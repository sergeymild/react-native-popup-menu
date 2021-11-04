package com.reactnativepopupmenu

import android.graphics.Color
import android.graphics.Rect
import android.view.Gravity
import android.view.View
import com.facebook.react.bridge.*
import com.facebook.react.uimanager.PixelUtil
import com.github.zawadz88.materialpopupmenu.appearance
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

  fun configure(options: ReadableMap) {
    if (options.hasKey("isIconsFromRight")) {
      val rightIcon = options.getBoolean("isIconsFromRight")
      appearance.rightIcon = rightIcon
    }

    if (options.hasKey("cornerRadius")) {
      appearance.cornerRadius = PixelUtil.toPixelFromDIP(options.getDouble("cornerRadius"))
    }

    if (options.hasKey("itemHeight")) {
      appearance.itemHeight = PixelUtil.toPixelFromDIP(options.getDouble("itemHeight"))
    }

    if (options.hasKey("itemFontSize")) {
      appearance.itemFontSize = options.getDouble("itemFontSize").toFloat()
    }

    if (options.hasKey("itemIconSize")) {
      appearance.popMenuActionIconSize = PixelUtil.toPixelFromDIP(options.getDouble("itemIconSize"))
    }

    if (options.hasKey("itemPaddingHorizontal")) {
      appearance.popMenuActionPaddingHorizontal = PixelUtil.toPixelFromDIP(options.getDouble("itemPaddingHorizontal"))
    }
  }

  @ReactMethod
  fun configurePopup(options: ReadableMap) {
    configure(options)

    if (options.hasKey("separatorHeight")) {
      appearance.separatorHeight = PixelUtil.toPixelFromDIP(options.getDouble("separatorHeight"))
    }

    if (options.hasKey("separatorColor") && reactApplicationContext != null) {
      appearance.separatorColor = options.color(reactApplicationContext!!, "separatorColor", Color.parseColor("#1F000000"))
    }

    if (options.hasKey("backgroundColor") && reactApplicationContext != null) {
      appearance.backgroundColor = options.color(reactApplicationContext!!, "backgroundColor", Color.parseColor("#1F000000"))
    }
  }

  @ReactMethod
  fun showPopup(params: ReadableMap, actionCallback: Callback) {
    val originalAppearance = appearance.copy()
    configure(params)
    val activity = reactApplicationContext?.currentActivity ?: return

    var s = R.style.Widget_MPM_Menu
    if (Helpers.isDarkMode(activity, params)) {
      s = R.style.Widget_MPM_Menu_Dark
    }

    var gravity = Gravity.NO_GRAVITY
    if (!params.hasKey("frame")) gravity = params.gravity()
    appearance.popMenuGravity = gravity
    var didDismissBySelectItem = false
    val popupMenu = popupMenu {
      style = s
      val buttons = params.getArray("buttons") ?: return@popupMenu
      section {
        for (i in 0 until buttons.size()) {
          val button = buttons.getMap(i) ?: continue
          val icon = Helpers.getIcon(activity, button.getString("icon"))
          val drawable = Helpers.toDrawable(activity, icon)

          var tint = appearance.actionColor
          if (button.hasKey("tint")) {
            tint = button.color(activity, "tint", Color.BLACK)
          }

          var sh = appearance.separatorHeight
          if (button.hasKey("separatorHeight")) {
            sh = PixelUtil.toPixelFromDIP(button.getDouble("separatorHeight"))
          }

          var sc = appearance.separatorColor
          if (button.hasKey("separatorColor")) {
            sc = button.color(activity, "separatorColor", appearance.separatorColor)
          }

          item {
            rightIconDrawable = if (appearance.rightIcon) drawable else null
            iconDrawable = if (!appearance.rightIcon) drawable else null
            iconColor = tint
            labelColor = tint
            label = button.getString("text")
            showSeparator = button.bool("showSeparator")
            separatorHeight = sh.toInt()
            separatorColor = sc
            callback = {
              didDismissBySelectItem = true
              actionCallback.invoke(i)
            }
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
        popupMenu.setOnDismissListener {
          if (!didDismissBySelectItem) actionCallback.invoke(null)
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
