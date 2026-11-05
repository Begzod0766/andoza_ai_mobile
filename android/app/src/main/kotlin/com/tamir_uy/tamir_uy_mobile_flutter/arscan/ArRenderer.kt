package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.os.SystemClock
import android.view.View
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.roundToInt
import kotlin.math.sin

/** What the overlay draws this frame (screen pixels, from [WallGeometry]). */
data class OverlayState(
    val walls: List<WallShape> = emptyList(),
    val liveWall: WallShape? = null,
    val heightAxis: Segment? = null,
    val heightLabel: Pair<Px, String>? = null,
    val reticle: List<Px>? = null,
    val reticleSnapping: Boolean = false,
    val labels: List<Pair<Px, String>> = emptyList(),
    val onboarding: Boolean = false,
    /** Doors and windows on the walls: (outline, isWindow). */
    val openings: List<Pair<List<Px>, Boolean>> = emptyList(),
    /** The first corner while the room can be closed: a ring on it, or an arrow at the edge. */
    val firstCorner: ScreenTarget? = null,
    val firstCornerLabel: String? = null,
    /** Height step before the ray reaches the ceiling: "turn the phone up". */
    val ceilingArrow: Boolean = false,
)

/**
 * Transparent view over the camera: translucent gridded walls, length chips,
 * the floor reticle, the height line and the "move the phone" animation.
 */
class ArOverlayView(context: Context) : View(context) {
    private val density = resources.displayMetrics.density
    private fun dp(v: Float) = v * density

