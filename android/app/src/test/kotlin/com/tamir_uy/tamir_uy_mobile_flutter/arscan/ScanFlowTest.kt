package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ScanFlowTest {

    private fun walls(): ScanFlow = ScanFlow().apply {
        floorFound(); placeBase(Vec3(0f, 0f, 0f)); confirmHeight(2.5f, measured = true)
    }

    @Test fun `starts looking for the floor with no main button`() {
        val f = ScanFlow()
        assertEquals(ScanStep.FIND_FLOOR, f.step)
        val ui = f.ui(true, null, null)
        assertEquals("arScanFindFloor", ui.hintKey); assertNull(ui.mainKey); assertFalse(ui.undoVisible)
    }

    @Test fun `base step asks for the wall-floor corner`() {
        val f = ScanFlow().apply { floorFound() }
        val ui = f.ui(true, Vec3(1f, 0f, -1f), null)
        assertEquals("arScanBaseHint", ui.hintKey); assertEquals("arScanStart", ui.mainKey); assertTrue(ui.mainEnabled)
        assertEquals("arScanNoFloorHere", f.ui(true, null, null).hintKey)
    }

    @Test fun `happy path to DONE by snapping`() {
        val f = walls()
        f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.addCorner(Vec3(0f, 0f, 3f))
        assertEquals(AddResult.CLOSED, f.addCorner(Vec3(0.1f, 0f, 0.1f)))
        assertEquals(ScanStep.DONE, f.step)
        assertEquals(2.5f, f.height!!, 1e-6f); assertTrue(f.heightMeasured)
        val ui = f.ui(true, null, null)
        assertEquals("arScanCreatePlan", ui.mainKey); assertTrue(ui.mainEnabled)
    }

    @Test fun `close room button needs three corners`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
        assertFalse(f.ui(true, Vec3(4f, 0f, 3f), null).closeVisible)
        assertFalse(f.closeRoom())
        f.addCorner(Vec3(4f, 0f, 3f))
        assertTrue(f.ui(true, Vec3(0f, 0f, 3f), null).closeVisible)
        assertTrue(f.closeRoom()); assertEquals(ScanStep.DONE, f.step)
    }

    @Test fun `height outside 1_8 to 4_5 m is refused`() {
        val f = ScanFlow().apply { floorFound(); placeBase(Vec3(0f, 0f, 0f)) }
        assertFalse(f.confirmHeight(1.2f, true)); assertFalse(f.confirmHeight(5f, true))
        assertEquals(ScanStep.HEIGHT, f.step)
        assertFalse(f.ui(true, null, null).mainEnabled)
        assertTrue(f.ui(true, null, null).chipsVisible)
    }

    @Test fun `a chip height is not measured`() {
        val f = ScanFlow().apply { floorFound(); placeBase(Vec3(0f, 0f, 0f)) }
        assertTrue(f.confirmHeight(2.7f, measured = false))
        assertEquals(ScanStep.WALLS, f.step); assertFalse(f.heightMeasured)
    }

    @Test fun `corners outside WALLS are refused`() {
        val f = ScanFlow().apply { floorFound() }
        assertEquals(AddResult.REJECTED_CLOSED, f.addCorner(Vec3(1f, 0f, 1f)))
        assertTrue(f.capture.corners.isEmpty())
    }

    @Test fun `snapping hint near the first corner`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f))
        assertEquals("arScanSnapToFirst", f.ui(true, Vec3(0.05f, 0f, 0.05f), null).hintKey)
        assertEquals("arScanCornersHint", f.ui(true, Vec3(2f, 0f, 2f), null).hintKey)
    }

    @Test fun `undo walks back one step at a time`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
        assertEquals(1, f.undo()); assertEquals(ScanStep.WALLS, f.step)
        assertEquals(0, f.undo()); assertEquals(ScanStep.HEIGHT, f.step); assertNull(f.height)
        assertEquals(1, f.undo()); assertEquals(ScanStep.BASE, f.step); assertTrue(f.capture.corners.isEmpty())
        assertEquals(0, f.undo()); assertEquals(ScanStep.BASE, f.step)
    }

    @Test fun `undo in DONE reopens`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.closeRoom()
        assertEquals(1, f.undo()); assertEquals(ScanStep.WALLS, f.step); assertFalse(f.capture.isClosed)
    }

    @Test fun `losing corners in DONE reopens`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f)); f.addCorner(Vec3(4f, 0f, 3f)); f.closeRoom()
        f.capture.updatePositions(listOf(Vec3(0f, 0f, 0f), Vec3(4f, 0f, 0f), null, null))
        f.cornersLost(); assertEquals(ScanStep.WALLS, f.step)
    }

    @Test fun `losing the base returns to BASE`() {
        val f = walls(); f.addCorner(Vec3(4f, 0f, 0f))
        f.capture.updatePositions(listOf(null, null))
        f.cornersLost(); assertEquals(ScanStep.BASE, f.step); assertNull(f.height)
    }

    @Test fun `no reticle disables the main button`() {
        val f = walls()
        assertFalse(f.ui(true, null, null).mainEnabled)
        assertFalse(f.ui(false, Vec3(1f, 0f, 1f), null).mainEnabled)
        assertEquals("arScanTrackingLost", f.ui(false, Vec3(1f, 0f, 1f), null).hintKey)
    }
}
