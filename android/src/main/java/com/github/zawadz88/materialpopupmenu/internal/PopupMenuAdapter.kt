package com.github.zawadz88.materialpopupmenu.internal

import android.annotation.SuppressLint
import android.content.res.ColorStateList
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.annotation.CallSuper
import androidx.appcompat.widget.AppCompatImageView
import androidx.recyclerview.widget.RecyclerView
import com.github.zawadz88.materialpopupmenu.MaterialPopupMenu
import com.github.zawadz88.materialpopupmenu.appearance
import com.reactnativepopupmenu.R

/**
 * RecyclerView adapter used for displaying popup menu items grouped in sections.
 *
 * @author Piotr Zawadzki
 */
@SuppressLint("RestrictedApi")
internal class PopupMenuAdapter(
  private val sections: List<MaterialPopupMenu.PopupMenuSection>,
  private val dismissPopupCallback: () -> Unit
) :
  SectionedRecyclerViewAdapter<PopupMenuAdapter.SectionHeaderViewHolder, PopupMenuAdapter.AbstractItemViewHolder>() {

  init {
    setHasStableIds(false)
  }

  override fun getItemCountForSection(section: Int): Int {
    return sections[section].items.size
  }

  override val sectionCount: Int
    get() = sections.size

  override fun onCreateSectionHeaderViewHolder(
    parent: ViewGroup,
    viewType: Int
  ): SectionHeaderViewHolder {
    val v = LayoutInflater.from(parent.context)
      .inflate(R.layout.mpm_popup_menu_section_header, parent, false)
    return SectionHeaderViewHolder(v)
  }

  override fun getSectionItemViewType(section: Int, position: Int): Int {
    return when (val popupMenuItem = sections[section].items[position]) {
      is MaterialPopupMenu.PopupMenuCustomItem -> popupMenuItem.layoutResId
      else -> super.getSectionItemViewType(section, position)
    }
  }

  override fun onCreateItemViewHolder(parent: ViewGroup, viewType: Int): AbstractItemViewHolder {
    return if (viewType == TYPE_ITEM) {
      val v =
        LayoutInflater.from(parent.context).inflate(R.layout.mpm_popup_menu_item, parent, false)
      ItemViewHolder(v)
    } else {
      val v = LayoutInflater.from(parent.context).inflate(viewType, parent, false)
      CustomItemViewHolder(v)
    }
  }

  override fun onBindSectionHeaderViewHolder(
    holder: SectionHeaderViewHolder,
    sectionPosition: Int
  ) {
    val title = sections[sectionPosition].title
    if (title != null) {
      holder.label.visibility = View.VISIBLE
      holder.label.text = title
    } else {
      holder.label.visibility = View.GONE
    }

    holder.separator.visibility = if (sectionPosition == 0) View.GONE else View.VISIBLE
  }

  override fun onBindItemViewHolder(holder: AbstractItemViewHolder, section: Int, position: Int) {
    val popupMenuItem = sections[section].items[position]
    holder.bindItem(popupMenuItem)
    holder.itemView.setOnClickListener {
      popupMenuItem.callback()
      if (popupMenuItem.dismissOnSelect) {
        dismissPopupCallback()
      }
    }
  }

  internal abstract class AbstractItemViewHolder(
    itemView: View
  ) : RecyclerView.ViewHolder(itemView) {

    @CallSuper
    open fun bindItem(popupMenuItem: MaterialPopupMenu.AbstractPopupMenuItem) {
      popupMenuItem.viewBoundCallback.invoke(itemView)
    }
  }

  internal class ItemViewHolder(itemView: View) :
    AbstractItemViewHolder(itemView) {

    private var label: TextView = itemView.findViewById(R.id.mpm_popup_menu_item_label)

    private var icon: AppCompatImageView = itemView.findViewById(R.id.mpm_popup_menu_item_icon)
    private var rightIcon: AppCompatImageView =
      itemView.findViewById(R.id.mpm_popup_menu_item_right_icon)

    private var nestedIcon: AppCompatImageView =
      itemView.findViewById(R.id.mpm_popup_menu_item_nested_icon)

    private var content: View = itemView.findViewById(R.id.content)
    private var separator: View = itemView.findViewById(R.id.mpm_popup_menu_section_separator)

    override fun bindItem(popupMenuItem: MaterialPopupMenu.AbstractPopupMenuItem) {
      content.setPaddingRelative(
        appearance.popMenuActionPaddingHorizontal.toInt(),
        0,
        appearance.popMenuActionPaddingHorizontal.toInt(),
        0
      )
      content.layoutParams.height = appearance.itemHeight.toInt()
      label.setTextSize(TypedValue.COMPLEX_UNIT_SP, appearance.itemFontSize)
      rightIcon.layoutParams.width = appearance.popMenuActionIconSize.toInt()
      rightIcon.layoutParams.height = appearance.popMenuActionIconSize.toInt()
      icon.layoutParams.width = appearance.popMenuActionIconSize.toInt()
      icon.layoutParams.height = appearance.popMenuActionIconSize.toInt()


      val castedPopupMenuItem = popupMenuItem as MaterialPopupMenu.PopupMenuItem
      if (castedPopupMenuItem.label != null) {
        label.text = castedPopupMenuItem.label
      }
      if (castedPopupMenuItem.iconDrawable != null) {
        icon.apply {
          visibility = View.VISIBLE
          setImageDrawable(castedPopupMenuItem.iconDrawable)
          if (castedPopupMenuItem.iconColor != 0) {
            supportImageTintList = ColorStateList.valueOf(castedPopupMenuItem.iconColor)
          }
        }
      } else {
        icon.visibility = View.GONE
      }

      if (castedPopupMenuItem.rightIconDrawable != null) {
        rightIcon.apply {
          visibility = View.VISIBLE
          setImageDrawable(castedPopupMenuItem.rightIconDrawable)
          if (castedPopupMenuItem.iconColor != 0) {
            supportImageTintList = ColorStateList.valueOf(castedPopupMenuItem.iconColor)
          }
        }
      } else {
        rightIcon.visibility = View.GONE
      }
      if (castedPopupMenuItem.labelColor != 0) {
        label.setTextColor(castedPopupMenuItem.labelColor)
      }
      nestedIcon.visibility = if (castedPopupMenuItem.hasNestedItems) View.VISIBLE else View.GONE

//      if (castedPopupMenuItem.showSeparator) {
//        separator.visibility = View.VISIBLE
//        separator.setBackgroundColor(castedPopupMenuItem.separatorColor)
//        separator.layoutParams.height = castedPopupMenuItem.separatorHeight
//      } else {
//      }
      separator.visibility = View.GONE

      super.bindItem(popupMenuItem)
    }
  }

  internal class CustomItemViewHolder(itemView: View) :
    AbstractItemViewHolder(itemView)

  internal class SectionHeaderViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
    var label: TextView = itemView.findViewById(R.id.mpm_popup_menu_section_header_label)
    var separator: View = itemView.findViewById(R.id.mpm_popup_menu_section_separator)
  }
}
