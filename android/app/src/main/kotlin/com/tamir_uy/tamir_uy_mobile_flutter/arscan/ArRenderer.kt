package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.opengl.Matrix
import android.view.View
import java.util.Locale

/** Projects world points to screen pixels with ARCore's camera matrices. */
class ScreenProjector(private val view: FloatArray, private val proj: FloatArray, private val w: Int, private val h: Int) {
    private val vp = FloatArray(16).also { Matrix.multiplyMM(it, 0, proj, 0, view, 0) }

    /** `null` when the point is behind the camera. */
    fun project(p: Vec3): Pair<Float, Float>? {
        val v = floatArrayOf(p.x, p.y, p.z, 1f)
        val out = FloatArray(4)
        Matrix.multiplyMV(out, 0, vp, 0, v, 0)
        if (out[3] <= 0f) return null
        val nx = out[0] / out[3]
        val ny = out[1] / out[3]
        return Pair((nx + 1f) / 2f * w, (1f - ny) / 2f * h)
    }
}

/** What the overlay draws this frame (screen pixels). */
data class OverlayState(
    val corners: List<Pair<Float, Float>?> = emptyList(),
    val labels: List<Triple<Float, Float, String>> = emptyList(),
    val reticleOnFloor: Boolean = false,
    val snapping: Boolean = false,
    val closed: Boolean = false,
    val heightAxis: Pair<Pair<Float, Float>, Pair<Float, Float>>? = null,
    val heightLabel: String? = null,
    /** Walls ARCore found, as floor lines. */
    val walls: List<Pair<Pair<Float, Float>, Pair<Float, Float>>> = emptyList(),
    /** Where walls meet — corners that can go in on their own. */
    val candidates: List<Pair<Float, Float>> = emptyList(),
    /** 0–1: how long the target has been held still. */
    val dwell: Float = 0f,
    /** Target drawn here when snapped to a wall corner; null = screen centre. */
    val reticleAt: Pair<Float, Float>? = null,
    /** Doors/windows on the outline: (start, end, isWindow). */
    val openings: List<Triple<Pair<Float, Float>, Pair<Float, Float>, Boolean>> = emptyList(),
    /** The first edge of the opening being marked, and its live width. */
    val pendingEdge: Pair<Float, Float>? = null,
    val pendingLabel: String? = null,
)

/** Transparent view over the camera: outline, corner dots, lengths and the aim reticle. */
class ArOverlayView(context: Context) : View(context) {
    private val density = resources.displayMetrics.density
    private val line = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; strokeWidth = 3f * density; style = Paint.Style.STROKE }
    private val dot = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(40, 80, 208) }
    private val ring = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 2.5f * density }
    private val text = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; textSize = 14f * density; textAlign = Paint.Align.CENTER; setShadowLayer(4f, 0f, 0f, Color.BLACK) }
    private val wall = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(59, 130, 246); strokeWidth = 3f * density; strokeCap = Paint.Cap.ROUND }
    private val candidate = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; style = Paint.Style.STROKE; strokeWidth = 2.5f * density }
    private val progress = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(59, 130, 246); style = Paint.Style.STROKE; strokeWidth = 4f * density; strokeCap = Paint.Cap.ROUND }
    private val axis = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(249, 115, 22); strokeWidth = 3f * density }

    private val door = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(34, 197, 94); strokeWidth = 6f * density; strokeCap = Paint.Cap.ROUND }
    private val window = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(59, 130, 246); strokeWidth = 6f * density; strokeCap = Paint.Cap.ROUND }

    var state = OverlayState()
        set(value) { field = value; postInvalidateOnAnimation() }

    override fun onDraw(canvas: Canvas) {
        val s = state
        for ((a, b) in s.walls) canvas.drawLine(a.first, a.second, b.first, b.second, wall)
        for (c in s.candidates) canvas.drawCircle(c.first, c.second, 9f * density, candidate)
        val pts = s.corners
        for (i in 0 until pts.size - 1) {
            val a = pts[i] ?: continue
            val b = pts[i + 1] ?: continue
            canvas.drawLine(a.first, a.second, b.first, b.second, line)
        }
        if (s.closed && pts.size >= 3) {
            val a = pts.last(); val b = pts.first()
            if (a != null && b != null) canvas.drawLine(a.first, a.second, b.first, b.second, line)
        }
        for (p in pts) if (p != null) canvas.drawCircle(p.first, p.second, 7f * density, dot)
        for ((x, y, label) in s.labels) canvas.drawText(label, x, y, text)
        for ((a, b, isWindow) in s.openings) canvas.drawLine(a.first, a.second, b.first, b.second, if (isWindow) window else door)

        s.heightAxis?.let { (a, b) -> canvas.drawLine(a.first, a.second, b.first, b.second, axis) }
        s.heightLabel?.let { canvas.drawText(it, width / 2f, height / 2f - 40f * density, text) }

        // Aim reticle in the centre: white ring, blue when it would snap.
        val cx = s.reticleAt?.first ?: (width / 2f)
        val cy = s.reticleAt?.second ?: (height / 2f)
        ring.color = when {
            s.snapping || s.reticleAt != null -> Color.rgb(40, 80, 208)
            s.reticleOnFloor -> Color.WHITE
            else -> Color.argb(110, 255, 255, 255)
        }
        s.pendingEdge?.let { p ->
            canvas.drawLine(p.first, p.second, cx, cy, door)
            canvas.drawCircle(p.first, p.second, 7f * density, dot)
            s.pendingLabel?.let { canvas.drawText(it, (p.first + cx) / 2, (p.second + cy) / 2 - 12f * density, text) }
        }
        canvas.drawCircle(cx, cy, 18f * density, ring)
        canvas.drawCircle(cx, cy, 2.5f * density, ring)
        if (s.dwell > 0f) {
            val r = 18f * density
            canvas.drawArc(cx - r, cy - r, cx + r, cy + r, -90f, 360f * s.dwell, false, progress)
        }
    }

    companion object {
        fun metres(m: Float): String = String.format(Locale.US, "%.2f m", m)
    }
}
