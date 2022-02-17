package com.reactnativepopupmenu.sheet

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.*
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.yoga.YogaMeasureFunction
import com.facebook.yoga.YogaMeasureOutput
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
    return AppFittedSheet(reactContext)
  }

  @ReactProp(name = "sheetSize")
  fun sheetSize(view: AppFittedSheet, size: Double) {
    println("🥲sheetSize")
    view.sheetSize = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  @ReactProp(name = "sheetMaxWidthSize")
  fun sheetMaxWidthSize(view: AppFittedSheet, size: Double) {
    println("🥲sheetMaxWidthSize")
    view.sheetMaxWidthSize = PixelUtil.toPixelFromDIP(size).toDouble()
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
