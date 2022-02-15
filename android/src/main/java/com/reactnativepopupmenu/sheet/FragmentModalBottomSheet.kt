package com.reactnativepopupmenu.sheet

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.reactnativepopupmenu.R

class FragmentModalBottomSheet : BottomSheetDialogFragment() {

  var peekHeight: Double = 0.0
    set(value) {
      field = value
      (dialog as SheetDialog?)?.peekHeight = value.toInt()
    }
  var handleRadius: Float = 12F
    set(value) {
      field = value
      (dialog as SheetDialog?)?.cornerRadius = value
    }
    get() = (dialog as SheetDialog?)?.cornerRadius ?: field
  var onDismiss: Runnable? = null
  var createViewCallable: (() -> View)? = null

  private val mBottomSheetBehaviorCallback: BottomSheetBehavior.BottomSheetCallback = object : BottomSheetBehavior.BottomSheetCallback() {
    @SuppressLint("SwitchIntDef")
    override fun onStateChanged(bottomSheet: View, newState: Int) {
      when (newState) {
        BottomSheetBehavior.STATE_HIDDEN -> {
          dismiss()
        }
      }
    }

    override fun onSlide(bottomSheet: View, slideOffset: Float) {}
  }

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
    val view = createViewCallable!!.invoke()
    if (peekHeight != 0.0) return view

    val reactView = (view as ViewGroup).getChildAt(0)
    reactView.viewTreeObserver.addOnPreDrawListener(object: ViewTreeObserver.OnPreDrawListener {
      override fun onPreDraw(): Boolean {
        reactView.viewTreeObserver.removeOnPreDrawListener(this)
        peekHeight = view.measuredHeight.toDouble()
        return true
      }
    })
    return view
  }

  override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
    val dialog = SheetDialog(requireContext(), R.style.AppBottomSheetDialog)
    dialog.peekHeight = peekHeight.toInt()
    dialog.cornerRadius = handleRadius
    dialog.behavior.addBottomSheetCallback(mBottomSheetBehaviorCallback)
    return dialog
  }

  override fun onDismiss(dialog: DialogInterface) {
    super.onDismiss(dialog)
    onDismiss?.run()
  }
}
