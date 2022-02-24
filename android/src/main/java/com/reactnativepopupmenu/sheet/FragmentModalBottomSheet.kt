package com.reactnativepopupmenu.sheet

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.google.android.material.bottomsheet.BottomSheetBehavior
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.reactnativepopupmenu.R

var publicPeekHeight: Double = 0.0

class FragmentModalBottomSheet : BottomSheetDialogFragment() {

    var peekHeight: Double = 0.0
        set(value) {
            field = value
            publicPeekHeight = value
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

    private val mBottomSheetBehaviorCallback: BottomSheetBehavior.BottomSheetCallback =
        object : BottomSheetBehavior.BottomSheetCallback() {
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

//  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
//    val view = createViewCallable!!.invoke()
//    if (peekHeight > 0.0) {
//      return Wrapper(view as ViewGroup).apply { alpha = 0.5F }
//    }
//
//    return Wrapper(view as ViewGroup).apply { alpha = 0.5F
//        layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)
//      setBackgroundColor(Color.GREEN)
//    }
//  }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val view = createViewCallable!!.invoke()
        return view.apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT
            )
        }
//    if (peekHeight > 0.0) {
//      return Wrapper(view as ViewGroup).apply { alpha = 0.5F }
//    }
//
//    return Wrapper(view as ViewGroup).apply { alpha = 0.5F
//        layoutParams = FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT)
//      setBackgroundColor(Color.GREEN)
//    }
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
