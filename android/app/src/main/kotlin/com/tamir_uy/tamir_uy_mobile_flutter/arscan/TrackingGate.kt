package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import com.google.ar.core.TrackingFailureReason

/**
 * When ARCore comes back after losing tracking it often starts a new map and
 * only later aligns it with the old one, so the first second's poses can be
 * off by a metre. Nothing is marked until tracking has held for [SETTLE_MS].
 */
class TrackingGate {
    private var tracking = false
    private var since = 0L

    fun update(tracking: Boolean, nowMs: Long) {
        if (tracking && !this.tracking) since = nowMs
        this.tracking = tracking
    }

    fun steady(nowMs: Long): Boolean = tracking && nowMs - since >= SETTLE_MS
    fun settling(nowMs: Long): Boolean = tracking && !steady(nowMs)

    companion object {
        const val SETTLE_MS = 1_500L

        /** The hint while tracking is lost, by ARCore's reason. */
        fun hintKey(reason: TrackingFailureReason?): String = when (reason) {
            TrackingFailureReason.EXCESSIVE_MOTION -> "arScanLostMotion"
            TrackingFailureReason.INSUFFICIENT_LIGHT -> "arScanLostLight"
            TrackingFailureReason.INSUFFICIENT_FEATURES -> "arScanLostFeatures"
            else -> "arScanTrackingLost"
        }
    }
}
