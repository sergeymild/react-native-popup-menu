package com.github.zawadz88.materialpopupmenu

import android.graphics.Color
import android.view.Gravity
import com.facebook.react.uimanager.PixelUtil

data class PopMenuAppearance(
  var cornerRadius: Float = PixelUtil.toPixelFromDIP(20f),
  var itemHeight: Float = PixelUtil.toPixelFromDIP(48f),
  var itemFontSize: Float = 17f,
  var popMenuActionIconSize: Float = PixelUtil.toPixelFromDIP(24f),
  var popMenuActionPaddingHorizontal: Float = PixelUtil.toPixelFromDIP(16f),
  var backgroundColor: Int = Color.WHITE,
  var popMenuGravity: Int = Gravity.NO_GRAVITY,
  var rightIcon: Boolean = true,
  var actionColor: Int = Color.BLACK,
  var separatorColor: Int = Color.parseColor("#1F000000"),
  var separatorHeight: Float = 0f
)

var appearance = PopMenuAppearance()
