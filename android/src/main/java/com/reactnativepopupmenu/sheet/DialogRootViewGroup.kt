package com.reactnativepopupmenu.sheet

import android.content.Context
import android.os.Handler
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import androidx.annotation.UiThread
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.UIManagerHelper.getReactContext
import com.facebook.react.uimanager.events.EventDispatcher
import com.facebook.react.views.view.ReactViewGroup

internal class DialogRootViewGroup(context: Context?) : ReactViewGroup(context), RootView {
    private var hasAdjustedSize = false
    private var viewWidth = 0
    private var viewHeight = 0
    private var mStateWrapper: StateWrapper? = null
    private val mJSTouchDispatcher = JSTouchDispatcher(this)
    private var reactHeight: Int = -1

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        viewWidth = w
        viewHeight = h
        updateFirstChildView()
    }

    private fun updateFirstChildView() {
        if (childCount > 0) {
            hasAdjustedSize = false
            if (mStateWrapper != null) {
                // This will only be called under Fabric
                updateState(mStateWrapper, viewWidth, viewHeight)
            } else {
                // TODO: T44725185 remove after full migration to Fabric
//        ReactContext reactContext = getReactContext();
//        reactContext.runOnNativeModulesQueueThread(
//          new GuardedRunnable(reactContext) {
//            @Override
//            public void runGuarded() {
//              (getReactContext())
//                .getNativeModule(UIManagerModule.class)
//                .updateNodeSize(viewTag, viewWidth, viewHeight);
//            }
//          });
            }
        } else {
            hasAdjustedSize = true
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        println("🔦 222 reactHeight ${reactHeight}")
        if (reactHeight > -1) {
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), reactHeight)
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        }
    }

    @UiThread
    fun updateState(stateWrapper: StateWrapper?, width: Int, height: Int) {
        mStateWrapper = stateWrapper
        val map: WritableMap = WritableNativeMap()
        map.putDouble("screenWidth", PixelUtil.toDIPFromPixel(width.toFloat()).toDouble())
        map.putDouble("screenHeight", PixelUtil.toDIPFromPixel(height.toFloat()).toDouble())
        //stateWrapper.updateState(map);
    }

    override fun addView(child: View, index: Int, params: LayoutParams) {
        super.addView(child, index, params)
        //    // call only if peekHeight is not zero
//    if (FragmentModalBottomSheetKt.getPublicPeekHeight() > 0) {
//      ReactNativeReflection.setSize(getChildAt(0), getReactContext());
//    }
        //    // call only if peekHeight is not zero
//    if (FragmentModalBottomSheetKt.getPublicPeekHeight() > 0) {
//      ReactNativeReflection.setSize(getChildAt(0), getReactContext());
//    }
        child.viewTreeObserver.addOnPreDrawListener(object :
            ViewTreeObserver.OnPreDrawListener {
            override fun onPreDraw(): Boolean {
                child.viewTreeObserver.removeOnPreDrawListener(this)
                Handler().postDelayed({
                    val reactContext: ReactContext =
                        UIManagerHelper.getReactContext(this@DialogRootViewGroup)
                    val modalSize = ModalHostHelper.getModalHostSize(reactContext)
                    val newHeight = child.measuredHeight
                    println("🔦 111 ${newHeight}")
                    this@DialogRootViewGroup.reactHeight = newHeight
                    ReactNativeReflection.setSize(child, modalSize.x, newHeight)
//                    this@DialogRootViewGroup.forceLayout()
//                    this@DialogRootViewGroup.requestLayout()
                    this@DialogRootViewGroup.requestLayout()
                }, 1500)
                return true
            }
        })
    }

    override fun handleException(t: Throwable) {
        reactContext.handleException(RuntimeException(t))
    }

    private val reactContext: ReactContext
        private get() = context as ReactContext

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

    override fun onChildStartedNativeGesture(androidEvent: MotionEvent) {
        mJSTouchDispatcher.onChildStartedNativeGesture(androidEvent, eventDispatcher)
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
}
