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

    @Test fun `point ahead is on screen`() {
        val t = g.locate(Vec3(0f, 0f, -2f), 50f) as ScreenTarget.OnScreen
        assertEquals(500f, t.at.first, 0.01f); assertEquals(500f, t.at.second, 0.01f)
    }

    @Test fun `point far right is off screen at the right edge`() {
        val t = g.locate(Vec3(10f, 0f, -2f), 50f) as ScreenTarget.OffScreen
        assertEquals(950f, t.at.first, 0.01f); assertEquals(500f, t.at.second, 0.01f)
        assertEquals(0f, t.angleRad, 1e-3f)
    }

    @Test fun `point behind and to the left points left`() {
        val t = g.locate(Vec3(-1f, 0f, 2f), 50f) as ScreenTarget.OffScreen
        assertEquals(50f, t.at.first, 0.01f)
        assertEquals(Math.PI.toFloat(), abs(t.angleRad), 1e-3f)
    }

    @Test fun `point straight behind points down`() {
        val t = g.locate(Vec3(0f, 0f, 2f), 50f) as ScreenTarget.OffScreen
        assertEquals((Math.PI / 2).toFloat(), t.angleRad, 1e-3f)
        assertEquals(950f, t.at.second, 0.01f)
    }

    @Test fun `off-screen point is always inside the inset bounds`() {
        for (p in listOf(Vec3(5f, 3f, -1f), Vec3(-4f, -6f, 1f), Vec3(0.1f, 9f, 3f), Vec3(-20f, 0.5f, -0.5f), Vec3(2f, -2f, 0f))) {
            val t = g.locate(p, 50f)
            val at = when (t) { is ScreenTarget.OnScreen -> t.at; is ScreenTarget.OffScreen -> t.at }
            assertTrue("$p -> $at", at.first in 49.99f..950.01f && at.second in 49.99f..950.01f)
        }
    }

    @Test fun `arrow keeps clear of the chrome with per-side insets`() {
        // Straight behind: pinned above the bottom inset (the main button), centred.
        val t = g.locate(Vec3(0f, 0f, 2f), left = 50f, top = 200f, right = 50f, bottom = 150f) as ScreenTarget.OffScreen
        assertEquals(850f, t.at.second, 0.01f); assertEquals(500f, t.at.first, 0.01f)
        // A point on screen but under the bottom chrome counts as off screen.
        val under = g.locate(Vec3(0f, -1.8f, -2f), left = 50f, top = 200f, right = 50f, bottom = 150f)
        assertTrue(under is ScreenTarget.OffScreen)
    }

    @Test fun `a point inside the margin band is off screen and pinned to the border`() {
        // x = 970 px on a 1000 px screen, margin 50.
        val t = g.locate(Vec3(0.94f, 0f, -1f), 50f) as ScreenTarget.OffScreen
        assertEquals(950f, t.at.first, 0.01f)
    }

    @Test fun `a label centre is pulled in so the label stays on screen`() {
        assertEquals(118f, keepOnScreen(100f, half = 110f, size = 1080f, pad = 8f), 0.01f)
        assertEquals(962f, keepOnScreen(1000f, half = 110f, size = 1080f, pad = 8f), 0.01f)
        assertEquals(540f, keepOnScreen(540f, half = 110f, size = 1080f, pad = 8f), 0.01f)
        assertEquals(50f, keepOnScreen(10f, half = 600f, size = 100f, pad = 8f), 0.01f) // wider than the screen: centred
    }
}
