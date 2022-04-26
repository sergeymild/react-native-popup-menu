package com.reactnativepopupmenu.sheet

import android.annotation.TargetApi
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.view.ViewStructure
import android.view.accessibility.AccessibilityEvent
import androidx.appcompat.app.AppCompatActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.uimanager.events.RCTEventEmitter

class AppFittedSheet(context: Context) : ViewGroup(context), LifecycleEventListener {
    private val fragmentTag = "CCBottomSheet-${System.currentTimeMillis()}"
    var mHostView: Wrapper = Wrapper(context)

    var sheetSize: Int = -1
        set(value) {
            mHostView.reactHeight = value
            if (field != value) mHostView.setVirtualHeight(value)
            field = value
        }
        get() = mHostView.reactHeight
    var sheetMaxWidthSize: Double = -1.0
      set(value) {
        field = value
        mHostView.sheetMaxWidthSize = value
      }
    var sheetMaxHeightSize: Double = -1.0
      set(value) {
        field = value
        mHostView.sheetMaxHeightSize = value
      }

  var topLeftRightCornerRadius: Double = -1.0
      set(value) {
        field = value
        sheet?.handleRadius = value.toFloat()
      }

    private fun getCurrentActivity(): AppCompatActivity {
        return (context as ReactContext).currentActivity as AppCompatActivity
    }

    private val sheet: FragmentModalBottomSheet?
        get() = getCurrentActivity().supportFragmentManager.findFragmentByTag(fragmentTag) as FragmentModalBottomSheet?

    fun showOrUpdate() {
        println("🥲showOrUpdate")
        UiThreadUtil.assertOnUiThread()

        val sheet = this.sheet
        if (sheet == null) {
            val fragment = FragmentModalBottomSheet()
            fragment.createViewCallable = ::getContentView
            fragment.onDismiss = Runnable {
                (context as ReactContext).getJSModule(RCTEventEmitter::class.java)
                    .receiveEvent(id, "onSheetDismiss", Arguments.createMap())
            }
            fragment.show(getCurrentActivity().supportFragmentManager, fragmentTag)
        }
    }

    @TargetApi(23)
    override fun dispatchProvideStructure(structure: ViewStructure?) {
        mHostView.dispatchProvideStructure(structure)
    }

    private fun getContentView(): Wrapper = mHostView

    override fun addView(child: View, index: Int) {
        println("🥲addView")
        UiThreadUtil.assertOnUiThread()
        mHostView.addView(child, index)
    }

    override fun getChildCount(): Int = mHostView.childCount

    override fun getChildAt(index: Int): View? = mHostView.getChildAt(index)

    override fun removeView(child: View?) {
        UiThreadUtil.assertOnUiThread()
        mHostView.removeView(child)
    }

    override fun removeViewAt(index: Int) {
        UiThreadUtil.assertOnUiThread()
        val child = getChildAt(index)
        mHostView.removeView(child)
    }

    override fun addChildrenForAccessibility(outChildren: ArrayList<View?>?) {
        // Explicitly override this to prevent accessibility events being passed down to children
        // Those will be handled by the mHostView which lives in the dialog
    }

    override fun dispatchPopulateAccessibilityEvent(event: AccessibilityEvent?): Boolean {
        // Explicitly override this to prevent accessibility events being passed down to children
        // Those will be handled by the mHostView which lives in the dialog
        return false
    }

    override fun onHostResume() {
        // We show the dialog again when the host resumes
        showOrUpdate()
    }

    override fun onHostPause() {
        // do nothing
    }

    override fun onHostDestroy() {
        // Drop the instance if the host is destroyed which will dismiss the dialog
        onDropInstance()
    }

    fun onDropInstance() {
        (context as ReactContext).removeLifecycleEventListener(this)
        dismiss()
    }

    private fun dismiss() {
        UiThreadUtil.assertOnUiThread()
        val sheet = this.sheet
        if (sheet != null) {
            sheet.dismissAllowingStateLoss()
            val parent = mHostView.parent as? ViewGroup
            parent?.removeViewAt(0)
        }
    }

    override fun onLayout(p0: Boolean, p1: Int, p2: Int, p3: Int, p4: Int) {}
}
