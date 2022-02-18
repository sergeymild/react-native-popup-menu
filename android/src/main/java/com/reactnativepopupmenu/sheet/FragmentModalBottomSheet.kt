package com.reactnativepopupmenu.sheet

import android.annotation.SuppressLint
import android.app.Dialog
import android.content.DialogInterface
import android.os.Bundle
import android.os.Handler
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import com.facebook.react.bridge.GuardedRunnable
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.PixelUtil
import com.facebook.react.uimanager.UIManagerHelper.getReactContext
import com.facebook.react.uimanager.UIManagerModule
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

  fun setSize(reactView: ViewGroup) {
    val reactContext: ReactContext = getReactContext(view)
    val modalSize = ModalHostHelper.getModalHostSize(reactContext)
    println("before measure dialogRootViewGroup")
    ((dialog as SheetDialog).containerView.getChildAt(0) as ViewGroup).getChildAt(1).measure(
      View.MeasureSpec.makeMeasureSpec(modalSize.x, View.MeasureSpec.EXACTLY),
      View.MeasureSpec.makeMeasureSpec(peekHeight.toInt(), View.MeasureSpec.EXACTLY)
    )
    ReactNativeReflection.setSize(reactView, modalSize.x, peekHeight.toInt())
    this.peekHeight = peekHeight
//    reactContext.runOnNativeModulesQueueThread(
//      object : GuardedRunnable(reactContext) {
//        override fun runGuarded() {
//          val viewTag: Int = view.getChildAt(0).getId()
//          val modalSize = ModalHostHelper.getModalHostSize(reactContext)
//          println("🥲runGuarded peekHeight: ${peekHeight} height: ${modalSize.y} vH: ${view.measuredHeight} ${PixelUtil.toPixelFromDIP(peekHeight)}")
//          getReactContext(view)
//            .getNativeModule(UIManagerModule::class.java)!!
//            .updateNodeSize(viewTag, modalSize.x, peekHeight.toInt())
//        }
//      })
  }

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
    val view = createViewCallable!!.invoke()
    if (peekHeight > 0.0) {
      return view
    }

    val reactView = (view as ViewGroup).getChildAt(0)
    reactView.viewTreeObserver.addOnPreDrawListener(object: ViewTreeObserver.OnPreDrawListener {
      override fun onPreDraw(): Boolean {
        reactView.viewTreeObserver.removeOnPreDrawListener(this)
        println("🥲 onPreDraw ${reactView.measuredHeight}")
        Handler().postDelayed(Runnable {
          peekHeight = reactView.measuredHeight.toDouble()
          setSize(reactView as ViewGroup)
        }, 3000)
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
