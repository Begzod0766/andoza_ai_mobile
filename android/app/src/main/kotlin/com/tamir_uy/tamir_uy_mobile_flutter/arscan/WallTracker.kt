package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.PI
import kotlin.math.abs
import kotlin.math.acos
import kotlin.math.hypot
import kotlin.math.min

/** One ARCore vertical plane seen as a floor-level segment: centre, unit direction, half its length (metres, XZ). */
data class WallObs(val id: Int, val cx: Float, val cz: Float, val dx: Float, val dz: Float, val halfLength: Float)

/** A wall on the floor plan; [key] is the smallest [WallObs.id] merged into it, so it survives new pieces. */
data class WallSegment(val key: Int, val ax: Float, val az: Float, val bx: Float, val bz: Float) {
    val length: Float get() = hypot(bx - ax, bz - az)
}

/** Where two walls meet. [stable] once it has stood still long enough to be taken as a corner. */
data class CornerCandidate(
    val key: Long,
    val x: Float,
    val z: Float,
    val stable: Boolean,
    val wallA: WallSegment,
    val wallB: WallSegment,
)

data class WallFrame(val walls: List<WallSegment>, val candidates: List<CornerCandidate>)

/**
 * A vertical plane's world polygon → its floor segment. The wall runs across
 * the plane's horizontal normal; the polygon's extent along it is the length.
 * `null` if the plane isn't upright (|normal.y| > 0.3) or has < 2 points.
 */
fun wallObsFrom(id: Int, center: Vec3, normal: Vec3, polygonWorld: List<Vec3>): WallObs? {
    if (polygonWorld.size < 2 || abs(normal.y) > 0.3f) return null
    val nl = hypot(normal.x, normal.z)
    if (nl < 1e-6f) return null
    val dx = -normal.z / nl
    val dz = normal.x / nl
    val ts = polygonWorld.map { (it.x - center.x) * dx + (it.z - center.z) * dz }
    val lo = ts.min()
    val hi = ts.max()
    val mid = (lo + hi) / 2
    return WallObs(id, center.x + mid * dx, center.z + mid * dz, dx, dz, (hi - lo) / 2)
}

/**
 * Turns the vertical planes ARCore reports each frame into walls and the
 * corners where they meet, remembering how long each corner has held still.
 * Free of ARCore types so it runs in JVM tests; called on the GL thread only.
 */
class WallTracker(
    private val mergeAngleDeg: Float = 5f,
    private val mergeDistM: Float = 0.08f,
    // Pieces further apart along the line are separate walls (a doorway, a notch).
    private val mergeGapM: Float = 0.6f,
    private val minCornerAngleDeg: Float = 30f,
    private val maxEndGapM: Float = 0.5f,
    private val stableMs: Long = 1000L,
    private val stableMoveM: Float = 0.05f,
    private val minWallM: Float = 0.5f,
) {
    private class Track(val x: Float, val z: Float, val sinceMs: Long)

    private val tracks = HashMap<Long, Track>()

    fun update(walls: List<WallObs>, nowMs: Long): WallFrame {
        val segments = merge(walls)
        val candidates = mutableListOf<CornerCandidate>()
        val seen = HashSet<Long>()
        for (i in segments.indices) for (j in i + 1 until segments.size) {
            val a = segments[i]
            val b = segments[j]
            val p = intersect(a, b) ?: continue
            if (endGap(a, p.first, p.second) > maxEndGapM || endGap(b, p.first, p.second) > maxEndGapM) continue
            val key = (min(a.key, b.key).toLong() shl 32) or maxOf(a.key, b.key).toLong()
            seen += key
            val old = tracks[key]
            val track = if (old == null || hypot(p.first - old.x, p.second - old.z) > stableMoveM) {
                Track(p.first, p.second, nowMs).also { tracks[key] = it }
            } else old
            val stable = nowMs - track.sinceMs >= stableMs && a.length >= minWallM && b.length >= minWallM
            candidates += CornerCandidate(key, p.first, p.second, stable, a, b)
        }
        tracks.keys.retainAll(seen)
        return WallFrame(segments, candidates)
    }

    /** Pieces of one wall (same direction, same line) become one segment on the longest piece's line. */
    private fun merge(walls: List<WallObs>): List<WallSegment> {
        class Cluster(val members: MutableList<WallObs>, var lo: Float, var hi: Float)
        val clusters = mutableListOf<Cluster>()
        for (w in walls.sortedByDescending { it.halfLength }) {
            var at = 0f
            val home = clusters.firstOrNull { c ->
                val l = c.members[0]
                at = (w.cx - l.cx) * l.dx + (w.cz - l.cz) * l.dz
                val gap = maxOf(c.lo - (at + w.halfLength), (at - w.halfLength) - c.hi, 0f)
                angleDeg(l.dx, l.dz, w.dx, w.dz) <= mergeAngleDeg &&
                    abs((w.cx - l.cx) * -l.dz + (w.cz - l.cz) * l.dx) <= mergeDistM &&
                    gap <= mergeGapM
            }
            if (home != null) {
                home.members += w
                home.lo = minOf(home.lo, at - w.halfLength)
                home.hi = maxOf(home.hi, at + w.halfLength)
            } else {
                clusters += Cluster(mutableListOf(w), -w.halfLength, w.halfLength)
            }
        }
        return clusters.map { cluster ->
            val c = cluster.members
            val l = c[0]
            var lo = Float.MAX_VALUE
            var hi = -Float.MAX_VALUE
            for (w in c) for (s in floatArrayOf(-w.halfLength, w.halfLength)) {
                val t = (w.cx + s * w.dx - l.cx) * l.dx + (w.cz + s * w.dz - l.cz) * l.dz
                if (t < lo) lo = t
                if (t > hi) hi = t
            }
            WallSegment(
                key = c.minOf { it.id },
                ax = l.cx + lo * l.dx, az = l.cz + lo * l.dz,
                bx = l.cx + hi * l.dx, bz = l.cz + hi * l.dz,
            )
        }
    }

    /** Where the two walls' lines cross, or null when they meet at less than [minCornerAngleDeg]. */
    private fun intersect(a: WallSegment, b: WallSegment): Pair<Float, Float>? {
        val ax = (a.bx - a.ax) / a.length
        val az = (a.bz - a.az) / a.length
        val bx = (b.bx - b.ax) / b.length
        val bz = (b.bz - b.az) / b.length
        if (a.length < 1e-6f || b.length < 1e-6f) return null
        if (angleDeg(ax, az, bx, bz) < minCornerAngleDeg) return null
        val cross = ax * bz - az * bx
        val t = ((b.ax - a.ax) * bz - (b.az - a.az) * bx) / cross
        return Pair(a.ax + t * ax, a.az + t * az)
    }

    private fun endGap(s: WallSegment, x: Float, z: Float): Float =
        min(hypot(x - s.ax, z - s.az), hypot(x - s.bx, z - s.bz))

    /** Angle between two undirected lines, 0–90°. */
    private fun angleDeg(ax: Float, az: Float, bx: Float, bz: Float): Float {
        val dot = abs(ax * bx + az * bz).coerceAtMost(1f)
        return (acos(dot) * 180.0 / PI).toFloat()
    }
}
