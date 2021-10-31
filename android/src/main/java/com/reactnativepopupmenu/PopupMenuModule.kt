package com.reactnativepopupmenu

import android.graphics.Color
import android.graphics.Rect
import android.view.Gravity
import android.view.View
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.PixelUtil
import com.github.zawadz88.materialpopupmenu.popupMenu


class PopupMenuModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return "PopupMenu"
  }

  fun ReadableMap.gravity(): Int {
    return if (hasKey("gravity") && getString("gravity") == "top") {
      Gravity.TOP
    } else {
      Gravity.BOTTOM
    }
  }

  @ReactMethod
  fun showPopup(params: ReadableMap, actionCallback: Callback) {
    val activity = reactApplicationContext?.currentActivity ?: return

    val isIconsFromRight = params.bool("isIconsFromRight")
    val isDark = Helpers.isDarkMode(activity, params)
    var s = R.style.Widget_MPM_Menu
    if (Helpers.isDarkMode(activity, params)) {
      s = R.style.Widget_MPM_Menu_Dark
    }

    var gravity = Gravity.NO_GRAVITY
    if (!params.hasKey("frame")) {
      gravity = params.gravity()
    }
    val popupMenu = popupMenu {
      style = s
      dropdownGravity = gravity
      cornerRadius = params.double("cornerRadius", 20.0).toPixel()
      val buttons = params.getArray("buttons") ?: return@popupMenu
      section {
        for (i in 0 until buttons.size()) {
          val button = buttons.getMap(i) ?: continue
          val icon = Helpers.getIcon(activity, button.getString("icon"))
          val drawable = Helpers.toDrawable(activity, icon)
          var tint = if (isDark) Color.WHITE else Color.BLACK
          if (button.hasKey("tint")) {
            tint = ColorPropConverter.getColor(button.getDouble("tint"), activity)
          }
          item {
            rightIconDrawable = if (isIconsFromRight) drawable else null
            iconDrawable = if (!isIconsFromRight) drawable else null
            iconColor = tint
            labelColor = tint
            label = button.getString("text")
            callback = { actionCallback.invoke(i) }
          }
        }
      }
    }

    activity.runOnUiThread {
      fun create(anchor: View) {
        var rect: Rect? = null
        if (params.hasKey("frame")) {
          val frame = params.getMap("frame")!!
          var y = frame.getDouble("y").toPixel()
          if (params.gravity() == Gravity.BOTTOM) {
            y += frame.getDouble("height").toPixel()
          }
          y += Helpers.getStatusBarHeight(activity)
          rect = Rect(
            frame.getDouble("x").toPixel() + (16.0).toPixel(),
            y,
            0,
            0
          )
        }
        popupMenu.show(
          context = activity,
          anchor = anchor,
          location = rect
        )
      }
      if (params.hasKey("frame")) {
        create(activity.findViewById(android.R.id.content))
      } else {
        Helpers.findView(activity, params)?.let(::create)
      }
    }
  }


}
