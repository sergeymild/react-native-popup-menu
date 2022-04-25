package com.reactnativepopupmenu.sheet

import android.animation.ValueAnimator
import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewTreeObserver
import android.widget.FrameLayout
import androidx.core.view.ViewCompat
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.events.EventDispatcher
import com.facebook.react.views.scroll.ReactScrollView
import com.facebook.react.views.view.ReactViewGroup
import com.reactnativepopupmenu.finalListener
import kotlin.math.min

class Wrapper(context: Context) : ReactViewGroup(context), RootView {

  private val reactContext: ReactContext
    private get() = context as ReactContext
  private val mJSTouchDispatcher = JSTouchDispatcher(this)
  private var animator: ValueAnimator? = null
  private val eventDispatcher: EventDispatcher
    private get() {
      val reactContext = reactContext
      return reactContext.getNativeModule(UIManagerModule::class.java)!!.eventDispatcher
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

  var sheetMaxWidthSize: Double = -1.0
  var sheetMaxHeightSize: Double = -1.0
  private val screenHeight: Int
    get() = context.resources.displayMetrics.heightPixels

  private val allowedHeight: Int
    get() {
      if (sheetMaxHeightSize == -1.0) {
        if (reactHeight != -1 && reactHeight <= screenHeight) {
          reactView?.let { ViewCompat.setNestedScrollingEnabled(it, false) }
        }
        return min(reactHeight, screenHeight)
      }

      if (reactHeight != -1 && reactHeight <= sheetMaxHeightSize.toInt()) {
        reactView?.let { ViewCompat.setNestedScrollingEnabled(it, false) }
      }
      return min(sheetMaxHeightSize.toInt(), reactHeight)
    }

  private var pendingHeight: Int? = null
  var reactHeight: Int = -1

  val isReactViewAttached: Boolean
    get() = reactView?.parent != null

  fun setVirtualHeight(h: Int) {
    println("😀 setVirtualHeight $h $reactView")
    if (reactView == null) {
      pendingHeight = h
      return
    }
    pendingHeight = null

    if (h < 0) { // TODO What todo?
      this@Wrapper.reactHeight = h
      return
    }
    this@Wrapper.reactHeight = h
    val w = getModalW()
    println("😀 ReactNativeReflection.setSize $allowedHeight")
    //TODO check that h must be lower sheetMaxHeightSize or screenHeight
    ReactNativeReflection.setSize(reactView, w, allowedHeight)
    println("😀 ReactNativeReflection.setSizeAfter $reactView")
    val oldH = layoutParams.height
    if (oldH < 0) {
      layoutParams = FrameLayout.LayoutParams(w, allowedHeight)
    } else {
      playNewHeightAnimation(oldH = oldH, newH = allowedHeight)
    }
  }

  override fun addView(child: View, index: Int, params: LayoutParams) {
    println("😀 addView $child")
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
    println("😀 onMeasure $allowedHeight")
    if (allowedHeight > -1) {
      super.onMeasure(
        widthMeasureSpec,
        MeasureSpec.makeMeasureSpec(allowedHeight, MeasureSpec.EXACTLY)
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
    println("😀 applyPendingHeight $allowedHeight $reactHeight")
    ReactNativeReflection.setSize(reactView, w, allowedHeight)
    layoutParams = FrameLayout.LayoutParams(w, allowedHeight)
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
    println("😀 releaseReactView " + reactView?.height)
    animator?.let {
      it.removeAllListeners()
      it.removeAllUpdateListeners()
    }
    sheetMaxHeightSize = -1.0
    sheetMaxWidthSize = -1.0
    pendingHeight = null
    reactHeight = -1
    reactView = null
  }
}
