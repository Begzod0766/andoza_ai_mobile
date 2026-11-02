package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.hypot

enum class OpeningType(val wire: String) { DOOR("door"), WINDOW("window") }

/** Where the target lands on the outline: edge [edge] (corner i → i+1) at fraction [t]; [x],[z] is that point. */
data class EdgeHit(val edge: Int, val t: Float, val distance: Float, val x: Float, val z: Float)

/** A door/window as a stretch [t0, t1] of outline edge [edge]; fractions survive anchor drift. */
data class CapturedOpening(val type: OpeningType, val edge: Int, val t0: Float, val t1: Float)

enum class OpeningAddResult { PENDING, ADDED, REJECTED_OTHER_WALL, REJECTED_TOO_NARROW, REJECTED_OVERLAP }

/**
 * Doors and windows marked after the outline is done: two taps on the floor
 * line under an opening's edges. Free of ARCore types so it runs on the JVM;
 * Dart maps each edge fraction onto the squared walls.
 */
class OpeningCapture(val snapM: Float = 0.30f, val minWidthM: Float = 0.30f) {

    var pending: EdgeHit? = null
        private set

    // Swapped whole: the GL thread writes, the UI thread may read.
    @Volatile var openings: List<CapturedOpening> = emptyList()
        private set

    /** The outline's corners; a closed one drops its closing tap (≈ the first corner). */
    fun loop(corners: List<Vec3>, closed: Boolean): List<Vec3> =
        if (closed && corners.size > 3) corners.dropLast(1) else corners

    fun snap(p: Vec3, loop: List<Vec3>): EdgeHit? {
        if (loop.size < 3) return null
        var best: EdgeHit? = null
        for (i in loop.indices) {
            val a = loop[i]
            val b = loop[(i + 1) % loop.size]
            val dx = b.x - a.x
            val dz = b.z - a.z
            val len2 = dx * dx + dz * dz
            val t = if (len2 < 1e-9f) 0f else (((p.x - a.x) * dx + (p.z - a.z) * dz) / len2).coerceIn(0f, 1f)
            val x = a.x + dx * t
            val z = a.z + dz * t
            val d = hypot(p.x - x, p.z - z)
            if (best == null || d < best.distance) best = EdgeHit(i, t, d, x, z)
        }
        return best?.takeIf { it.distance <= snapM }
    }

    fun addEdge(hit: EdgeHit, type: OpeningType, loop: List<Vec3>): OpeningAddResult {
        val first = pending ?: run {
            pending = hit
            return OpeningAddResult.PENDING
        }
        pending = null
        if (first.edge != hit.edge) return OpeningAddResult.REJECTED_OTHER_WALL
        val o = CapturedOpening(type, hit.edge, minOf(first.t, hit.t), maxOf(first.t, hit.t))
        if (widthM(o, loop) < minWidthM) return OpeningAddResult.REJECTED_TOO_NARROW
        if (openings.any { it.edge == o.edge && o.t0 < it.t1 && it.t0 < o.t1 }) return OpeningAddResult.REJECTED_OVERLAP
        openings = openings + o
        return OpeningAddResult.ADDED
    }

    /** Pending edge first, then the last opening; false when there is nothing to undo. */
    fun undo(): Boolean {
        if (pending != null) {
            pending = null
            return true
        }
        if (openings.isEmpty()) return false
        openings = openings.dropLast(1)
        return true
    }

    /** The outline changed under them (corners lost): start over. */
    fun clear() {
        pending = null
        openings = emptyList()
    }

    fun widthM(o: CapturedOpening, loop: List<Vec3>): Float {
        val a = loop[o.edge]
        val b = loop[(o.edge + 1) % loop.size]
        return (o.t1 - o.t0) * hypot(b.x - a.x, b.z - a.z)
    }
}
