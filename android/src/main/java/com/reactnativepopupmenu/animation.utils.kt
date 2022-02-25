package com.reactnativepopupmenu

import android.animation.Animator
import android.animation.ValueAnimator

fun ValueAnimator.finalListener(listener: () -> Unit) {
    addListener(object : Animator.AnimatorListener {
        override fun onAnimationStart(animation: Animator?) = Unit
        override fun onAnimationRepeat(animation: Animator?) = Unit
        override fun onAnimationEnd(animation: Animator?) = listener()
        override fun onAnimationCancel(animation: Animator?) = listener()
    })
}
