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

    @Test fun `snaps to the first corner within 20 cm`() {
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
        assertEquals(emptyList<Any>(), m["openings"])
    }

    @Test fun `serializes openings into the channel payload`() {
        val c = FloorPlanCapture()
        square(c)
        val m = c.toResult(2.7f, true, 1, listOf(CapturedOpening(OpeningType.WINDOW, 2, 0.25f, 0.5f)))
        assertEquals(
            listOf(mapOf("type" to "window", "edge" to 2, "t0" to 0.25, "t1" to 0.5)),
            m["openings"],
        )
    }

    // ── auto corners ───────────────────────────────────────────────────────
    private fun seg(ax: Float, az: Float, bx: Float, bz: Float) = WallSegment(0, ax, az, bx, bz)

    private fun cand(x: Float, z: Float, a: WallSegment, b: WallSegment = seg(x, z, x, z + 1f)) =
        CornerCandidate(0L, x, z, stable = true, wallA = a, wallB = b)

    @Test fun `first auto corner is accepted`() {
        assertTrue(FloorPlanCapture().acceptsAuto(cand(1f, 1f, seg(0f, 1f, 4f, 1f))))
    }

    @Test fun `auto corner must share a wall with the last corner`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        assertTrue(c.acceptsAuto(cand(4f, 0f, seg(0f, 0f, 4f, 0f), seg(4f, 0f, 4f, 3f))))
        assertFalse(c.acceptsAuto(cand(4f, 3f, seg(4f, 0f, 4f, 3f), seg(4f, 3f, 0f, 3f))))
    }

    @Test fun `a candidate on an existing corner is not added again`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(c.acceptsAuto(cand(4.05f, 0f, seg(0f, 0f, 4f, 0f), seg(4f, 0f, 4f, 3f))))
    }

    @Test fun `a candidate on the first corner closes once there are three corners`() {
        val two = FloorPlanCapture()
        two.addCorner(Vec3(0f, 0f, 0f))
        two.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(two.acceptsAuto(cand(0.05f, 0f, seg(4f, 0f, 0f, 0f), seg(0f, 3f, 0f, 0f))))

        val c = FloorPlanCapture()
        square(c)
        assertTrue(c.acceptsAuto(cand(0.05f, 0f, seg(0f, 3f, 0f, 0f), seg(0f, 0f, 4f, 0f))))
    }

    @Test fun `undoing an auto corner rejects that spot for auto only`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f), auto = true)
        assertTrue(c.undo())
        assertFalse(c.acceptsAuto(cand(0.1f, 0f, seg(0f, 0f, 4f, 0f))))
        assertEquals(AddResult.ADDED, c.addCorner(Vec3(0.1f, 0f, 0f), auto = false))
    }

    @Test fun `undoing a manual corner rejects nothing`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        assertTrue(c.undo())
        assertTrue(c.acceptsAuto(cand(0f, 0f, seg(0f, 0f, 4f, 0f))))
    }

    @Test fun `closed outline accepts nothing`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.1f, 0f, 0.1f))
        assertTrue(c.isClosed)
        assertFalse(c.acceptsAuto(cand(2f, 2f, seg(0f, 2f, 4f, 2f))))
    }

    @Test fun `going back from the height step does not close again on its own`() {
        val c = FloorPlanCapture()
        square(c)
        c.addCorner(Vec3(0.05f, 0f, 0f), auto = true)
        assertTrue(c.isClosed)
        assertTrue(c.reopen())
        assertFalse(c.acceptsAuto(cand(0.05f, 0f, seg(0f, 3f, 0f, 0f), seg(0f, 0f, 4f, 0f))))
    }

    @Test fun `the outline only closes from a corner on one of the closing walls`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 3f))
        // The first corner's walls are z=0 and x=0; the last corner (4,3) is on neither.
        assertFalse(c.acceptsAuto(cand(0f, 0f, seg(0f, 0f, 4f, 0f), seg(0f, 3f, 0f, 0f))))
    }

    @Test fun `a placed corner is not a new spot, the first one is once it would close`() {
        val c = FloorPlanCapture()
        c.addCorner(Vec3(0f, 0f, 0f))
        c.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(c.isNewSpot(4.05f, 0f))
        assertFalse(c.isNewSpot(0.05f, 0f))
        assertTrue(c.isNewSpot(4f, 3f))
        c.addCorner(Vec3(4f, 0f, 3f))
        assertTrue(c.isNewSpot(0.05f, 0f))
    }
}
