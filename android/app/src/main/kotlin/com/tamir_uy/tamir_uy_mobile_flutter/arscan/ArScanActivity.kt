package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.HapticFeedbackConstants
import android.widget.FrameLayout
import com.google.ar.core.Anchor
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.Plane
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.UnavailableApkTooOldException
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException
import com.tamir_uy.tamir_uy_mobile_flutter.BackgroundRenderer
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10
import kotlin.math.hypot

/**
 * Full-screen ARCore room scanner: find the floor → base point where a wall
 * meets the floor → pull the height up → add corners while 3D walls grow →
 * done. Steps and copy come from [ScanFlow]; walls are projected by
 * [WallGeometry] and drawn by [ArOverlayView]. Returns
 * [FloorPlanCapture.toResult] as JSON in [EXTRA_RESULT].
 *
 * Threading: ARCore, [flow] and [anchors] live on the GL thread; button taps
 * are queued onto it with [GLSurfaceView.queueEvent]; UI updates go back with
 * [runOnUiThread].
 */
class ArScanActivity : Activity(), GLSurfaceView.Renderer {

    companion object {
        const val EXTRA_STRINGS = "strings"
        const val EXTRA_RESULT = "result"
        const val EXTRA_ERROR = "errorCode"
        const val EXTRA_ERROR_MESSAGE = "errorMessage"
        private const val CAMERA_REQUEST = 4202
        private const val FLOOR_HINT_AFTER_MS = 20_000L
        private val PRESET_HEIGHTS = floatArrayOf(2.5f, 2.7f, 2.8f, 3.0f)
        private const val TAG = "ArScan"
    }

    // Fallbacks only; Flutter passes the copy in the user's language.
    private val fallback = mapOf(
        "arScanFindFloor" to "Telefonni polga qaratib sekin aylantiring",
        "arScanFloorHint" to "Yorug'roq joyda, gilam yoki naqshli polga qarating",
        "arScanBaseHint" to "Nishonni devor va pol tutashgan burchakka qo'ying",
        "arScanStart" to "Boshlash",
        "arScanAimCeiling" to "Telefonni yuqoriga burib, chiziqni shiftgacha torting",
        "arScanConfirm" to "Tasdiqlash",
        "arScanCornersHint" to "Nishonni keyingi burchakka qo'yib, burchak qo'shing",
        "arScanSnapToFirst" to "Birinchi burchakka yaqinlashing — kontur yopiladi",
        "arScanAddCorner" to "Burchak qo'shish",
        "arScanCloseRoom" to "Xonani yopish",
        "arScanDoneHint" to "Xona tayyor. Xato bo'lsa, ↶ bilan qayting",
        "arScanCreatePlan" to "Rejani yaratish",
        "arScanUndo" to "Bekor qilish",
        "arScanExit" to "Chiqish",
        "arScanExitConfirm" to "O'lchovni to'xtatasizmi? Belgilangan burchaklar yo'qoladi.",
        "arScanKeepMeasuring" to "O'lchashni davom ettirish",
        "arScanTrackingLost" to "Yorug'lik kam yoki telefon tez harakatlandi",
        "arScanCornersLost" to "Ba'zi burchaklar yo'qoldi — ularni qayta belgilang",
        "arScanNoFloorHere" to "Nishon polga tushmayapti — telefonni pastroq qarating",
        "arScanPerimeter" to "Perimetr",
        "arScanArea" to "Maydon",
        "arScanVolume" to "Hajm",
        "arScanUnitCm" to "sm",
        "arScanUnitM" to "m",
    )
    private lateinit var strings: Map<String, String>
    private fun s(key: String) = strings[key] ?: fallback[key] ?: key

    private lateinit var surface: GLSurfaceView
    private lateinit var overlay: ArOverlayView
    private lateinit var chrome: ArScanChrome

    private var session: Session? = null
    private var installRequested = false
    private val background = BackgroundRenderer()

    // GL-thread state. One anchor per corner in flow.capture, in order.
    private val flow = ScanFlow()
    private val anchors = mutableListOf<Anchor>()
    private var reticle: Vec3? = null
    // The lowest tracked upward plane until the base point fixes the floor.
    private var floorCandidateY: Float? = null
    @Volatile private var liveHeight: Float? = null
    @Volatile private var tracking = false
    private var wasTracking = false
    // Set when anchors stopped tracking and corners were dropped; stays up
    // until the user's next action (a one-frame hint is never seen).
    @Volatile private var cornersLost = false
    private var viewportW = 0
    private var viewportH = 0
    private var viewportChanged = false

