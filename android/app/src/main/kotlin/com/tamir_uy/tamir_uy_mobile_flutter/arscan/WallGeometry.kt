package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.sin

/** A screen position in pixels. */
typealias Px = Pair<Float, Float>

data class Segment(val a: Px, val b: Px)

/** A wall on screen: its (clipped) outline, grid lines, and where its length goes. */
data class WallShape(val outline: List<Px>, val grid: List<Segment>, val labelAt: Px?)

/**
 * World geometry → screen pixels with ARCore's camera matrices (column-major).
 * Everything is clipped against the near plane first, so a wall that passes
 * beside or behind the camera stays a sane polygon instead of shooting off to
 * infinity. Plain Kotlin (no android.opengl) so it runs in JVM tests.
 */
class WallGeometry(
    private val view: FloatArray,
    private val proj: FloatArray,
    private val width: Int,
    private val height: Int,
    private val near: Float = 0.05f,
) {
    private class V(val x: Float, val y: Float, val z: Float)

    private fun toView(p: Vec3) = V(
        view[0] * p.x + view[4] * p.y + view[8] * p.z + view[12],
        view[1] * p.x + view[5] * p.y + view[9] * p.z + view[13],
        view[2] * p.x + view[6] * p.y + view[10] * p.z + view[14],
    )

    private fun visible(v: V) = v.z <= -near

    private fun toScreen(v: V): Px {
        val cx = proj[0] * v.x + proj[4] * v.y + proj[8] * v.z + proj[12]
        val cy = proj[1] * v.x + proj[5] * v.y + proj[9] * v.z + proj[13]
        val cw = proj[3] * v.x + proj[7] * v.y + proj[11] * v.z + proj[15]
        return Px((cx / cw + 1f) / 2f * width, (1f - cy / cw) / 2f * height)
    }

    private fun cut(a: V, b: V): V {
        val t = (-near - a.z) / (b.z - a.z)
        return V(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, -near)
    }

    /** Sutherland–Hodgman against the near plane (one clipping edge). */
    private fun clip(poly: List<V>): List<V> {
        val out = ArrayList<V>(poly.size + 1)
        for (i in poly.indices) {
            val cur = poly[i]
            val prev = poly[(i + poly.size - 1) % poly.size]
            if (visible(cur)) {
                if (!visible(prev)) out.add(cut(prev, cur))
                out.add(cur)
            } else if (visible(prev)) {
                out.add(cut(prev, cur))
            }
        }
        return out
    }

    /** `null` when the point is behind the near plane. */
    fun point(p: Vec3): Px? = toView(p).takeIf(::visible)?.let(::toScreen)

    fun segment(a: Vec3, b: Vec3): Segment? {
        val va = toView(a); val vb = toView(b)
        return when {
            visible(va) && visible(vb) -> Segment(toScreen(va), toScreen(vb))
            visible(va) -> Segment(toScreen(va), toScreen(cut(va, vb)))
            visible(vb) -> Segment(toScreen(cut(va, vb)), toScreen(vb))
            else -> null
        }
    }

    /** The wall standing on floor points [a]→[b], [height] tall; `null` if wholly behind. */
    fun wall(a: Vec3, b: Vec3, height: Float, gridStep: Float = 0.5f): WallShape? {
        val ta = Vec3(a.x, a.y + height, a.z)
        val tb = Vec3(b.x, b.y + height, b.z)
        val outline = clip(listOf(a, b, tb, ta).map(::toView))
        if (outline.size < 3) return null

        val grid = ArrayList<Segment>()
        val len = hypot(b.x - a.x, b.z - a.z)
        if (len > 0f) {
            var d = gridStep
            while (d < len - 1e-3f) {
                val t = d / len
                val bottom = Vec3(a.x + (b.x - a.x) * t, a.y, a.z + (b.z - a.z) * t)
                segment(bottom, Vec3(bottom.x, bottom.y + height, bottom.z))?.let(grid::add)
                d += gridStep
            }
        }
        var h = gridStep
        while (h < height - 1e-3f) {
            segment(Vec3(a.x, a.y + h, a.z), Vec3(b.x, b.y + h, b.z))?.let(grid::add)
            h += gridStep
        }
        val mid = Vec3((a.x + b.x) / 2, (a.y + b.y) / 2, (a.z + b.z) / 2)
        return WallShape(outline.map(::toScreen), grid, point(mid))
    }

    /** A circle of [radius] lying on the floor at [center], as a screen polygon; `null` unless all of it is in view. */
    fun floorEllipse(center: Vec3, radius: Float = 0.15f, steps: Int = 32): List<Px>? {
        val pts = (0 until steps).map { i ->
            val a = 2.0 * PI * i / steps
            point(Vec3(center.x + radius * cos(a).toFloat(), center.y, center.z + radius * sin(a).toFloat()))
        }
        return if (pts.any { it == null }) null else pts.map { it!! }
    }
}
