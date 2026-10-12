package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.abs
import kotlin.math.hypot

class WallTrackerTest {

    private fun wall(id: Int, ax: Float, az: Float, bx: Float, bz: Float): WallObs {
        val len = hypot(bx - ax, bz - az)
        return WallObs(id, (ax + bx) / 2, (az + bz) / 2, (bx - ax) / len, (bz - az) / len, len / 2)
    }

    private val room = listOf(
        wall(1, 0f, 0f, 4f, 0f),
        wall(2, 4f, 0f, 4f, 3f),
        wall(3, 4f, 3f, 0f, 3f),
        wall(4, 0f, 3f, 0f, 0f),
    )

    private fun hasCornerAt(f: WallFrame, x: Float, z: Float) =
        f.candidates.any { abs(it.x - x) <= 0.01f && abs(it.z - z) <= 0.01f }

    @Test fun `four walls of a 4x3 room give four corners`() {
        val f = WallTracker().update(room, 0)
        assertEquals(4, f.candidates.size)
        for ((x, z) in listOf(0f to 0f, 4f to 0f, 4f to 3f, 0f to 3f)) assertTrue("corner $x,$z", hasCornerAt(f, x, z))
    }

    @Test fun `L-shaped room gives six corners`() {
        val pts = listOf(0f to 0f, 4f to 0f, 4f to 2f, 2f to 2f, 2f to 4f, 0f to 4f)
        val walls = pts.indices.map { i ->
            val (ax, az) = pts[i]; val (bx, bz) = pts[(i + 1) % pts.size]
            wall(i + 1, ax, az, bx, bz)
        }
        val f = WallTracker().update(walls, 0)
        assertEquals(6, f.candidates.size)
        for ((x, z) in pts) assertTrue("corner $x,$z", hasCornerAt(f, x, z))
    }

    @Test fun `parallel walls give no corner`() {
        val f = WallTracker().update(listOf(wall(1, 0f, 0f, 4f, 0f), wall(2, 0f, 3f, 4f, 3f)), 0)
        assertEquals(0, f.candidates.size)
    }

    @Test fun `walls far from each other give no corner`() {
        val f = WallTracker().update(listOf(wall(1, 0f, 0f, 1f, 0f), wall(2, 3f, 1f, 3f, 3f)), 0)
        assertEquals(0, f.candidates.size)
    }

    @Test fun `two pieces of one wall merge`() {
        val f = WallTracker().update(listOf(wall(1, 0f, 0f, 1.5f, 0f), wall(2, 2f, 0.03f, 4f, 0.03f)), 0)
        assertEquals(1, f.walls.size)
        val w = f.walls[0]
        assertEquals(1, w.key)
        assertEquals(0f, minOf(w.ax, w.bx), 0.02f)
        assertEquals(4f, maxOf(w.ax, w.bx), 0.02f)
    }

    @Test fun `a candidate becomes stable after a second of standing still`() {
        val t = WallTracker()
        assertFalse(t.update(room, 0).candidates.any { it.stable })
        assertFalse(t.update(room, 999).candidates.any { it.stable })
        assertTrue(t.update(room, 1000).candidates.all { it.stable })
    }

    @Test fun `a moving candidate restarts its clock`() {
        val t = WallTracker()
        t.update(room, 0)
        val shifted = listOf(wall(1, 0f, 0.06f, 4f, 0.06f)) + room.drop(1)
        t.update(shifted, 600)
        val at1200 = t.update(shifted, 1200)
        assertFalse(at1200.candidates.first { abs(it.x - 4f) < 0.02f && abs(it.z - 0.06f) < 0.02f }.stable)
        val at1600 = t.update(shifted, 1600)
        assertTrue(at1600.candidates.first { abs(it.x - 4f) < 0.02f && abs(it.z - 0.06f) < 0.02f }.stable)
    }

    @Test fun `short walls never make a stable corner`() {
        val walls = listOf(
            wall(1, 0f, 0f, 4f, 0f),
            wall(2, 4f, 0f, 4f, 0.4f), // 40 cm — a wardrobe side, not a wall
            wall(3, 0f, 3f, 0f, 0f),
        )
        val t = WallTracker()
        t.update(walls, 0)
        val f = t.update(walls, 2000)
        val short = f.candidates.filter { abs(it.x - 4f) < 0.02f && abs(it.z) < 0.02f }
        assertEquals(1, short.size)
        assertFalse(short[0].stable)
        assertTrue(f.candidates.first { abs(it.x) < 0.02f && abs(it.z) < 0.02f }.stable)
    }

    @Test fun `wall order and a newly merged piece keep the candidate key`() {
        val keys = WallTracker().update(room, 0).candidates.map { it.key }.toSet()
        val reordered = room.reversed() + wall(99, 1f, 0.02f, 2f, 0.02f)
        val keys2 = WallTracker().update(reordered, 0).candidates.map { it.key }.toSet()
        assertEquals(keys, keys2)
    }

    @Test fun `wallObsFrom turns a vertical plane polygon into a floor segment`() {
        val poly = listOf(Vec3(0f, 0f, 0f), Vec3(4f, 0f, 0f), Vec3(4f, 2f, 0f), Vec3(0f, 2f, 0f))
        val o = wallObsFrom(7, Vec3(2f, 1f, 0f), Vec3(0f, 0f, 1f), poly)
        assertNotNull(o)
        assertEquals(2f, o!!.cx, 1e-4f)
        assertEquals(0f, o.cz, 1e-4f)
        assertEquals(1f, abs(o.dx), 1e-4f)
        assertEquals(2f, o.halfLength, 1e-4f)
        assertNull(wallObsFrom(7, Vec3(2f, 1f, 0f), Vec3(0f, 1f, 0f), poly))
    }

    @Test fun `walls on one line with a doorway between stay apart`() {
        val f = WallTracker().update(listOf(wall(1, 0f, 0f, 1f, 0f), wall(2, 2f, 0f, 4f, 0f)), 0)
        assertEquals(2, f.walls.size)
    }
}
