package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.abs
import kotlin.math.sqrt

/**
 * Where the aim lands on the floor. ARCore's plane hits stop at the edge of
 * the detected patch, which rarely reaches the walls or the space behind
 * furniture; the camera ray against the infinite plane `y = floorY` does.
 */
object FloorRay {
    const val MAX_DISTANCE_M = 8f
    const val PLANE_TOLERANCE_M = 0.25f

    /** The ray `origin + s·dir` on `y = floorY`; `null` if it doesn't point down or lands too far. */
    fun hit(origin: Vec3, dir: Vec3, floorY: Float): Vec3? {
        if (dir.y >= -1e-4f) return null
        val s = (floorY - origin.y) / dir.y
        if (s <= 0f) return null
        val dx = dir.x * s; val dy = dir.y * s; val dz = dir.z * s
        if (sqrt(dx * dx + dy * dy + dz * dz) > MAX_DISTANCE_M) return null
        return Vec3(origin.x + dx, floorY, origin.z + dz)
    }

    /**
     * A real floor hit when there is one at the floor's height (a table top
     * doesn't count), else the ray. The result sits exactly on [floorY].
     * Before the floor is known, the plane hit as is.
     */
    fun pick(planeHit: Vec3?, rayHit: Vec3?, floorY: Float?): Vec3? {
        if (floorY == null) return planeHit
        if (planeHit != null && abs(planeHit.y - floorY) < PLANE_TOLERANCE_M) return Vec3(planeHit.x, floorY, planeHit.z)
        return rayHit
    }
}
