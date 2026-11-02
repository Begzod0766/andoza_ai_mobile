package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class FloorRayTest {

    @Test fun `looking down hits the floor`() {
        val p = FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, -1f, -1f), 0f)!!
        assertEquals(0f, p.x, 1e-5f); assertEquals(0f, p.y, 1e-5f); assertEquals(-1.5f, p.z, 1e-5f)
    }

    @Test fun `looking up or level misses`() {
        assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, 0.2f, -1f), 0f))
        assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, 0f, -1f), 0f))
    }

    @Test fun `farther than 8 m misses`() {
        assertNull(FloorRay.hit(Vec3(0f, 1.5f, 0f), Vec3(0f, -0.1f, -1f), 0f)) // ~15 m away
    }

    @Test fun `pick ignores a table top`() {
        val table = Vec3(1f, 0.75f, -1f)
        val ray = Vec3(1.2f, 0f, -1.4f)
        assertEquals(ray, FloorRay.pick(table, ray, 0f))
    }

    @Test fun `pick prefers a real floor hit and pins it to floorY`() {
        val p = FloorRay.pick(Vec3(1f, 0.04f, -1f), Vec3(1.1f, 0f, -1f), 0f)!!
        assertEquals(1f, p.x, 1e-6f); assertEquals(0f, p.y, 1e-6f)
    }

    @Test fun `pick before the floor is known uses the plane hit`() {
        val h = Vec3(1f, -1.3f, -1f)
        assertEquals(h, FloorRay.pick(h, null, null))
    }

    @Test fun `pick ignores a low platform 20 cm up`() {
        val korpacha = Vec3(1f, 0.2f, -1f)
        val ray = Vec3(1.3f, 0f, -1.5f)
        assertEquals(ray, FloorRay.pick(korpacha, ray, 0f))
    }
}
