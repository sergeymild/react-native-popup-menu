package com.reactnativepopupmenu.sheet

import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.PixelUtil
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

class AppFittedSheetModule: ViewGroupManager<AppFittedSheet>() {
  override fun getName(): String {
    return "AppFitterSheet"
  }

  override fun createViewInstance(reactContext: ThemedReactContext): AppFittedSheet {
    return AppFittedSheet(reactContext)
  }

  @ReactProp(name = "sheetSize")
  fun sheetSize(view: AppFittedSheet, size: Double) {
    view.sheetSize = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  @ReactProp(name = "sheetMaxWidthSize")
  fun sheetMaxWidthSize(view: AppFittedSheet, size: Double) {
    view.sheetMaxWidthSize = PixelUtil.toPixelFromDIP(size).toDouble()
  }

  override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
    return MapBuilder.builder<String, Any>()
      .put("onDismiss", MapBuilder.of("registrationName", "onDismiss"))
      .build()
  }

  override fun onAfterUpdateTransaction(view: AppFittedSheet) {
    super.onAfterUpdateTransaction(view)
    view.showOrUpdate()
  }
}