    private val wallFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(70, 110, 100, 230); style = Paint.Style.FILL }
    private val liveFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(40, 110, 100, 230); style = Paint.Style.FILL }
    private val edge = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; strokeWidth = dp(3f); style = Paint.Style.STROKE; strokeJoin = Paint.Join.ROUND }
    private val grid = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(60, 255, 255, 255); strokeWidth = dp(1f) }
    private val reticleFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(150, 110, 100, 230); style = Paint.Style.FILL }
    private val reticleSnapFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; style = Paint.Style.FILL }
    private val reticleEdge = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; strokeWidth = dp(2f); style = Paint.Style.STROKE }
    private val faintRing = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(110, 255, 255, 255); strokeWidth = dp(2f); style = Paint.Style.STROKE }
    private val doorFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(120, 34, 197, 94); style = Paint.Style.FILL }
    private val windowFill = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.argb(120, 59, 130, 246); style = Paint.Style.FILL }
    private val chipBg = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE }
    private val chipText = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.rgb(64, 56, 160); textSize = dp(13f); textAlign = Paint.Align.CENTER; isFakeBoldText = true }
    private val pulseRing = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; strokeWidth = dp(3f); style = Paint.Style.STROKE }
    private val guide = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = Color.WHITE; strokeWidth = dp(2.5f); style = Paint.Style.STROKE; strokeJoin = Paint.Join.ROUND }

    var state = OverlayState()
        set(value) { field = value; postInvalidateOnAnimation() }

    override fun onDraw(canvas: Canvas) {
        val s = state
        for (w in s.walls) drawWall(canvas, w, wallFill)
        s.liveWall?.let { drawWall(canvas, it, liveFill) }
        for ((outline, isWindow) in s.openings) {
            val path = polygon(outline)
            canvas.drawPath(path, if (isWindow) windowFill else doorFill)
            canvas.drawPath(path, edge)
        }
        s.heightAxis?.let { canvas.drawLine(it.a.first, it.a.second, it.b.first, it.b.second, edge) }

        val r = s.reticle
        if (r != null) {
            val path = polygon(r)
            canvas.drawPath(path, if (s.reticleSnapping) reticleSnapFill else reticleFill)
            canvas.drawPath(path, reticleEdge)
            val cx = r.sumOf { it.first.toDouble() }.toFloat() / r.size
            val cy = r.sumOf { it.second.toDouble() }.toFloat() / r.size
            canvas.drawCircle(cx, cy, dp(4f), reticleEdge)
        } else if (!s.onboarding) {
            canvas.drawCircle(width / 2f, height / 2f, dp(18f), faintRing)
        }

        for ((at, text) in s.labels) chip(canvas, at, text)
        s.heightLabel?.let { (at, text) -> chip(canvas, at, text) }
        s.firstCorner?.let { drawFirstCorner(canvas, it, s.firstCornerLabel) }
        if (s.ceilingArrow) drawCeilingArrow(canvas)
        if (s.onboarding) {
            drawOnboarding(canvas)
            postInvalidateOnAnimation()
        }
    }

    private fun pulse(periodMs: Long) = (SystemClock.uptimeMillis() % periodMs) / periodMs.toFloat()

    private fun drawFirstCorner(canvas: Canvas, t: ScreenTarget, label: String?) {
        when (t) {
            is ScreenTarget.OnScreen -> {
                val (x, y) = t.at
                val p = pulse(1200L)
                pulseRing.alpha = ((1f - p) * 220).toInt()
                canvas.drawCircle(x, y, dp(16f) + dp(18f) * p, pulseRing)
                canvas.drawCircle(x, y, dp(10f), reticleEdge)
                label?.let { chip(canvas, Px(x, y + dp(40f)), it) }
            }
            is ScreenTarget.OffScreen -> {
                val (x, y) = t.at
                val size = dp(22f)
                canvas.save()
                canvas.rotate(Math.toDegrees(t.angleRad.toDouble()).toFloat(), x, y)
                val arrow = Path().apply {
                    moveTo(x + size, y); lineTo(x - size * 0.6f, y - size * 0.8f)
                    lineTo(x - size * 0.2f, y); lineTo(x - size * 0.6f, y + size * 0.8f); close()
                }
                canvas.drawPath(arrow, reticleSnapFill)
                canvas.drawPath(arrow, reticleFill)
                canvas.restore()
                // The label sits on the screen side of the arrow.
                val back = dp(44f)
                label?.let { chip(canvas, Px(x - cos(t.angleRad) * back, y - sin(t.angleRad) * back), it) }
            }
        }
    }

    /** Two chevrons above the centre, drifting up. */
    private fun drawCeilingArrow(canvas: Canvas) {
        val cx = width / 2f
        val base = height * 0.35f - dp(12f) * pulse(1000L)
        for (i in 0..1) {
            val y = base - i * dp(18f)
            canvas.drawLine(cx - dp(18f), y + dp(10f), cx, y - dp(6f), guide)
            canvas.drawLine(cx, y - dp(6f), cx + dp(18f), y + dp(10f), guide)
        }
    }

    private fun polygon(pts: List<Px>) = Path().apply {
        pts.forEachIndexed { i, p -> if (i == 0) moveTo(p.first, p.second) else lineTo(p.first, p.second) }
        close()
    }

    private fun drawWall(canvas: Canvas, w: WallShape, fill: Paint) {
        val path = polygon(w.outline)
        canvas.drawPath(path, fill)
        for (g in w.grid) canvas.drawLine(g.a.first, g.a.second, g.b.first, g.b.second, grid)
        canvas.drawPath(path, edge)
    }

    private fun chip(canvas: Canvas, at: Px, text: String) {
        val w = chipText.measureText(text) + dp(20f)
        val h = dp(28f)
        val x = keepOnScreen(at.first, w / 2, width.toFloat(), dp(8f))
        val y = keepOnScreen(at.second, h / 2, height.toFloat(), dp(8f))
        val rect = RectF(x - w / 2, y - h / 2, x + w / 2, y + h / 2)
        canvas.drawRoundRect(rect, dp(8f), dp(8f), chipBg)
        canvas.drawText(text, x, y - (chipText.descent() + chipText.ascent()) / 2, chipText)
    }

    /** A floor tile in perspective with a phone sweeping over it. */
    private fun drawOnboarding(canvas: Canvas) {
        val cx = width / 2f
        val cy = height * 0.55f
        val topW = width * 0.45f
        val botW = width * 0.7f
        val h = height * 0.12f
        val floor = Path().apply {
            moveTo(cx - topW / 2, cy - h / 2); lineTo(cx + topW / 2, cy - h / 2)
            lineTo(cx + botW / 2, cy + h / 2); lineTo(cx - botW / 2, cy + h / 2); close()
        }
        canvas.drawPath(floor, guide)
        for (i in 1..3) {
            val t = i / 4f
            canvas.drawLine(cx - topW / 2 + topW * t, cy - h / 2, cx - botW / 2 + botW * t, cy + h / 2, grid)
        }
        val phase = (SystemClock.uptimeMillis() % 2400L) / 2400.0
        val dx = (sin(phase * 2 * PI) * width * 0.12).toFloat()
        val pw = width * 0.13f
        val ph = pw * 1.9f
        canvas.save()
        canvas.rotate(-15f, cx + dx, cy)
        canvas.drawRoundRect(RectF(cx + dx - pw / 2, cy - ph / 2, cx + dx + pw / 2, cy + ph / 2), dp(10f), dp(10f), guide)
        canvas.restore()
    }

    companion object {
        /** "493 sm" — wall lengths and height in whole centimetres. */
        fun cm(m: Float, unit: String): String = "${(m * 100).roundToInt()} $unit"
    }
}
