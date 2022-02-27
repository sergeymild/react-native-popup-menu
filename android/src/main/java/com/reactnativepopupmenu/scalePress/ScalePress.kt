package com.reactnativepopupmenu.scalePress

import android.content.Context
import android.view.MotionEvent
import android.view.View
import com.facebook.react.views.view.ReactViewGroup
import android.graphics.Rect
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter


class ScalePress(context: Context?) : ReactViewGroup(context), View.OnTouchListener {
  init {
    setOnTouchListener(this)
  }

  var isAnimating = false
  var scale: Float = 0.9f
  var durationIn: Long = 500L
  var durationOut: Long = 500L
  private val emptyMap
    get() = Arguments.createMap()
  private val eventEmitter = (context as ReactContext).getJSModule(RCTEventEmitter::class.java)

  private fun isViewInBounds(view: View, x: Float, y: Float): Boolean {
    val outRect = Rect()
    val location = IntArray(2)
    view.getDrawingRect(outRect)
    view.getLocationOnScreen(location)
    outRect.offset(location[0], location[1])
    return outRect.contains(x.toInt(), y.toInt())
  }

  override fun onTouch(v: View?, event: MotionEvent?): Boolean {
    v ?: return false
    if (isAnimating) return false
    val action = event?.action ?: return false
    when(action) {
      MotionEvent.ACTION_DOWN -> {
        v.animate()
          .scaleX(scale)
          .scaleY(scale)
          .setDuration(durationIn)
          .withEndAction { isAnimating = false }
          .start()
      }
      MotionEvent.ACTION_CANCEL,
      MotionEvent.ACTION_UP -> {
        if (isViewInBounds(this, event.rawX, event.rawY)) {
          eventEmitter.receiveEvent(id, "onPress", emptyMap)
        }

        v.animate()
          .scaleX(1f)
          .scaleY(1f)
          .setDuration(durationOut)
          .withEndAction { isAnimating = false }
          .start()
      }
    }
    return false
  }
}
