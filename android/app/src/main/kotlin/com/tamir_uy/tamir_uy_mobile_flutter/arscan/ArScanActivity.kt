package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import android.Manifest
import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.google.ar.core.Anchor
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Config
import com.google.ar.core.HitResult
import com.google.ar.core.Plane
import com.google.ar.core.Session
import com.google.ar.core.TrackingFailureReason
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.UnavailableApkTooOldException
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException
import com.tamir_uy.tamir_uy_mobile_flutter.BackgroundRenderer
import org.json.JSONArray
import org.json.JSONObject
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

/**
 * Full-screen ARCore floor-plan scanner: find the floor → tap the corners
 * (snapping onto the first closes the outline) → aim at the ceiling line for
 * the height. Returns [FloorPlanCapture.toResult] as JSON in [EXTRA_RESULT].
 *
 * Threading: ARCore and [capture] live on the GL thread; button taps are
 * queued onto it with [GLSurfaceView.queueEvent]; UI updates go back with
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
        private const val NOTICE_MS = 2_500L
        private val PRESET_HEIGHTS = floatArrayOf(2.5f, 2.7f, 2.8f, 3.0f, 3.2f)
        private const val TAG = "ArScan"
    }

    private enum class Step { FIND_FLOOR, CORNERS, HEIGHT }

    // Fallbacks only; Flutter passes the copy in the user's language.
    private val fallback = mapOf(
        "arScanFindFloor" to "Telefonni polga qaratib sekin aylantiring",
        "arScanAddCorner" to "Burchak qo'shish",
        "arScanUndo" to "Bekor qilish",
        "arScanFinish" to "Tayyor",
        "arScanAimCeiling" to "Birinchi burchak ustidagi shift chizig'iga qarating",
        "arScanConfirm" to "Tasdiqlash",
        "arScanEnterManually" to "Qo'lda kiritish",
        "arScanExit" to "Chiqish",
        "arScanExitConfirm" to "O'lchovni to'xtatasizmi? Belgilangan burchaklar yo'qoladi.",
        "arScanTrackingLost" to "Yorug'lik kam yoki telefon tez harakatlandi",
        "arScanFloorHint" to "Yorug'roq joyda, gilam yoki naqshli polga qarating",
        "arScanSnapToFirst" to "Birinchi burchakka yaqinlashing — kontur yopiladi",
        "arScanCornersHint" to "Nishonni pol burchagiga keltirib, burchak qo'shing",
        "arScanCornersLost" to "Ba'zi burchaklar yo'qoldi — ularni qayta belgilang",
        "arScanNoFloorHere" to "Avval polni skaner qiling",
        "arScanKeepMeasuring" to "O'lchashni davom ettirish",
        "arScanStepFloor" to "1/3 — pol",
        "arScanStepCorners" to "2/3 — burchaklar",
        "arScanStepHeight" to "3/3 — balandlik",
    )
    private lateinit var strings: Map<String, String>
    private fun s(key: String) = strings[key] ?: fallback[key] ?: key

    private lateinit var surface: GLSurfaceView
    private lateinit var overlay: ArOverlayView
    private lateinit var hint: TextView
    private lateinit var stepLabel: TextView
    private lateinit var leftButton: Button
    private lateinit var mainButton: Button
    private lateinit var rightButton: Button

    private var session: Session? = null
    private var installRequested = false
    private val background = BackgroundRenderer()

    // GL-thread state.
    private val capture = FloorPlanCapture()
    private val anchors = mutableListOf<Anchor>()
    private var lastFloorHit: HitResult? = null
    @Volatile private var liveHeight: Float? = null
    @Volatile private var tracking = false
    private var wasTracking = false
    @Volatile private var step = Step.FIND_FLOOR
    // Set when anchors stopped tracking and corners were dropped; stays up
    // until the user adds or undoes a corner (a one-frame hint is never seen).
    @Volatile private var cornersLost = false
    // "Add corner" tapped with no floor under the reticle: a short notice
    // ("Avval polni skaner qiling") until this time (elapsedRealtime).
    @Volatile private var noFloorUntil = 0L
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
        root.addView(surface, FrameLayout.LayoutParams(-1, -1))
        root.addView(overlay, FrameLayout.LayoutParams(-1, -1))
        root.addView(buildChrome(), FrameLayout.LayoutParams(-1, -1))
        setContentView(root)
        render()

        if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(Manifest.permission.CAMERA), CAMERA_REQUEST)
        }
    }

    // ── chrome ────────────────────────────────────────────────────────────
    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    private fun pill(fill: Int) = GradientDrawable().apply { cornerRadius = dp(28).toFloat(); setColor(fill) }

    private fun button(primary: Boolean) = Button(this).apply {
        isAllCaps = false
        textSize = 15f
        setTextColor(Color.WHITE)
        background = pill(if (primary) Color.rgb(40, 80, 208) else Color.argb(150, 0, 0, 0))
        setPadding(dp(18), 0, dp(18), 0)
        minHeight = dp(52)
    }

    private fun buildChrome(): View {
        val chrome = FrameLayout(this)
        val top = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16), dp(48), dp(16), dp(8))
        }
        val exit = TextView(this).apply {
            text = "✕  ${s("arScanExit")}"
            setTextColor(Color.WHITE)
            textSize = 15f
            setPadding(dp(14), dp(8), dp(14), dp(8))
            background = pill(Color.argb(150, 0, 0, 0))
            setOnClickListener { confirmExit() }
        }
        stepLabel = TextView(this).apply { setTextColor(Color.WHITE); textSize = 13f; setPadding(0, dp(12), 0, 0) }
        hint = TextView(this).apply {
            setTextColor(Color.WHITE); textSize = 16f
            setPadding(dp(14), dp(10), dp(14), dp(10))
            background = pill(Color.argb(150, 0, 0, 0))
        }
        top.addView(exit, LinearLayout.LayoutParams(-2, -2))
        top.addView(stepLabel)
        top.addView(hint, LinearLayout.LayoutParams(-1, -2).apply { topMargin = dp(8) })
        chrome.addView(top, FrameLayout.LayoutParams(-1, -2, Gravity.TOP))

        val bottom = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            setPadding(dp(16), dp(8), dp(16), dp(36))
        }
        leftButton = button(false).apply { setOnClickListener { onLeft() } }
        mainButton = button(true).apply { setOnClickListener { onMain() } }
        rightButton = button(false).apply { setOnClickListener { onRight() } }
        val lp = { w: Float -> LinearLayout.LayoutParams(0, -2, w).apply { marginStart = dp(4); marginEnd = dp(4) } }
        bottom.addView(leftButton, lp(1f))
        bottom.addView(mainButton, lp(1.4f))
        bottom.addView(rightButton, lp(1f))
        chrome.addView(bottom, FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM))
        return chrome
    }

    /** UI from the current state (UI thread). */
    private fun render(
        trackingHint: String? = null,
        snapping: Boolean = false,
        n: Int = 0,
        height: Float? = null,
        notice: String? = null, // informational: shown, but doesn't block adding corners
    ) {
        stepLabel.text = when (step) {
            Step.FIND_FLOOR -> s("arScanStepFloor")
            Step.CORNERS -> s("arScanStepCorners")
            Step.HEIGHT -> s("arScanStepHeight")
        }
        hint.text = trackingHint ?: notice ?: when (step) {
            Step.FIND_FLOOR ->
                if (SystemClock.elapsedRealtime() - startedAt > FLOOR_HINT_AFTER_MS) s("arScanFloorHint") else s("arScanFindFloor")
            Step.CORNERS -> if (snapping) s("arScanSnapToFirst") else s("arScanCornersHint")
            Step.HEIGHT -> height?.let { "${s("arScanAimCeiling")} · ${ArOverlayView.metres(it)}" } ?: s("arScanAimCeiling")
        }
        when (step) {
            Step.FIND_FLOOR, Step.CORNERS -> {
                leftButton.text = s("arScanUndo"); leftButton.isEnabled = n > 0
                mainButton.text = s("arScanAddCorner"); mainButton.isEnabled = step == Step.CORNERS && trackingHint == null
                rightButton.text = s("arScanFinish"); rightButton.isEnabled = n >= 3
            }
            Step.HEIGHT -> {
                leftButton.text = s("arScanUndo"); leftButton.isEnabled = true
                mainButton.text = s("arScanConfirm"); mainButton.isEnabled = height != null
                rightButton.text = s("arScanEnterManually"); rightButton.isEnabled = true
            }
        }
        listOf(leftButton, mainButton, rightButton).forEach { it.alpha = if (it.isEnabled) 1f else 0.45f }
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

    private fun onMain() = onGl {
        when (step) {
            Step.FIND_FLOOR, Step.CORNERS -> addCorner()
            Step.HEIGHT -> liveHeight?.let { finishWith(it, measured = true) }
        }
    }

    private fun onLeft() = onGl {
        cornersLost = false
        if (step == Step.HEIGHT) {
            // Reopen in one tap: a snap-closed outline drops its closing tap
            // (and that anchor), so "add corner" works straight away.
            if (capture.reopen()) anchors.removeLastOrNull()?.detach()
            step = Step.CORNERS
        } else if (capture.undo()) {
            anchors.removeLastOrNull()?.detach()
        }
    }

    private fun onRight() {
        if (step == Step.HEIGHT) {
            val labels = PRESET_HEIGHTS.map { ArOverlayView.metres(it) }.toTypedArray()
            AlertDialog.Builder(this)
                .setTitle(s("arScanEnterManually"))
                .setItems(labels) { _, i -> onGl { finishWith(PRESET_HEIGHTS[i], measured = false) } }
                .show()
        } else {
            onGl { if (capture.corners.size >= 3) step = Step.HEIGHT }
        }
    }

    /** GL thread. */
    private fun addCorner() {
        if (!capture.canAddCorner(tracking = tracking)) return
        val hit = lastFloorHit
        if (hit == null) {
            noFloorUntil = SystemClock.elapsedRealtime() + NOTICE_MS
            return
        }
        val anchor = hit.createAnchor()
        val t = anchor.pose
        cornersLost = false
        noFloorUntil = 0L
        when (capture.addCorner(Vec3(t.tx(), t.ty(), t.tz()))) {
            AddResult.REJECTED_CLOSED, AddResult.REJECTED_DUPLICATE -> anchor.detach()
            AddResult.CLOSED -> { anchors.add(anchor); step = Step.HEIGHT }
            AddResult.ADDED -> { anchors.add(anchor); step = Step.CORNERS }
        }
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
        val result = capture.toResult(height, measured, seconds)
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
            if (wasTracking && !tracking) capture.trackingLossCount++
            wasTracking = tracking

            // Anchors drift as ARCore refines its map — keep corners in step;
            // stopped anchors are dropped together with their corners.
            val lost = capture.updatePositions(anchors.map {
                if (it.trackingState == TrackingState.STOPPED) null else Vec3(it.pose.tx(), it.pose.ty(), it.pose.tz())
            })
            if (lost > 0) {
                val keep = anchors.size - lost
                anchors.subList(keep, anchors.size).forEach { it.detach() }
                while (anchors.size > keep) anchors.removeAt(anchors.size - 1)
                cornersLost = true
                if (step == Step.HEIGHT) step = Step.CORNERS
            }

            // Floor under the reticle.
            lastFloorHit = if (!tracking) null else frame.hitTest(viewportW / 2f, viewportH / 2f).firstOrNull { hit ->
                val t = hit.trackable
                t is Plane && t.type == Plane.Type.HORIZONTAL_UPWARD_FACING && t.isPoseInPolygon(hit.hitPose) &&
                    (capture.floorY == null || kotlin.math.abs(hit.hitPose.ty() - capture.floorY!!) < 0.25f)
            }
            if (step == Step.FIND_FLOOR && lastFloorHit != null) step = Step.CORNERS
            val reticle = lastFloorHit?.hitPose?.let { Vec3(it.tx(), it.ty(), it.tz()) }

            // Ceiling height along the first corner's vertical axis.
            liveHeight = if (step == Step.HEIGHT && tracking) {
                val p = camera.pose
                val z = p.zAxis // camera looks down -Z
                capture.heightFromRay(Vec3(p.tx(), p.ty(), p.tz()), Vec3(-z[0], -z[1], -z[2]))
            } else null

            val view = FloatArray(16).also { camera.getViewMatrix(it, 0) }
            val proj = FloatArray(16).also { camera.getProjectionMatrix(it, 0, 0.05f, 100f) }
            val pr = ScreenProjector(view, proj, viewportW, viewportH)
            val corners = capture.corners
            val projected = corners.map { pr.project(it) }
            val labels = (0 until corners.size - 1).mapNotNull { i ->
                val a = projected[i]; val b = projected[i + 1]
                if (a == null || b == null) null else {
                    val len = kotlin.math.hypot(corners[i + 1].x - corners[i].x, corners[i + 1].z - corners[i].z)
                    Triple((a.first + b.first) / 2, (a.second + b.second) / 2, ArOverlayView.metres(len))
                }
            }
            val axis = if (step == Step.HEIGHT && corners.isNotEmpty()) {
                val base = corners[0]
                val a = pr.project(base); val b = pr.project(Vec3(base.x, base.y + (liveHeight ?: 2.7f), base.z))
                if (a != null && b != null) Pair(a, b) else null
            } else null
            val snapping = reticle != null && capture.wouldSnap(reticle)
            val trackingHint = if (tracking) null else when (camera.trackingFailureReason) {
                TrackingFailureReason.NONE -> null
                else -> s("arScanTrackingLost")
            }
            val state = OverlayState(
                corners = projected, labels = labels, reticleOnFloor = reticle != null,
                snapping = snapping, closed = capture.isClosed, heightAxis = axis,
                heightLabel = liveHeight?.let { ArOverlayView.metres(it) },
            )
            val n = corners.size
            val height = liveHeight
            val notice = when {
                cornersLost -> s("arScanCornersLost")
                SystemClock.elapsedRealtime() < noFloorUntil -> s("arScanNoFloorHere")
                else -> null
            }
            runOnUiThread {
                overlay.state = state
                render(trackingHint, snapping, n, height, notice)
            }
        } catch (e: Exception) {
            Log.w(TAG, "frame failed", e)
        }
    }
}
