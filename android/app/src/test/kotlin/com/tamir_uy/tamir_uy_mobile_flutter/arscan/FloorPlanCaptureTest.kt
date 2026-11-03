package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class FloorPlanCaptureTest {

    private fun square(c: FloorPlanCapture) {
        c.addCorner(Vec3(0f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 3f))
        c.addCorner(Vec3(0f, 0f, 3f))
    }

    @Test fun `adds corners on the floor height`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, -1.2f, 0f))
        c.addCorner(Vec3(4f, -1.15f, 0f))
        assertEquals(-1.2f, c.floorY!!, 1e-6f)
        assertEquals(-1.2f, c.corners[1].y, 1e-6f)
    }

    @Test fun `snaps to the first corner when the aim is near it`() {
        val c = FloorPlanCapture()
        square(c)
        assertTrue(c.wouldSnap(Vec3(0.15f, 0f, 0.1f)))
        assertEquals(AddResult.CLOSED, c.addCorner(Vec3(0.15f, 0f, 0.1f)))
        assertTrue(c.isClosed)
        assertEquals(5, c.corners.size)
        assertEquals(0.15f, c.corners.last().x, 1e-6f)
    }

    @Test fun `does not snap before three corners`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(c.wouldSnap(Vec3(0.05f, 0f, 0.05f)))
        assertEquals(AddResult.ADDED, c.addCorner(Vec3(0.05f, 0f, 0.05f)))
        assertFalse(c.isClosed)
    }

    @Test fun `undo removes the last corner and reopens`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        assertTrue(c.undo())
        assertFalse(c.isClosed)
        assertEquals(4, c.corners.size)
    }

    @Test fun `reopening a closed outline drops the snapping tap in one step`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        assertTrue(c.reopen())
        assertFalse(c.isClosed)
        assertEquals(4, c.corners.size)
        assertTrue(c.canAddCorner(tracking = true))
        assertEquals(AddResult.ADDED, c.addCorner(Vec3(-1f, 0f, 1.5f)))
    }

    @Test fun `reopening an open outline changes nothing`() {
        val c = FloorPlanCapture()
        square(c)
        assertFalse(c.reopen())
        assertEquals(4, c.corners.size)
    }

    @Test fun `adding to a closed outline is rejected as closed, not as lost tracking`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        assertEquals(AddResult.REJECTED_CLOSED, c.addCorner(Vec3(2f, 0f, 2f)))
        assertEquals(5, c.corners.size)
    }

    @Test fun `blocks adding while not tracking`() {
        val c = FloorPlanCapture()
        assertFalse(c.canAddCorner(tracking = false))
        assertTrue(c.canAddCorner(tracking = true))
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        assertFalse(c.canAddCorner(tracking = true))
    }

    @Test fun `a lost corner drops it and everything after it so re-marking stays in order`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        val lost = c.updatePositions(listOf(Vec3(0f, 0f, 0f), null, Vec3(4f, 0f, 3f), Vec3(0f, 0f, 3f), Vec3(0.1f, 0f, 0.1f)))
        assertEquals(4, lost)
        assertEquals(1, c.corners.size)
        assertFalse(c.isClosed)
        assertEquals(0, c.updatePositions(listOf(Vec3(0f, 0f, 0f))))
    }

    @Test fun `reading the result while frames refresh the corners never breaks`() {
        val c = FloorPlanCapture()
        square(c)
        val positions = c.corners
        var failure: Throwable? = null
        val writer = Thread {
            repeat(200_000) { c.updatePositions(positions) }
        }
        writer.start()
        try {
            while (writer.isAlive) {
                @Suppress("UNCHECKED_CAST")
                val corners = c.toResult(2.7f, true, 1)["corners"] as List<List<Double>>
                assertEquals(4, corners.size)
            }
        } catch (t: Throwable) {
            failure = t
        }
        writer.join()
        assertNull(failure)
    }

    @Test fun `measures height along the vertical axis`() {
        val c = FloorPlanCapture()
        square(c)
        val origin = Vec3(2f, 1.5f, 2f)
        val target = Vec3(0f, 2.7f, 0f)
        val dir = Vec3(target.x - origin.x, target.y - origin.y, target.z - origin.z)
        assertEquals(2.7f, c.heightFromRay(origin, dir)!!, 0.01f)
    }

    @Test fun `rejects heights outside 1_8 to 4_5 m`() {
        val c = FloorPlanCapture()
        square(c)
        val origin = Vec3(2f, 1.5f, 2f)
        assertNull(c.heightFromRay(origin, Vec3(-2f, -0.3f, -2f)))  // aims at 1.2 m
        assertNull(c.heightFromRay(origin, Vec3(-2f, 4f, -2f)))     // aims at 5.5 m
    }

    @Test fun `serializes the channel payload`() {
        val c = FloorPlanCapture()
        square(c)
        c.trackingLossCount = 2
        val m = c.toResult(height = 2.74f, heightMeasured = true, durationSec = 95)
        @Suppress("UNCHECKED_CAST")
        val corners = m["corners"] as List<List<Double>>
        assertEquals(listOf(4.0, 3.0), corners[2])
        assertEquals(2.74, m["height"] as Double, 1e-6)
        assertEquals(true, m["heightMeasured"])
        assertEquals(false, m["closed"])
        assertEquals(2, m["trackingLossCount"])
        assertEquals(95, m["durationSec"])
    }

    @Test fun `close appends a copy of the first corner`() {
        val c = FloorPlanCapture(); square(c)
        assertTrue(c.close())
        assertTrue(c.isClosed)
        assertEquals(5, c.corners.size)
        assertEquals(c.corners[0], c.corners[4])
        assertFalse(c.close())
    }

    @Test fun `close needs three corners`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(c.close()); assertFalse(c.isClosed)
    }

    @Test fun `reopen after close drops the copy`() {
        val c = FloorPlanCapture(); square(c); c.close()
        assertTrue(c.reopen()); assertEquals(4, c.corners.size); assertFalse(c.isClosed)
    }

    @Test fun `summary of a 4 by 3 room at 2_5 m`() {
        val c = FloorPlanCapture(); square(c); c.close()
        val s = c.summary(2.5f)
        assertEquals(14f, s.perimeterM, 1e-4f)
        assertEquals(12f, s.areaM2, 1e-4f)
        assertEquals(30f, s.volumeM3, 1e-4f)
    }

    @Test fun `rejects a corner within 5 cm of the last`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 0f))
        assertEquals(AddResult.REJECTED_DUPLICATE, c.addCorner(Vec3(4.03f, 0f, 0.02f)))
        assertEquals(2, c.corners.size)
    }

    @Test fun `the channel payload carries the openings`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 0f)); c.addCorner(Vec3(4f, 0f, 3f))
        val m = c.toResult(2.7f, true, 1, listOf(CapturedOpening(OpeningType.WINDOW, 2, 0.25f, 0.5f)))
        assertEquals(listOf(mapOf("type" to "window", "edge" to 2, "t0" to 0.25, "t1" to 0.5)), m["openings"])
        assertEquals(emptyList<Any>(), c.toResult(2.7f, true, 1)["openings"])
    }

    @Test fun `the floor follows the first corner's anchor when the map shifts`() {
        val c = FloorPlanCapture()
        square(c)
        // ARCore relocalised: every anchor moved 0.6 m down.
        c.updatePositions(c.corners.map { Vec3(it.x, it.y - 0.6f, it.z) })
        assertEquals(-0.6f, c.floorY!!, 1e-6f)
        assertTrue(c.corners.all { kotlin.math.abs(it.y + 0.6f) < 1e-6f })
    }

    @Test fun `the ceiling is measured from the shifted floor`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        c.updatePositions(listOf(Vec3(0f, -1f, 0f)))
        // Camera 1.4 m above the moved floor, 1 m from the axis, looking up at 45°: ceiling at 2.4 m.
        val h = c.heightFromRay(Vec3(1f, 0.4f, 0f), Vec3(-1f, 1f, 0f))!!
        assertEquals(2.4f, h, 1e-4f)
    }

    @Test fun `snaps to the first corner within 35 cm, not beyond`() {
        val c = FloorPlanCapture()
        square(c)
        assertTrue(c.wouldSnap(Vec3(0.3f, 0f, 0.1f)))
        assertFalse(c.wouldSnap(Vec3(0.4f, 0f, 0f)))
    }
}
