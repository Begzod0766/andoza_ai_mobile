package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import kotlin.math.abs
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class WallGeometryTest {

    private val identity = floatArrayOf(1f, 0f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f, 1f)

    // fovy 90°, aspect 1 (column-major, like ARCore's getProjectionMatrix).
    private fun persp(n: Float = 0.05f, f: Float = 100f) =
        floatArrayOf(1f, 0f, 0f, 0f, 0f, 1f, 0f, 0f, 0f, 0f, (f + n) / (n - f), -1f, 0f, 0f, 2 * f * n / (n - f), 0f)

    private val g = WallGeometry(identity, persp(), 1000, 1000)

    @Test fun `point straight ahead is the screen centre`() {
        val p = g.point(Vec3(0f, 0f, -2f))!!
        assertEquals(500f, p.first, 0.01f); assertEquals(500f, p.second, 0.01f)
    }

    @Test fun `point up and right lands up and right`() {
        val p = g.point(Vec3(1f, 1f, -2f))!!
        assertEquals(750f, p.first, 0.01f); assertEquals(250f, p.second, 0.01f)
    }

    @Test fun `point behind the camera is null`() {
        assertNull(g.point(Vec3(0f, 0f, 2f)))
    }

    @Test fun `wall in front has four corners and a label`() {
        val w = g.wall(Vec3(-1f, -1.5f, -3f), Vec3(1f, -1.5f, -3f), 2.5f)!!
        assertEquals(4, w.outline.size); assertNotNull(w.labelAt)
        assertEquals(3 + 4, w.grid.size) // 3 vertical (x=-0.5,0,0.5) + 4 horizontal (0.5..2.0)
    }

    @Test fun `wall behind the camera is null`() {
        assertNull(g.wall(Vec3(-1f, -1.5f, 3f), Vec3(1f, -1.5f, 3f), 2.5f))
    }

    @Test fun `wall through the camera is clipped to the near plane`() {
        val w = g.wall(Vec3(0.5f, -1.5f, 2f), Vec3(0.5f, -1.5f, -2f), 2.5f)!!
        assertEquals(4, w.outline.size)
        assertTrue(w.outline.all { it.first.isFinite() && it.second.isFinite() })
        assertTrue(w.outline.all { abs(it.first) < 1e5f && abs(it.second) < 1e5f })
        assertNull(w.labelAt) // the bottom edge's midpoint is at z=0, behind the near plane
    }

    @Test fun `segment crossing the near plane keeps its visible half`() {
        val s = g.segment(Vec3(0f, -1f, 1f), Vec3(0f, -1f, -2f))!!
        assertEquals(500f, s.b.first, 0.01f); assertEquals(750f, s.b.second, 0.01f)
        assertTrue(s.a.second > 1000f) // the near end drops off the bottom of the screen
    }

    @Test fun `floor ellipse in front has all its points`() {
        assertEquals(32, g.floorEllipse(Vec3(0f, -1.5f, -2f))!!.size)
    }

    @Test fun `floor ellipse behind is null`() {
        assertNull(g.floorEllipse(Vec3(0f, -1.5f, 2f)))
    }

    @Test fun `a panel on a wall spans its stretch and heights`() {
        // Wall from x=-1 to x=1 at z=-3; a door on its middle half, floor to 2 m.
        val a = Vec3(-1f, -1.5f, -3f); val b = Vec3(1f, -1.5f, -3f)
        val p = g.panel(a, b, t0 = 0.25f, t1 = 0.75f, bottom = 0f, top = 2f)!!
        assertEquals(4, p.size)
        assertEquals(g.point(Vec3(-0.5f, -1.5f, -3f))!!, p[0])
        assertEquals(g.point(Vec3(0.5f, 0.5f, -3f))!!, p[2])
    }

    @Test fun `a panel behind the camera is null`() {
        assertNull(g.panel(Vec3(-1f, 0f, 3f), Vec3(1f, 0f, 3f), 0f, 1f, 0f, 2f))
    }
}
