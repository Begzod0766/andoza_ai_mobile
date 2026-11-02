package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class OpeningCaptureTest {

    // 4 × 3 m room; edge 0 = (0,0)→(4,0), edge 3 = (0,3)→(0,0).
    private val square = listOf(Vec3(0f, 0f, 0f), Vec3(4f, 0f, 0f), Vec3(4f, 0f, 3f), Vec3(0f, 0f, 3f))
    private val c = OpeningCapture()
    private val loop = c.loop(square, closed = false)

    private fun hit(edge: Int, t: Float) = EdgeHit(edge, t, 0f, 0f, 0f)

    @Test fun `snaps to the nearest edge within 30 cm`() {
        val h = c.snap(Vec3(2f, 0f, 0.25f), loop)!!
        assertEquals(0, h.edge)
        assertEquals(0.5f, h.t, 1e-6f)
        assertEquals(2f, h.x, 1e-6f)
        assertEquals(0f, h.z, 1e-6f)
        assertNull(c.snap(Vec3(2f, 0f, 0.35f), loop))
    }

    @Test fun `clamps t at the corners`() {
        // Past a corner both edges meet at that corner: t is 0 or 1, never outside.
        val h = c.snap(Vec3(-0.1f, 0f, -0.1f), loop)!!
        assertTrue(h.t == 0f || h.t == 1f)
        assertEquals(0f, h.x, 1e-6f)
        assertEquals(0f, h.z, 1e-6f)
    }

    @Test fun `two edges make a sorted opening`() {
        assertEquals(OpeningAddResult.PENDING, c.addEdge(hit(0, 0.5f), OpeningType.DOOR, loop))
        assertEquals(0.5f, c.pending!!.t, 1e-6f)
        assertEquals(OpeningAddResult.ADDED, c.addEdge(hit(0, 0.25f), OpeningType.DOOR, loop))
        assertNull(c.pending)
        assertEquals(CapturedOpening(OpeningType.DOOR, 0, 0.25f, 0.5f), c.openings.single())
        assertEquals(1.0f, c.widthM(c.openings[0], loop), 1e-5f)
    }

    @Test fun `rejects edges on two walls`() {
        c.addEdge(hit(0, 0.5f), OpeningType.DOOR, loop)
        assertEquals(OpeningAddResult.REJECTED_OTHER_WALL, c.addEdge(hit(1, 0.5f), OpeningType.DOOR, loop))
        assertNull(c.pending)
        assertTrue(c.openings.isEmpty())
    }

    @Test fun `rejects a too narrow opening`() {
        c.addEdge(hit(0, 0.50f), OpeningType.WINDOW, loop)
        assertEquals(OpeningAddResult.REJECTED_TOO_NARROW, c.addEdge(hit(0, 0.57f), OpeningType.WINDOW, loop))
        assertNull(c.pending)
        assertTrue(c.openings.isEmpty())
    }

    @Test fun `rejects an overlap but allows touching`() {
        c.addEdge(hit(0, 0.25f), OpeningType.DOOR, loop)
        c.addEdge(hit(0, 0.5f), OpeningType.DOOR, loop)
        c.addEdge(hit(0, 0.4f), OpeningType.WINDOW, loop)
        assertEquals(OpeningAddResult.REJECTED_OVERLAP, c.addEdge(hit(0, 0.7f), OpeningType.WINDOW, loop))
        c.addEdge(hit(0, 0.5f), OpeningType.WINDOW, loop)
        assertEquals(OpeningAddResult.ADDED, c.addEdge(hit(0, 0.7f), OpeningType.WINDOW, loop))
        assertEquals(2, c.openings.size)
    }

    @Test fun `closed loop drops the closing tap`() {
        val closed = c.loop(square + Vec3(0.05f, 0f, 0.02f), closed = true)
        assertEquals(4, closed.size)
        val h = c.snap(Vec3(0.1f, 0f, 1.5f), closed)!!
        assertEquals(3, h.edge)
        assertEquals(0.5f, h.t, 1e-6f)
    }

    @Test fun `open loop wraps the last edge`() {
        val h = c.snap(Vec3(0.1f, 0f, 1.5f), loop)!!
        assertEquals(3, h.edge)
        assertEquals(0.5f, h.t, 1e-6f)
    }

    @Test fun `undo removes the pending edge, then the last opening`() {
        c.addEdge(hit(0, 0.1f), OpeningType.DOOR, loop)
        c.addEdge(hit(0, 0.4f), OpeningType.DOOR, loop)
        c.addEdge(hit(1, 0.2f), OpeningType.WINDOW, loop)
        assertTrue(c.undo())
        assertNull(c.pending)
        assertEquals(1, c.openings.size)
        assertTrue(c.undo())
        assertTrue(c.openings.isEmpty())
        assertFalse(c.undo())
    }
}
