package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DwellDetectorTest {

    private fun p(x: Float, z: Float = 0f) = Vec3(x, 0f, z)

    @Test fun `holding still for a second fires once`() {
        val d = DwellDetector()
        assertFalse(d.update(p(0f), 0).fired)
        assertEquals(0.5f, d.update(p(0f), 500).progress, 0.01f)
        assertTrue(d.update(p(0f), 1000).fired)
        assertFalse(d.update(p(0f), 1100).fired)
    }

    @Test fun `jitter above 3 cm restarts`() {
        val d = DwellDetector()
        d.update(p(0f), 0)
        d.update(p(0.04f), 600)
        assertFalse(d.update(p(0.04f), 1000).fired)
        assertTrue(d.update(p(0.04f), 1600).fired)
    }

    @Test fun `holding still after firing does not fire again`() {
        val d = DwellDetector()
        d.update(p(0f), 0)
        assertTrue(d.update(p(0f), 1000).fired)
        var t = 1100L
        while (t <= 5000L) {
            val r = d.update(p(0f), t)
            assertFalse(r.fired)
            assertEquals(0f, r.progress, 0f)
            t += 100
        }
    }

    @Test fun `moving 15 cm re-arms`() {
        val d = DwellDetector()
        d.update(p(0f), 0)
        assertTrue(d.update(p(0f), 1000).fired)
        d.update(p(0.16f), 1200)
        assertFalse(d.update(p(0.16f), 2100).fired)
        assertTrue(d.update(p(0.16f), 2200).fired)
    }

    @Test fun `losing the target resets progress`() {
        val d = DwellDetector()
        d.update(p(0f), 0)
        assertEquals(0f, d.update(null, 500).progress, 0f)
        d.update(p(0f), 600)
        assertFalse(d.update(p(0f), 1500).fired)
        assertTrue(d.update(p(0f), 1600).fired)
    }

    @Test fun `clearing progress keeps the fire-once rule`() {
        val d = DwellDetector()
        d.update(p(0f), 0)
        assertTrue(d.update(p(0f), 1000).fired)
        d.clearProgress()
        var t = 1100L
        while (t <= 4000L) {
            assertFalse(d.update(p(0f), t).fired)
            t += 100
        }
    }
}
