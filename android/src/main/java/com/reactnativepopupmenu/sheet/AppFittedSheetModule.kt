package com.reactnativepopupmenu.sheet

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.yoga.YogaPositionType

internal class ModalHostShadowNode : LayoutShadowNode() {
  /**
   * We need to set the styleWidth and styleHeight of the one child (represented by the <View></View>
   * within the <RCTModalHostView></RCTModalHostView> in Modal.js. This needs to fill the entire window.
   */
  override fun addChildAt(child: ReactShadowNodeImpl, i: Int) {
    super.addChildAt(child, i)
    println("🥲shadowNode.addChildAt")
    val modalSize = ModalHostHelper.getModalHostSize(themedContext)
    child.setStyleWidth(modalSize.x.toFloat())
    //child.setStyleHeight(modalSize.y.toFloat())
    child.setPositionType(YogaPositionType.ABSOLUTE)
  }
}

class AppFittedSheetModule: ViewGroupManager<AppFittedSheet>() {

  override fun getName(): String {
    return "AppFitterSheet"
  }


  override fun createViewInstance(reactContext: ThemedReactContext): AppFittedSheet {
    ReactNativeReflection.initialize(reactContext);
    return AppFittedSheet(reactContext)
  }

  @ReactProp(name = "sheetSize")
  fun sheetSize(view: AppFittedSheet, size: Double) {
    println("🥲sheetSize $size")
    view.sheetSize = if (size < 0) -1 else PixelUtil.toPixelFromDIP(size).toInt()
  }

  @ReactProp(name = "increaseHeight")
  fun setIncreaseHeight(view: AppFittedSheet, by: Double) {
    if (by == 0.0) return
    val newHeight = view.mHostView.reactHeight + PixelUtil.toPixelFromDIP(by)
    println("🥲increaseHeight from: ${view.mHostView.reactHeight} to: $newHeight")
    view.sheetSize = newHeight.toInt()
  }

  @ReactProp(name = "decreaseHeight")
  fun setDecreaseHeight(view: AppFittedSheet, by: Double) {
    if (by == 0.0) return
    val newHeight = view.mHostView.reactHeight - PixelUtil.toPixelFromDIP(by)
    println("🥲decreaseHeight from: ${view.mHostView.reactHeight} to: $newHeight")
    view.sheetSize = newHeight.toInt()
  }

  @ReactProp(name = "sheetMaxWidthSize")
  fun sheetMaxWidthSize(view: AppFittedSheet, size: Double) {
    println("🥲sheetMaxWidthSize")
    view.sheetMaxWidthSize = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  @ReactProp(name = "sheetMaxHeightSize")
  fun sheetMaxHeightSize(view: AppFittedSheet, size: Double) {
    println("🥲sheetMaxHeightSize")
    view.sheetMaxHeightSize = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  @ReactProp(name = "topLeftRightCornerRadius")
  fun topLeftRightCornerRadius(view: AppFittedSheet, size: Double) {
    println("🥲topLeftRightCornerRadius")
    view.topLeftRightCornerRadius = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
    return MapBuilder.builder<String, Any>()
      .put("onSheetDismiss", MapBuilder.of("registrationName", "onSheetDismiss"))
      .build()
  }

  override fun getShadowNodeClass(): Class<out LayoutShadowNode> {
    return ModalHostShadowNode::class.java
  }

  override fun createShadowNodeInstance(): LayoutShadowNode {
    return ModalHostShadowNode()
  }

  override fun createShadowNodeInstance(context: ReactApplicationContext): LayoutShadowNode {
    println("🥲createShadowNodeInstance")
    return ModalHostShadowNode()
  }

  override fun onAfterUpdateTransaction(view: AppFittedSheet) {
    super.onAfterUpdateTransaction(view)
    view.showOrUpdate()
  }
}
