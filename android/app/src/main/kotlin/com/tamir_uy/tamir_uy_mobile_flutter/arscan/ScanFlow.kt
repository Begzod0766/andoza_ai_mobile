package com.tamir_uy.tamir_uy_mobile_flutter.arscan

enum class ScanStep { FIND_FLOOR, BASE, HEIGHT, WALLS, DONE, OPENINGS }

/** What the chrome shows this frame; keys are the copy keys passed in from Flutter. */
data class FlowUi(
    val hintKey: String,
    val mainKey: String?,
    val mainEnabled: Boolean,
    val undoVisible: Boolean,
    val closeVisible: Boolean,
    val chipsVisible: Boolean,
    /** The pill under the hint when it isn't "Xonani yopish": opens/ends doors and windows. */
    val secondaryKey: String? = null,
    /** The Eshik / Deraza toggle (doors-and-windows step). */
    val typeChipsVisible: Boolean = false,
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

    /** Doors and windows, marked after the room is closed (edge + fractions). */
    val openings = OpeningCapture()
    @Volatile var openingType = OpeningType.DOOR

    /** The closed outline the openings' edge indices refer to. */
    fun loop(): List<Vec3> = openings.loop(capture.corners, capture.isClosed)

    /** Where the aim lands on a wall while marking openings; null off the walls. */
    fun edgeAt(reticle: Vec3?): EdgeHit? =
        if (step == ScanStep.OPENINGS && reticle != null) openings.snap(reticle, loop()) else null

    fun startOpenings(): Boolean {
        if (step != ScanStep.DONE) return false
        step = ScanStep.OPENINGS
        return true
    }

    /** Back to the finished room, keeping the openings (a half-marked one is dropped). */
    fun finishOpenings(): Boolean {
        if (step != ScanStep.OPENINGS) return false
        if (openings.pending != null) openings.undo()
        step = ScanStep.DONE
        return true
    }

    /** One edge of a door/window under the aim; null when it isn't on a wall. */
    fun addOpeningEdge(reticle: Vec3): OpeningAddResult? {
        val hit = edgeAt(reticle) ?: return null
        return openings.addEdge(hit, openingType, loop())
    }

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
        // Openings hang on the closed outline: they go before it reopens.
        ScanStep.DONE -> if (openings.openings.isNotEmpty()) {
            openings.undo()
            0
        } else {
            capture.reopen()
            step = ScanStep.WALLS
            1
        }
        ScanStep.OPENINGS -> {
            if (!openings.undo()) step = ScanStep.DONE
            0
        }
    }

    /** After [FloorPlanCapture.updatePositions] dropped corners whose anchors stopped tracking. */
    fun cornersLost() {
        // Their edge indices referred to the outline that just changed.
        openings.clear()
        if (step == ScanStep.OPENINGS) step = ScanStep.DONE
        if (capture.corners.isEmpty()) {
            height = null
            if (step != ScanStep.FIND_FLOOR) step = ScanStep.BASE
        } else if (step == ScanStep.DONE) {
            step = ScanStep.WALLS
        }
    }

    fun ui(
        tracking: Boolean,
        reticle: Vec3?,
        liveHeight: Float?,
        lostHintKey: String = "arScanTrackingLost",
        settling: Boolean = false,
    ): FlowUi {
        val ok = tracking && !settling && reticle != null
        val ui = when (step) {
            ScanStep.FIND_FLOOR -> FlowUi("arScanFindFloor", null, false, false, false, false)
            ScanStep.BASE -> FlowUi(
                if (reticle == null) "arScanNoFloorHere" else "arScanBaseHint",
                "arScanStart", ok, false, false, false,
            )
            ScanStep.HEIGHT -> FlowUi("arScanAimCeiling", "arScanConfirm", tracking && !settling && liveHeight != null, true, false, true)
            ScanStep.WALLS -> {
                // A tap there closes the room, so the button says so.
                val snap = reticle != null && capture.wouldSnap(reticle)
                FlowUi(
                    if (snap) "arScanSnapToFirst" else "arScanCornersHint",
                    if (snap) "arScanCloseRoom" else "arScanAddCorner",
                    ok, true, tracking && !settling && capture.corners.size >= 3, false,
                )
            }
            ScanStep.DONE -> FlowUi("arScanDoneHint", "arScanCreatePlan", true, true, false, false, secondaryKey = "arScanAddOpenings")
            ScanStep.OPENINGS -> {
                val onWall = edgeAt(reticle) != null
                FlowUi(
                    if (onWall) "arScanOpeningsHint" else "arScanAimWallBase",
                    "arScanAddEdge", tracking && !settling && onWall, true, false, false,
                    secondaryKey = "arScanOpeningsDone", typeChipsVisible = true,
                )
            }
        }
        val live = step != ScanStep.DONE && step != ScanStep.OPENINGS
        return when {
            !tracking && live -> ui.copy(hintKey = lostHintKey)
            settling && step != ScanStep.DONE && step != ScanStep.FIND_FLOOR -> ui.copy(hintKey = "arScanTrackingSettling")
            else -> ui
        }
    }
}