    private val startedAt = SystemClock.elapsedRealtime()
    @Volatile private var finished = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        @Suppress("UNCHECKED_CAST", "DEPRECATION")
        strings = (intent.getSerializableExtra(EXTRA_STRINGS) as? HashMap<String, String>) ?: emptyMap()

        val root = FrameLayout(this).apply { setBackgroundColor(Color.BLACK) }
        surface = GLSurfaceView(this).apply {
            preserveEGLContextOnPause = true
            setEGLContextClientVersion(2)
            setEGLConfigChooser(8, 8, 8, 8, 16, 0)
            setRenderer(this@ArScanActivity)
            renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
        }
        overlay = ArOverlayView(this)
        chrome = ArScanChrome(this, ::s, PRESET_HEIGHTS).apply {
            onExit = ::confirmExit
            onUndo = ::onUndo
            onMain = ::onMain
            onCloseRoom = ::onCloseRoom
            onChip = ::onChip
        }
        root.addView(surface, FrameLayout.LayoutParams(-1, -1))
        root.addView(overlay, FrameLayout.LayoutParams(-1, -1))
        root.addView(chrome.root, FrameLayout.LayoutParams(-1, -1))
        setContentView(root)
        chrome.bind(flow.ui(tracking = false, reticle = null, liveHeight = null), s("arScanFindFloor"), null)

