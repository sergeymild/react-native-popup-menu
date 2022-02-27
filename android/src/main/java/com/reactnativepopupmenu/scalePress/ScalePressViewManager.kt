package com.reactnativepopupmenu.scalePress

import androidx.annotation.Nullable
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.annotations.ReactPropGroup
import com.facebook.react.views.view.ReactClippingViewManager
import com.facebook.react.views.view.ReactViewManager
import com.facebook.react.uimanager.PixelUtil

import com.facebook.yoga.YogaConstants

import com.facebook.react.views.view.ReactViewGroup

import com.facebook.react.uimanager.ViewProps
import com.facebook.react.uimanager.Spacing


class ScalePressViewManager : ReactClippingViewManager<ScalePress>() {
  override fun getName(): String {
    return "ScalePressView"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): ScalePress {
    return ScalePress(reactContext)
  }

  private val SPACING_TYPES = intArrayOf(
    Spacing.ALL,
    Spacing.LEFT,
    Spacing.RIGHT,
    Spacing.TOP,
    Spacing.BOTTOM,
    Spacing.START,
    Spacing.END)

  @ReactProp(name = "scale")
  fun scale(view: ScalePress, scale: Double) {
    view.scale = scale.toFloat()
  }

  @ReactProp(name = "longPressEnabled")
  fun setOnLongPress(view: ScalePress, enabled: Boolean) {
    view.gestureDetector.setIsLongpressEnabled(enabled)
  }

  @ReactProp(name = "durationIn")
  fun durationIn(view: ScalePress, durationIn: Double) {
    view.durationIn = durationIn.toLong()
  }

  @ReactProp(name = "durationOut")
  fun durationOut(view: ScalePress, durationOut: Double) {
    view.durationOut = durationOut.toLong()
  }

  @ReactPropGroup(names = [ViewProps.BORDER_RADIUS, ViewProps.BORDER_TOP_LEFT_RADIUS, ViewProps.BORDER_TOP_RIGHT_RADIUS, ViewProps.BORDER_BOTTOM_RIGHT_RADIUS, ViewProps.BORDER_BOTTOM_LEFT_RADIUS, ViewProps.BORDER_TOP_START_RADIUS, ViewProps.BORDER_TOP_END_RADIUS, ViewProps.BORDER_BOTTOM_START_RADIUS, ViewProps.BORDER_BOTTOM_END_RADIUS], defaultFloat = YogaConstants.UNDEFINED)
  fun setBorderRadius(view: ReactViewGroup, index: Int, borderRadius: Float) {
    var borderRadius = borderRadius
    if (!YogaConstants.isUndefined(borderRadius) && borderRadius < 0) {
      borderRadius = YogaConstants.UNDEFINED
    }
    if (!YogaConstants.isUndefined(borderRadius)) {
      borderRadius = PixelUtil.toPixelFromDIP(borderRadius)
    }
    if (index == 0) {
      view.setBorderRadius(borderRadius)
    } else {
      view.setBorderRadius(borderRadius, index - 1)
    }
  }

  @ReactProp(name = "borderStyle")
  fun setBorderStyle(view: ReactViewGroup, @Nullable borderStyle: String?) {
    view.setBorderStyle(borderStyle)
  }

  @ReactPropGroup(names = [ViewProps.BORDER_WIDTH, ViewProps.BORDER_LEFT_WIDTH, ViewProps.BORDER_RIGHT_WIDTH, ViewProps.BORDER_TOP_WIDTH, ViewProps.BORDER_BOTTOM_WIDTH, ViewProps.BORDER_START_WIDTH, ViewProps.BORDER_END_WIDTH], defaultFloat = YogaConstants.UNDEFINED)
  fun setBorderWidth(view: ReactViewGroup, index: Int, width: Float) {
    var width = width
    if (!YogaConstants.isUndefined(width) && width < 0) {
      width = YogaConstants.UNDEFINED
    }
    if (!YogaConstants.isUndefined(width)) {
      width = PixelUtil.toPixelFromDIP(width)
    }
    view.setBorderWidth(SPACING_TYPES[index], width)
  }

  @ReactPropGroup(names = [ViewProps.BORDER_COLOR, ViewProps.BORDER_LEFT_COLOR, ViewProps.BORDER_RIGHT_COLOR, ViewProps.BORDER_TOP_COLOR, ViewProps.BORDER_BOTTOM_COLOR, ViewProps.BORDER_START_COLOR, ViewProps.BORDER_END_COLOR], customType = "Color")
  fun setBorderColor(view: ReactViewGroup, index: Int, color: Int?) {
    val rgbComponent = if (color == null) YogaConstants.UNDEFINED else (color and 0x00FFFFFF).toFloat()
    val alphaComponent = if (color == null) YogaConstants.UNDEFINED else (color ushr 24).toFloat()
    view.setBorderColor(SPACING_TYPES[index], rgbComponent, alphaComponent)
  }

  @ReactProp(name = ViewProps.OVERFLOW)
  fun setOverflow(view: ReactViewGroup, overflow: String?) {
    view.overflow = overflow
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
    return MapBuilder.builder<String, Any>()
      .put("onPress", MapBuilder.of("registrationName", "onPress"))
      .put("onLongPress", MapBuilder.of("registrationName", "onLongPress"))
      .build()
  }
}
