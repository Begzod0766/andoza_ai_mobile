package com.tamir_uy.tamir_uy_mobile_flutter.arscan

enum class ScanStep { FIND_FLOOR, BASE, HEIGHT, WALLS, DONE }

/** What the chrome shows this frame; keys are the copy keys passed in from Flutter. */
data class FlowUi(
    val hintKey: String,
    val mainKey: String?,
    val mainEnabled: Boolean,
    val undoVisible: Boolean,
    val closeVisible: Boolean,
    val chipsVisible: Boolean,
)

/**
 * The scanner's steps: find the floor → base point where wall meets floor →
 * height → corners (walls) → done. The base point is the first corner.
 * Lives on the GL thread with [capture]; the activity keeps one ARCore anchor
 * per corner and detaches as many as [undo] says.
 */
class ScanFlow(val capture: FloorPlanCapture = FloorPlanCapture()) {

    var step = ScanStep.FIND_FLOOR
        private set
    var height: Float? = null
        private set
    var heightMeasured = false
        private set

    /**
     * Taps are queued onto the GL thread: one made while the screen showed
     * [tappedIn] is stale if the step has moved on since (a quick second tap
     * on "Burchak qo'shish" must not also press "Rejani yaratish").
     */
    fun isCurrent(tappedIn: ScanStep): Boolean = step == tappedIn

    fun floorFound() {
        if (step == ScanStep.FIND_FLOOR) step = ScanStep.BASE
    }

    fun placeBase(p: Vec3): Boolean {
        if (step != ScanStep.BASE || capture.addCorner(p) != AddResult.ADDED) return false
        step = ScanStep.HEIGHT
        return true
    }

    fun confirmHeight(h: Float, measured: Boolean): Boolean {
        if (step != ScanStep.HEIGHT || h !in FloorPlanCapture.MIN_HEIGHT_M..FloorPlanCapture.MAX_HEIGHT_M) return false
        height = h
        heightMeasured = measured
        step = ScanStep.WALLS
        return true
    }

    fun addCorner(p: Vec3): AddResult {
        if (step != ScanStep.WALLS) return AddResult.REJECTED_CLOSED
        return capture.addCorner(p).also { if (it == AddResult.CLOSED) step = ScanStep.DONE }
    }

    fun closeRoom(): Boolean {
        if (step != ScanStep.WALLS || !capture.close()) return false
        step = ScanStep.DONE
        return true
    }

    /** One step back; returns how many of the last anchors to detach. */
    fun undo(): Int = when (step) {
        ScanStep.FIND_FLOOR, ScanStep.BASE -> 0
        ScanStep.HEIGHT -> {
            capture.undo()
            step = ScanStep.BASE
            1
        }
        ScanStep.WALLS -> if (capture.corners.size <= 1) {
            height = null
            step = ScanStep.HEIGHT
            0
        } else {
            capture.undo()
            1
        }
        ScanStep.DONE -> {
            capture.reopen()
            step = ScanStep.WALLS
            1
        }
    }

    /** After [FloorPlanCapture.updatePositions] dropped corners whose anchors stopped tracking. */
    fun cornersLost() {
        if (capture.corners.isEmpty()) {
            height = null
            if (step != ScanStep.FIND_FLOOR) step = ScanStep.BASE
        } else if (step == ScanStep.DONE) {
            step = ScanStep.WALLS
        }
    }

    fun ui(tracking: Boolean, reticle: Vec3?, liveHeight: Float?): FlowUi {
        val ok = tracking && reticle != null
        val ui = when (step) {
            ScanStep.FIND_FLOOR -> FlowUi("arScanFindFloor", null, false, false, false, false)
            ScanStep.BASE -> FlowUi(
                if (reticle == null) "arScanNoFloorHere" else "arScanBaseHint",
                "arScanStart", ok, false, false, false,
            )
            ScanStep.HEIGHT -> FlowUi("arScanAimCeiling", "arScanConfirm", tracking && liveHeight != null, true, false, true)
            ScanStep.WALLS -> FlowUi(
                if (reticle != null && capture.wouldSnap(reticle)) "arScanSnapToFirst" else "arScanCornersHint",
                "arScanAddCorner", ok, true, tracking && capture.corners.size >= 3, false,
            )
            ScanStep.DONE -> FlowUi("arScanDoneHint", "arScanCreatePlan", true, true, false, false)
        }
        return if (!tracking && step != ScanStep.DONE) ui.copy(hintKey = "arScanTrackingLost") else ui
    }
}
