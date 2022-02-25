package com.reactnativepopupmenu.sheet

import android.animation.ValueAnimator
import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.JSTouchDispatcher
import com.facebook.react.uimanager.RootView
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.UIManagerModule
import com.facebook.react.uimanager.events.EventDispatcher
import com.facebook.react.views.view.ReactViewGroup
import com.reactnativepopupmenu.finalListener

class Wrapper(context: Context) : ReactViewGroup(context), RootView {

    private val reactContext: ReactContext
        private get() = context as ReactContext
    private val mJSTouchDispatcher = JSTouchDispatcher(this)
    private var animator: ValueAnimator? = null
    private val eventDispatcher: EventDispatcher
        private get() {
            val reactContext = reactContext
            return reactContext.getNativeModule(UIManagerModule::class.java).eventDispatcher
        }
    private var reactView: View? = null
        set(value) {
            field = value
            if (value == null) {
                pendingHeight = null
                return
            }
            if (!applyPendingHeight()) {
                value.viewTreeObserver.addOnPreDrawListener(object :
                    ViewTreeObserver.OnPreDrawListener {
                    override fun onPreDraw(): Boolean {
                        value.viewTreeObserver.removeOnPreDrawListener(this)
                        setVirtualHeight(value.measuredHeight)
                        return true
                    }
                })
            }
        }

    private var pendingHeight: Int? = null
    var reactHeight: Int = -1

    val isReactViewAttached: Boolean
        get() = reactView?.parent != null

    fun setVirtualHeight(h: Int) {
        if (reactView == null) {
            pendingHeight = h
            return
        }
        pendingHeight = null

        if (h < 0) { // TODO What todo?
            this@Wrapper.reactHeight = h
            return
        }
        val w = getModalW()
        ReactNativeReflection.setSize(reactView, w, h)
        val oldH = layoutParams.height
        if (oldH < 0) {
            this@Wrapper.reactHeight = h
            layoutParams = FrameLayout.LayoutParams(w, h)
        } else {
            playNewHeightAnimation(oldH = oldH, newH = h)
        }
    }

    override fun addView(child: View, index: Int, params: LayoutParams) {
        if (reactView != null) removeView(reactView)
        super.addView(child, -1, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))
        reactView = child
    }

    override fun removeView(view: View?) {
        if (view == reactView) releaseReactView()
        super.removeView(view)
    }

    override fun removeViewAt(index: Int) {
        if (getChildAt(index) === reactView) releaseReactView()
        super.removeViewAt(index)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        if (reactHeight > -1) {
            super.onMeasure(
                widthMeasureSpec,
                MeasureSpec.makeMeasureSpec(reactHeight, MeasureSpec.EXACTLY)
            )
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        }
    }

    override fun onChildStartedNativeGesture(androidEvent: MotionEvent?) {
        mJSTouchDispatcher.onChildStartedNativeGesture(androidEvent, eventDispatcher)
    }

    override fun handleException(t: Throwable?) {
        reactContext.handleException(RuntimeException(t))
    }

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

    // No-op - override in order to still receive events to onInterceptTouchEvent
    // even when some other view disallow that
    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) = Unit

    private fun applyPendingHeight(): Boolean {
        val pendingHeight = this.pendingHeight ?: return false
        this@Wrapper.reactHeight = pendingHeight
        val w = getModalW()
        ReactNativeReflection.setSize(reactView, w, pendingHeight)
        layoutParams = FrameLayout.LayoutParams(w, pendingHeight)
        this.pendingHeight = null
        return true
    }

    private fun getModalW(): Int {
        val reactContext: ReactContext = UIManagerHelper.getReactContext(this@Wrapper)
        return ModalHostHelper.getModalHostSize(reactContext).x
    }

    private fun playNewHeightAnimation(oldH: Int, newH: Int) {
        animator?.let {
            it.cancel()
            it.removeAllListeners()
        }
        ValueAnimator.ofInt(oldH, newH).also {
            it.duration = 250L
            it.addUpdateListener { animator ->
                val h = animator.animatedValue as Int
                this@Wrapper.reactHeight = h
                layoutParams = layoutParams.also { it.height = h }
            }
            it.finalListener {
                it.removeAllListeners()
                it.removeAllUpdateListeners()
            }
        }.start()
    }

    private fun releaseReactView() {
        animator?.let {
            it.removeAllListeners()
            it.removeAllUpdateListeners()
        }
        reactView = null
    }
}
