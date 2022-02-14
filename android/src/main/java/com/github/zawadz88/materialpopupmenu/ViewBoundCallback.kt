package com.github.zawadz88.materialpopupmenu

import android.view.View

/**
 * Callback to be invoked once the custom item view gets created and bound.
 * It is to be used when some views inside need to be updated once inflated.
 *
 * This class is an extension for closure based callback that provides
 * additional functionality such as dismissing popup.
 *
 * @param callback block of the callback in which you can bind the given view
 */
class ViewBoundCallback(
    private val callback: ViewBoundCallback.(View) -> Unit
) : (View) -> Unit {
    override fun invoke(view: View) {
        callback(view)
    }
}
