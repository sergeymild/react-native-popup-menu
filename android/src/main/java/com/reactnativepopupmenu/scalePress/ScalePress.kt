package com.reactnativepopupmenu.scalePress

import android.content.Context
import android.view.GestureDetector
import android.view.MotionEvent
import androidx.core.view.GestureDetectorCompat
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.facebook.react.views.view.ReactViewGroup


class ScalePress(context: Context?) : ReactViewGroup(context) {
  var isAnimating = false
  var scale: Float = 0.95f
  var durationIn: Long = 150L
  var durationOut: Long = 150L
  private val emptyMap
    get() = Arguments.createMap()
  private val eventEmitter = (context as ReactContext).getJSModule(RCTEventEmitter::class.java)

  val gestureDetector = GestureDetectorCompat(context, object : GestureDetector.SimpleOnGestureListener() {
    override fun onLongPress(e: MotionEvent) {
      scaleToNormal()
      eventEmitter.receiveEvent(id, "onLongPress", emptyMap)
    }

    override fun onSingleTapConfirmed(e: MotionEvent?): Boolean {
      scaleToNormal()
      return super.onSingleTapConfirmed(e)
    }

    override fun onSingleTapUp(e: MotionEvent?): Boolean {
      scaleToNormal()
      eventEmitter.receiveEvent(id, "onPress", emptyMap)
      return super.onSingleTapUp(e)
    }

    override fun onShowPress(e: MotionEvent?) {
      if (e?.action == MotionEvent.ACTION_DOWN) startPress()
      super.onShowPress(e)
    }
  })


  override fun onTouchEvent(event: MotionEvent): Boolean {
    return if (gestureDetector.onTouchEvent(event)) {
      true
    } else {
      scaleToNormal()
      super.onTouchEvent(event)
    }
  }


  private fun startPress() {
    if (isAnimating) return
    isAnimating = true
    animate()
      .scaleX(scale)
      .scaleY(scale)
      .setDuration(durationIn)
      .withEndAction { isAnimating = false }
      .start()
  }

  private fun scaleToNormal() {
    animate()
      .scaleX(1f)
      .scaleY(1f)
      .setDuration(durationOut)
      .withEndAction { isAnimating = false }
      .start()
  }
}
