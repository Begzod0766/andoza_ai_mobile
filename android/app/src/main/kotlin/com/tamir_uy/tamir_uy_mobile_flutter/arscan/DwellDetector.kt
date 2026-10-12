package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.hypot

/** [progress] 0–1 fills the ring around the target; [fired] is true on the one frame a corner should be added. */
data class Dwell(val progress: Float, val fired: Boolean)

/**
 * "Hold the target still to add a corner": fires once the floor point under
 * the target has stayed within [radiusM] for [holdMs], then waits until the
 * target has moved [rearmM] away before it can fire again — so standing still
 * on a corner adds it once, not every second. Distances are on the floor (XZ).
 */
class DwellDetector(
    private val holdMs: Long = 1000L,
    private val radiusM: Float = 0.03f,
    private val rearmM: Float = 0.15f,
) {
    private var anchor: Vec3? = null
    private var startMs = 0L
    private var firedAt: Vec3? = null

    fun update(p: Vec3?, nowMs: Long): Dwell {
        if (p == null) {
            anchor = null
            return IDLE
        }
        val last = firedAt
        if (last != null) {
            if (dist(p, last) <= rearmM) return IDLE
            firedAt = null
        }
        val a = anchor
        if (a == null || dist(p, a) > radiusM) {
            anchor = p
            startMs = nowMs
            return IDLE
        }
        val progress = ((nowMs - startMs).toFloat() / holdMs).coerceIn(0f, 1f)
        if (progress < 1f) return Dwell(progress, fired = false)
        firedAt = a
        anchor = null
        return Dwell(1f, fired = true)
    }

    /** Start the hold over (target lost, a corner went in elsewhere) — but still don't fire again where it last fired. */
    fun clearProgress() {
        anchor = null
    }

    private fun dist(a: Vec3, b: Vec3) = hypot(a.x - b.x, a.z - b.z)

    private companion object {
        val IDLE = Dwell(0f, fired = false)
    }
}
