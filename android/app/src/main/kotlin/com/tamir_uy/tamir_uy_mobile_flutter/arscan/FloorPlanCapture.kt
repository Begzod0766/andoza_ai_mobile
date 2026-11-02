package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.abs
import kotlin.math.hypot

/** A world-space point in metres (ARCore pose translation). */
data class Vec3(val x: Float, val y: Float, val z: Float)

/** [REJECTED_CLOSED]: the outline is already closed — reopen it first. */
enum class AddResult { ADDED, CLOSED, REJECTED_CLOSED }

/**
 * The floor outline being captured, kept free of ARCore types so it can be
 * unit-tested on the JVM. The activity feeds it hit-test points and, every
 * frame, the anchors' refreshed positions; it decides snapping/closing and the
 * ceiling height. All cleaning-up (squaring, merging) happens in Dart.
 */
class FloorPlanCapture(val snapDistanceM: Float = 0.20f) {

    // Swapped whole, never mutated in place: the GL thread refreshes it every
    // frame while the UI thread may read it (a tap on "Tasdiqlash").
    @Volatile private var points: List<Vec3> = emptyList()

    // Parallel to [points]: whether that corner was taken on its own from a
    // wall corner (not by the user). Only the GL thread reads it.
    private var autoFlags: List<Boolean> = emptyList()

    // Where the user undid an auto corner: never auto-added there again
    // (they can still snap or hold there on purpose).
    private var rejected: List<Vec3> = emptyList()

    // After "back" from the height step: don't close the outline again on our
    // own (it would bounce straight back) until the user adds a corner.
    private var autoCloseBlocked = false

    /** Height of the floor plane — the first corner's Y; later corners are pinned to it. */
    @Volatile var floorY: Float? = null
        private set

    val corners: List<Vec3> get() = points

    /**
     * True once the user snapped back onto the first corner. The last point is
     * then the snapping tap itself (the loop's closure error), not a corner.
     */
    @Volatile var isClosed: Boolean = false
        private set

    var trackingLossCount: Int = 0

    fun canAddCorner(tracking: Boolean): Boolean = tracking && !isClosed

    fun wouldSnap(p: Vec3): Boolean =
        !isClosed && points.size >= 3 &&
            hypot(p.x - points[0].x, p.z - points[0].z) <= snapDistanceM

    fun addCorner(p: Vec3, auto: Boolean = false): AddResult {
        if (isClosed) return AddResult.REJECTED_CLOSED
        autoCloseBlocked = false
        val y = floorY ?: p.y.also { floorY = it }
        val snap = wouldSnap(p)
        points = points + Vec3(p.x, y, p.z)
        autoFlags = autoFlags + auto
        if (snap) {
            isClosed = true
            return AddResult.CLOSED
        }
        return AddResult.ADDED
    }

    fun undo(): Boolean {
        if (points.isEmpty()) return false
        if (autoFlags.lastOrNull() == true) rejected = rejected + points.last()
        points = points.dropLast(1)
        autoFlags = autoFlags.dropLast(1)
        isClosed = false
        if (points.isEmpty()) floorY = null
        return true
    }

    /**
     * Back from the height step to corners: drop the snapping tap so the
     * outline is open again and the next "add corner" works at once.
     * Returns false (and changes nothing) if the outline wasn't closed.
     */
    fun reopen(): Boolean {
        if (!isClosed) return false
        points = points.dropLast(1)
        autoFlags = autoFlags.dropLast(1)
        autoCloseBlocked = true
        isClosed = false
        return true
    }

    /**
     * Refresh corners from their anchors (ARCore improves its map as the user
     * walks). `null` = that anchor stopped tracking: it and every corner after
     * it are dropped, so re-marking continues the outline in order. Returns how
     * many corners were dropped (the caller drops the same anchors).
     */
    fun updatePositions(positions: List<Vec3?>): Int {
        val current = points
        if (positions.size != current.size) return 0
        val y = floorY ?: return 0
        val firstLost = positions.indexOfFirst { it == null }
        val keep = if (firstLost < 0) positions.size else firstLost
        points = positions.take(keep).map { Vec3(it!!.x, y, it.z) }
        autoFlags = autoFlags.take(keep)
        val lost = current.size - keep
        if (lost > 0) isClosed = false
        return lost
    }

