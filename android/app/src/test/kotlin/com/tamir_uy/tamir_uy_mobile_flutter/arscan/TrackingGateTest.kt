package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import com.google.ar.core.TrackingFailureReason
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class TrackingGateTest {

    @Test fun `not steady while not tracking`() {
        val g = TrackingGate()
        g.update(tracking = false, nowMs = 0)
        assertFalse(g.steady(0))
    }

    @Test fun `settles for a while after tracking comes back`() {
        val g = TrackingGate()
        g.update(true, 0); g.update(true, 5_000)
        assertTrue(g.steady(5_000))
        g.update(false, 6_000)
        g.update(true, 7_000)
        assertTrue(g.settling(7_000 + TrackingGate.SETTLE_MS - 1))
        assertFalse(g.steady(7_000 + TrackingGate.SETTLE_MS - 1))
        g.update(true, 7_000 + TrackingGate.SETTLE_MS)
        assertTrue(g.steady(7_000 + TrackingGate.SETTLE_MS))
        assertFalse(g.settling(7_000 + TrackingGate.SETTLE_MS))
    }

    @Test fun `each failure reason has its own hint`() {
        assertEquals("arScanLostMotion", TrackingGate.hintKey(TrackingFailureReason.EXCESSIVE_MOTION))
        assertEquals("arScanLostLight", TrackingGate.hintKey(TrackingFailureReason.INSUFFICIENT_LIGHT))
        assertEquals("arScanLostFeatures", TrackingGate.hintKey(TrackingFailureReason.INSUFFICIENT_FEATURES))
        assertEquals("arScanTrackingLost", TrackingGate.hintKey(TrackingFailureReason.BAD_STATE))
        assertEquals("arScanTrackingLost", TrackingGate.hintKey(null))
    }
}
