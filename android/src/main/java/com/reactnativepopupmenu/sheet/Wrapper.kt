package com.reactnativepopupmenu.sheet

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.JSTouchDispatcher
import com.facebook.react.uimanager.RootView
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.UIManagerModule
import com.facebook.react.uimanager.events.EventDispatcher
import com.facebook.react.views.view.ReactViewGroup

class Wrapper(context: Context) : ReactViewGroup(context), RootView {
    private val reactContext: ReactContext
        private get() = context as ReactContext

    private val mJSTouchDispatcher = JSTouchDispatcher(this)
    override fun onInterceptTouchEvent(event: MotionEvent): Boolean {
        mJSTouchDispatcher.handleTouchEvent(event, eventDispatcher)
        return super.onInterceptTouchEvent(event)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        mJSTouchDispatcher.handleTouchEvent(event, eventDispatcher)
        super.onTouchEvent(event)
        // In case when there is no children interested in handling touch event, we return true from
        // the root view in order to receive subsequent events related to that gesture
        return true
    }

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // No-op - override in order to still receive events to onInterceptTouchEvent
        // even when some other view disallow that
    }

    private val eventDispatcher: EventDispatcher
        private get() {
            val reactContext = reactContext
            return reactContext.getNativeModule(UIManagerModule::class.java).eventDispatcher
        }

    init {
        backgroundColor = Color.GREEN
    }

    var reactHeight: Int = -1

    private var reactView: View? = null
        set(value) {
            field = value
            if (value == null) return
            value.viewTreeObserver.addOnPreDrawListener(object :
                ViewTreeObserver.OnPreDrawListener {
                override fun onPreDraw(): Boolean {
                    value.viewTreeObserver.removeOnPreDrawListener(this)
                    setVirtualHeight(value.measuredHeight)
//                    Handler().postDelayed({
//                        setVirtualHeight(value.measuredHeight)
//                    }, 1000)
                    return true
                }
            })
        }

    fun setVirtualHeight(h: Int) {
        this@Wrapper.reactHeight = h
        if (h < 0) return // TODO What todo?
        val reactContext: ReactContext =
            UIManagerHelper.getReactContext(this@Wrapper)
        val w = ModalHostHelper.getModalHostSize(reactContext).x
        println("🔦 SetSize $w x $h")
        ReactNativeReflection.setSize(reactView, w, h)
        layoutParams = FrameLayout.LayoutParams(w, h)
    }

    override fun addView(child: View, index: Int, params: ViewGroup.LayoutParams) {
        if (reactView != null) removeView(reactView)
        super.addView(child, -1, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        reactView = child
    }

    override fun removeView(view: View?) {
        if (view == reactView) reactView = null
        super.removeView(view)
    }

    override fun removeViewAt(index: Int) {
        if (getChildAt(index) === reactView) reactView = null
        super.removeViewAt(index)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        if (reactHeight > -1) {
            super.onMeasure(
                widthMeasureSpec,
                MeasureSpec.makeMeasureSpec(reactHeight, MeasureSpec.EXACTLY)
            )
//            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), reactHeight)
            println("🔦 1 S w: $measuredWidth $measuredHeight")
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            println("🔦 2 S w: $measuredWidth $measuredHeight")
        }
    }

//    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
//        val b = if (reactHeight > -1) top + reactHeight else bottom
//        super.onLayout(changed, left, top, right, b)
//        println("🔦 LAYOUT $changed, $left, $top, $right, $bottom, b: $b")
//    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        println("🔦 size changed $w, $h, $oldw, $oldh, $reactHeight")
    }

    override fun onChildStartedNativeGesture(androidEvent: MotionEvent?) {
        mJSTouchDispatcher.onChildStartedNativeGesture(androidEvent, eventDispatcher)
    }

    override fun handleException(t: Throwable?) {
        reactContext.handleException(RuntimeException(t))
    }
}