    /**
     * Ceiling height where the camera ray passes closest to the vertical axis
     * standing on the first corner. `null` if the ray runs parallel to the
     * axis, points away from it, or lands outside 1.8–4.5 m.
     */
    fun heightFromRay(origin: Vec3, dir: Vec3): Float? {
        val base = points.firstOrNull() ?: return null
        val floor = floorY ?: return null
        // Axis: base + t·(0,1,0). Ray: origin + s·dir. Closest points between two lines.
        val w0x = base.x - origin.x
        val w0y = floor - origin.y
        val w0z = base.z - origin.z
        val b = dir.y
        val c = dir.x * dir.x + dir.y * dir.y + dir.z * dir.z
        val d = w0y
        val e = dir.x * w0x + dir.y * w0y + dir.z * w0z
        val denom = c - b * b
        if (abs(denom) < 1e-6f) return null
        val t = (b * e - c * d) / denom
        val s = (e - b * d) / denom
        if (s <= 0f) return null
        return t.takeIf { it in MIN_HEIGHT_M..MAX_HEIGHT_M }
    }

    /**
     * Whether a wall corner may be added without the user doing anything:
     * the outline is open, it isn't a spot the user undid, it isn't an
     * existing corner (the first one only once it would close the outline,
     * and not right after "back" from the height step), and it continues the
     * outline — the last corner lies on one of its walls.
     */
    fun acceptsAuto(c: CornerCandidate): Boolean {
        if (isClosed) return false
        if (rejected.any { hypot(it.x - c.x, it.z - c.z) <= REJECT_RADIUS_M }) return false
        if (!isNewSpot(c.x, c.z)) return false
        val current = points
        val closing = current.isNotEmpty() && hypot(current[0].x - c.x, current[0].z - c.z) <= snapDistanceM
        if (closing && autoCloseBlocked) return false
        val last = current.lastOrNull() ?: return true
        return lineDistance(last, c.wallA) <= ON_WALL_M || lineDistance(last, c.wallB) <= ON_WALL_M
    }

    /**
     * False on top of a placed corner — snapping or holding there would add a
     * zero-length wall — except the first corner once there are 3 (that closes).
     */
    fun isNewSpot(x: Float, z: Float): Boolean {
        val current = points
        current.forEachIndexed { i, p ->
            if (hypot(p.x - x, p.z - z) <= snapDistanceM) return i == 0 && current.size >= 3 && !isClosed
        }
        return true
    }

    private fun lineDistance(p: Vec3, w: WallSegment): Float {
        val len = w.length
        if (len < 1e-6f) return hypot(p.x - w.ax, p.z - w.az)
        return abs((p.x - w.ax) * (w.bz - w.az) - (p.z - w.az) * (w.bx - w.ax)) / len
    }

    fun toResult(
        height: Float,
        heightMeasured: Boolean,
        durationSec: Int,
        openings: List<CapturedOpening> = emptyList(),
    ): Map<String, Any> = mapOf(
        "corners" to points.map { listOf(it.x.toDouble(), it.z.toDouble()) },
        "height" to height.toDouble(),
        "heightMeasured" to heightMeasured,
        "closed" to isClosed,
        "trackingLossCount" to trackingLossCount,
        "durationSec" to durationSec,
        "openings" to openings.map {
            mapOf("type" to it.type.wire, "edge" to it.edge, "t0" to it.t0.toDouble(), "t1" to it.t1.toDouble())
        },
    )

    companion object {
        const val MIN_HEIGHT_M = 1.8f
        const val ON_WALL_M = 0.15f
        const val REJECT_RADIUS_M = 0.20f
        const val MAX_HEIGHT_M = 4.5f
    }
}