        if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(Manifest.permission.CAMERA), CAMERA_REQUEST)
        }
    }

    // ── actions (UI thread → GL thread) ────────────────────────────────────
    /** Runs [block] on the GL thread; ARCore can throw there (tracking lost, session paused). */
    private fun onGl(block: () -> Unit) = surface.queueEvent {
        try {
            if (!finished && session != null) block()
        } catch (e: Exception) {
            Log.w(TAG, "action failed", e)
        }
    }

    private fun haptic(constant: Int) = runOnUiThread { overlay.performHapticFeedback(constant) }

    /** GL thread: a world anchor on the floor under the reticle. */
    private fun anchorAtReticle(): Anchor? {
        val p = reticle ?: return null
        if (!tracking) return null
        return session?.createAnchor(Pose.makeTranslation(p.x, p.y, p.z))
    }

    private fun Anchor.vec() = Vec3(pose.tx(), pose.ty(), pose.tz())

    private fun onMain() = onGl {
        cornersLost = false
        when (flow.step) {
            ScanStep.FIND_FLOOR -> Unit
            ScanStep.BASE -> {
                val anchor = anchorAtReticle() ?: return@onGl
                if (flow.placeBase(anchor.vec())) {
                    anchors.add(anchor); haptic(HapticFeedbackConstants.VIRTUAL_KEY)
                } else {
                    anchor.detach()
                }
            }
            ScanStep.HEIGHT -> liveHeight?.let { flow.confirmHeight(it, measured = true) }
            ScanStep.WALLS -> {
                val anchor = anchorAtReticle() ?: return@onGl
                when (flow.addCorner(anchor.vec())) {
                    AddResult.ADDED -> { anchors.add(anchor); haptic(HapticFeedbackConstants.VIRTUAL_KEY) }
                    AddResult.CLOSED -> { anchors.add(anchor); haptic(HapticFeedbackConstants.LONG_PRESS) }
                    AddResult.REJECTED_CLOSED, AddResult.REJECTED_DUPLICATE -> anchor.detach()
                }
            }
            ScanStep.DONE -> flow.height?.let { finishWith(it, flow.heightMeasured) }
        }
    }

    private fun onCloseRoom() = onGl {
        cornersLost = false
        val first = anchors.firstOrNull() ?: return@onGl
        if (flow.closeRoom()) {
            // close() appended a copy of the first corner; keep one anchor per corner.
            session?.createAnchor(first.pose)?.let(anchors::add)
            haptic(HapticFeedbackConstants.LONG_PRESS)
        }
    }

    private fun onChip(h: Float) = onGl { flow.confirmHeight(h, measured = false) }

    private fun onUndo() = onGl {
        cornersLost = false
        repeat(flow.undo()) { anchors.removeLastOrNull()?.detach() }
    }

    private fun confirmExit() {
        AlertDialog.Builder(this)
            .setMessage(s("arScanExitConfirm"))
            .setPositiveButton(s("arScanExit")) { _, _ -> cancel() }
            .setNegativeButton(s("arScanKeepMeasuring"), null)
            .show()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() = confirmExit()

    // ── results ───────────────────────────────────────────────────────────
    /** GL thread: snapshot the result there, then leave on the UI thread. */
    private fun finishWith(height: Float, measured: Boolean) {
        if (finished) return
        val seconds = ((SystemClock.elapsedRealtime() - startedAt) / 1000).toInt()
        val result = flow.capture.toResult(height, measured, seconds)
        val json = JSONObject().apply {
            put("corners", JSONArray().apply {
                @Suppress("UNCHECKED_CAST")
                (result["corners"] as List<List<Double>>).forEach { put(JSONArray(it)) }
            })
            put("height", result["height"]); put("heightMeasured", result["heightMeasured"])
            put("closed", result["closed"]); put("trackingLossCount", result["trackingLossCount"])
            put("durationSec", result["durationSec"])
        }.toString()
        Log.i(TAG, json)
        finished = true
        runOnUiThread {
            setResult(RESULT_OK, Intent().putExtra(EXTRA_RESULT, json))
            finish()
        }
    }

    private fun cancel() {
        if (finished) return
        finished = true
        setResult(RESULT_CANCELED)
        finish()
    }

    private fun fail(code: String, message: String) {
        if (finished) return
        finished = true
        setResult(RESULT_CANCELED, Intent().putExtra(EXTRA_ERROR, code).putExtra(EXTRA_ERROR_MESSAGE, message))
        finish()
    }

    // ── lifecycle ─────────────────────────────────────────────────────────
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CAMERA_REQUEST &&
            checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
        ) fail("camera_denied", "Camera permission denied")
    }

    override fun onResume() {
        super.onResume()
        if (finished || checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) return
        if (session == null && !createSession()) return
        try {
            session?.resume()
        } catch (e: CameraNotAvailableException) {
            fail("session_failed", "Camera not available")
            return
        }
        surface.onResume()
    }

    override fun onPause() {
        super.onPause()
        if (session != null) {
            surface.onPause()
            session?.pause()
        }
    }

    override fun onDestroy() {
        session?.close()
        session = null
        super.onDestroy()
    }

    private fun createSession(): Boolean {
        try {
            if (ArCoreApk.getInstance().requestInstall(this, !installRequested) ==
                ArCoreApk.InstallStatus.INSTALL_REQUESTED
            ) {
                installRequested = true
                return false
            }
            val s = Session(this)
            s.configure(Config(s).apply {
                planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
                depthMode = if (s.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) Config.DepthMode.AUTOMATIC else Config.DepthMode.DISABLED
                focusMode = Config.FocusMode.AUTO
                updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
            })
            session = s
            return true
        } catch (e: UnavailableUserDeclinedInstallationException) {
            fail("arcore_not_installed", "ARCore installation declined")
        } catch (e: UnavailableArcoreNotInstalledException) {
            fail("arcore_not_installed", "ARCore is not installed")
        } catch (e: UnavailableApkTooOldException) {
            fail("arcore_not_installed", "ARCore is too old")
        } catch (e: UnavailableDeviceNotCompatibleException) {
            fail("unsupported_device", "Device does not support ARCore")
        } catch (e: Exception) {
            fail("session_failed", e.message ?: "Could not start AR")
        }
        return false
    }

    // ── GL ────────────────────────────────────────────────────────────────
    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        background.createOnGlThread()
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        GLES20.glViewport(0, 0, width, height)
        viewportW = width; viewportH = height; viewportChanged = true
    }

    private fun isUpwardFloor(p: Plane) =
        p.type == Plane.Type.HORIZONTAL_UPWARD_FACING && p.trackingState == TrackingState.TRACKING && p.subsumedBy == null

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val s = session ?: return
        if (finished) return
        try {
            if (viewportChanged) {
                @Suppress("DEPRECATION")
                s.setDisplayGeometry(windowManager.defaultDisplay.rotation, viewportW, viewportH)
                viewportChanged = false
            }
            s.setCameraTextureName(background.textureId)
            val frame = s.update()
            background.draw(frame)
            val camera = frame.camera

            tracking = camera.trackingState == TrackingState.TRACKING
            if (wasTracking && !tracking) flow.capture.trackingLossCount++
            wasTracking = tracking

            // Anchors drift as ARCore refines its map — keep corners in step;
            // stopped anchors are dropped together with their corners.
            val lost = flow.capture.updatePositions(anchors.map {
                if (it.trackingState == TrackingState.STOPPED) null else it.vec()
            })
            if (lost > 0) {
                val keep = anchors.size - lost
                anchors.subList(keep, anchors.size).forEach { it.detach() }
                while (anchors.size > keep) anchors.removeAt(anchors.size - 1)
                flow.cornersLost()
                cornersLost = true
            }

            // The floor: the lowest upward plane (a table top is higher) until the base point fixes it.
            if (tracking && flow.capture.floorY == null) {
                s.getAllTrackables(Plane::class.java).filter(::isUpwardFloor)
                    .minOfOrNull { it.centerPose.ty() }
                    ?.let { floorCandidateY = it; flow.floorFound() }
            }
            val floorY = flow.capture.floorY ?: floorCandidateY

            // The aim: a real floor hit at the centre, else the camera ray on the floor plane.
            reticle = if (!tracking || floorY == null) null else {
                val planeHit = frame.hitTest(viewportW / 2f, viewportH / 2f).firstOrNull { hit ->
                    val t = hit.trackable
                    t is Plane && t.type == Plane.Type.HORIZONTAL_UPWARD_FACING
                }?.hitPose?.let { Vec3(it.tx(), it.ty(), it.tz()) }
                val p = camera.pose
                val z = p.zAxis // camera looks down -Z
                val rayHit = FloorRay.hit(Vec3(p.tx(), p.ty(), p.tz()), Vec3(-z[0], -z[1], -z[2]), floorY)
                FloorRay.pick(planeHit, rayHit, floorY)
            }

            // Ceiling height along the base point's vertical axis.
            liveHeight = if (flow.step == ScanStep.HEIGHT && tracking) {
                val p = camera.pose
                val z = p.zAxis
                flow.capture.heightFromRay(Vec3(p.tx(), p.ty(), p.tz()), Vec3(-z[0], -z[1], -z[2]))
            } else null

            val view = FloatArray(16).also { camera.getViewMatrix(it, 0) }
            val proj = FloatArray(16).also { camera.getProjectionMatrix(it, 0, 0.05f, 100f) }
            val state = overlayState(WallGeometry(view, proj, viewportW, viewportH))
            val ui = flow.ui(tracking, reticle, liveHeight)
            val hintKey = when {
                flow.step == ScanStep.FIND_FLOOR && tracking &&
                    SystemClock.elapsedRealtime() - startedAt > FLOOR_HINT_AFTER_MS -> "arScanFloorHint"
                cornersLost && tracking -> "arScanCornersLost"
                else -> ui.hintKey
            }
            val summary = flow.height?.takeIf { flow.step == ScanStep.DONE }?.let(::summaryText)
            runOnUiThread {
                overlay.state = state
                chrome.bind(ui, s(hintKey), summary)
            }
        } catch (e: Exception) {
            Log.w(TAG, "frame failed", e)
        }
    }

    /** GL thread: walls, the live wall, the height line and the reticle on screen. */
    private fun overlayState(geo: WallGeometry): OverlayState {
        val cm = s("arScanUnitCm")
        val corners = flow.capture.corners
        val h = flow.height
        val step = flow.step
        val walls = ArrayList<WallShape>()
        val labels = ArrayList<Pair<Px, String>>()
        if (h != null) {
            for (i in 0 until corners.size - 1) {
                val a = corners[i]; val b = corners[i + 1]
                val w = geo.wall(a, b, h) ?: continue
                walls.add(w)
                w.labelAt?.let { labels.add(it to ArOverlayView.cm(hypot(b.x - a.x, b.z - a.z), cm)) }
            }
        }
        val aim = reticle
        val liveWall = if (step == ScanStep.WALLS && h != null && aim != null) {
            corners.lastOrNull()?.let { last ->
                geo.wall(last, aim, h)?.also { w ->
                    w.labelAt?.let { labels.add(it to ArOverlayView.cm(hypot(aim.x - last.x, aim.z - last.z), cm)) }
                }
            }
        } else null

        val base = corners.firstOrNull()
        val shownHeight = if (step == ScanStep.HEIGHT) liveHeight else h
        val heightAxis = if (step == ScanStep.HEIGHT && base != null && shownHeight != null) {
            geo.segment(base, Vec3(base.x, base.y + shownHeight, base.z))
        } else null
        val heightLabel = if (base != null && shownHeight != null) {
            geo.point(Vec3(base.x, base.y + shownHeight, base.z))?.let { it to "H = ${ArOverlayView.cm(shownHeight, cm)}" }
        } else null

        val showReticle = step == ScanStep.BASE || step == ScanStep.WALLS
        return OverlayState(
            walls = walls,
            liveWall = liveWall,
            heightAxis = heightAxis,
            heightLabel = heightLabel,
            reticle = if (showReticle && aim != null) geo.floorEllipse(aim) else null,
            reticleSnapping = step == ScanStep.WALLS && aim != null && flow.capture.wouldSnap(aim),
            labels = labels,
            onboarding = step == ScanStep.FIND_FLOOR,
        )
    }

    private fun summaryText(height: Float): String {
        val m = s("arScanUnitM")
        val r = flow.capture.summary(height)
        return String.format(
            Locale.US, "%s %.1f %s · %s %.1f %s² · %s %.1f %s³",
            s("arScanPerimeter"), r.perimeterM, m, s("arScanArea"), r.areaM2, m, s("arScanVolume"), r.volumeM3, m,
        )
    }
}
