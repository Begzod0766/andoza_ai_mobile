package com.tamir_uy.tamir_uy_mobile_flutter.arscan

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale

/**
 * The scanner's buttons and copy over the camera: ✕ and ↶ in the corners, one
 * hint card at the top, "Xonani yopish" under it, height chips and the single
 * main button at the bottom. [bind] shows a [FlowUi].
 */
class ArScanChrome(private val activity: Activity, private val s: (String) -> String, presetHeights: FloatArray) {

    var onExit: () -> Unit = {}
    var onUndo: () -> Unit = {}
    var onMain: () -> Unit = {}
    var onCloseRoom: () -> Unit = {}
    var onChip: (Float) -> Unit = {}
    var onOpeningType: (OpeningType) -> Unit = {}

    private val accent = Color.rgb(64, 56, 160)
    private fun dp(v: Int) = (v * activity.resources.displayMetrics.density).toInt()
    private fun rounded(fill: Int, radiusDp: Int) = GradientDrawable().apply { cornerRadius = dp(radiusDp).toFloat(); setColor(fill) }

    private fun iconButton(text: String) = TextView(activity).apply {
        this.text = text
        setTextColor(Color.WHITE)
        textSize = 24f
        gravity = Gravity.CENTER
        background = rounded(Color.argb(110, 0, 0, 0), 22)
    }

    private val undo = iconButton("↶").apply { contentDescription = s("arScanUndo"); setOnClickListener { onUndo() } }
    private val hint = TextView(activity).apply {
        setTextColor(Color.WHITE); textSize = 16f; gravity = Gravity.CENTER
        maxWidth = dp(300)
        setPadding(dp(18), dp(12), dp(18), dp(12))
        background = rounded(Color.argb(150, 0, 0, 0), 16)
    }
    private val closeRoom = TextView(activity).apply {
        text = s("arScanCloseRoom"); setTextColor(accent); textSize = 15f
        setPadding(dp(18), dp(10), dp(18), dp(10))
        background = rounded(Color.WHITE, 22)
        setOnClickListener { onCloseRoom() }
    }
    private val summary = TextView(activity).apply {
        setTextColor(accent); textSize = 14f; gravity = Gravity.CENTER
        setPadding(dp(14), dp(8), dp(14), dp(8))
        background = rounded(Color.WHITE, 12)
    }
    private val chips = LinearLayout(activity).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER
        for (h in presetHeights) {
            addView(TextView(activity).apply {
                text = String.format(Locale.US, "%.1f %s", h, s("arScanUnitM"))
                setTextColor(Color.WHITE); textSize = 14f
                setPadding(dp(14), dp(8), dp(14), dp(8))
                background = rounded(Color.argb(150, 0, 0, 0), 18)
                setOnClickListener { onChip(h) }
            }, LinearLayout.LayoutParams(-2, -2).apply { marginStart = dp(4); marginEnd = dp(4) })
        }
    }
    // Eshik / Deraza: which kind the next two edges make (doors-and-windows step).
    private var shownType = OpeningType.DOOR
    private fun typePill(type: OpeningType, key: String) = TextView(activity).apply {
        text = s(key); textSize = 15f
        setPadding(dp(18), dp(8), dp(18), dp(8))
        setOnClickListener { shownType = type; paintTypes(); onOpeningType(type) }
    }
    private val doorPill = typePill(OpeningType.DOOR, "arScanDoor")
    private val windowPill = typePill(OpeningType.WINDOW, "arScanWindow")
    private val types = LinearLayout(activity).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER
        addView(doorPill, LinearLayout.LayoutParams(-2, -2).apply { marginEnd = dp(8) })
        addView(windowPill, LinearLayout.LayoutParams(-2, -2))
    }
    private fun paintTypes() {
        for ((pill, type) in listOf(doorPill to OpeningType.DOOR, windowPill to OpeningType.WINDOW)) {
            val on = shownType == type
            pill.setTextColor(if (on) accent else Color.WHITE)
            pill.background = rounded(if (on) Color.WHITE else Color.argb(150, 0, 0, 0), 18)
        }
    }

    private val main = Button(activity).apply {
        isAllCaps = false
        textSize = 17f
        setTextColor(Color.WHITE)
        background = rounded(accent, 28)
        setPadding(dp(32), 0, dp(32), 0)
        minHeight = dp(56)
        setOnClickListener { onMain() }
    }

    val root: View = FrameLayout(activity).apply {
        val exit = iconButton("✕").apply { contentDescription = s("arScanExit"); setOnClickListener { onExit() } }
        addView(exit, FrameLayout.LayoutParams(dp(44), dp(44), Gravity.TOP or Gravity.START).apply { topMargin = dp(44); marginStart = dp(16) })
        addView(undo, FrameLayout.LayoutParams(dp(44), dp(44), Gravity.TOP or Gravity.END).apply { topMargin = dp(44); marginEnd = dp(16) })

        val top = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            addView(hint, LinearLayout.LayoutParams(-2, -2))
            addView(closeRoom, LinearLayout.LayoutParams(-2, -2).apply { topMargin = dp(12) })
        }
        addView(top, FrameLayout.LayoutParams(-1, -2, Gravity.TOP).apply { topMargin = dp(100) })

        val bottom = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(16), 0, dp(16), dp(40))
            addView(summary, LinearLayout.LayoutParams(-2, -2).apply { bottomMargin = dp(12) })
            addView(chips, LinearLayout.LayoutParams(-2, -2).apply { bottomMargin = dp(12) })
            addView(types, LinearLayout.LayoutParams(-2, -2).apply { bottomMargin = dp(12) })
            addView(main, LinearLayout.LayoutParams(-2, -2))
        }
        addView(bottom, FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM))
        paintTypes()
    }

    fun bind(ui: FlowUi, hintText: String, summaryText: String?, openingType: OpeningType = OpeningType.DOOR) {
        hint.text = hintText
        undo.visibility = if (ui.undoVisible) View.VISIBLE else View.INVISIBLE
        // The same pill: "Xonani yopish" while walling, else the doors/windows action.
        closeRoom.visibility = if (ui.closeVisible || ui.secondaryKey != null) View.VISIBLE else View.GONE
        closeRoom.text = s(ui.secondaryKey ?: "arScanCloseRoom")
        types.visibility = if (ui.typeChipsVisible) View.VISIBLE else View.GONE
        if (shownType != openingType) { shownType = openingType; paintTypes() }
        chips.visibility = if (ui.chipsVisible) View.VISIBLE else View.GONE
        summary.visibility = if (summaryText != null) View.VISIBLE else View.GONE
        summary.text = summaryText ?: ""
        if (ui.mainKey == null) {
            main.visibility = View.INVISIBLE
        } else {
            main.visibility = View.VISIBLE
            main.text = s(ui.mainKey)
            main.isEnabled = ui.mainEnabled
            main.alpha = if (ui.mainEnabled) 1f else 0.45f
        }
    }
}
