package com.reactnativepopupmenu.sheet;

import android.content.Context;
import android.graphics.Point;
import android.os.Handler;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.UiThread;

import com.facebook.react.bridge.GuardedRunnable;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.uimanager.JSTouchDispatcher;
import com.facebook.react.uimanager.NativeViewHierarchyOptimizer;
import com.facebook.react.uimanager.OnLayoutEvent;
import com.facebook.react.uimanager.PixelUtil;
import com.facebook.react.uimanager.ReactShadowNode;
import com.facebook.react.uimanager.RootView;
import com.facebook.react.uimanager.ShadowNodeRegistry;
import com.facebook.react.uimanager.StateWrapper;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.UIManagerModuleListener;
import com.facebook.react.uimanager.UIViewOperationQueue;
import com.facebook.react.uimanager.events.EventDispatcher;
import com.facebook.react.views.view.ReactViewGroup;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

class DialogRootViewGroup extends ReactViewGroup implements RootView {
  private boolean hasAdjustedSize = false;
  private int viewWidth;
  private int viewHeight;

  private @Nullable
  StateWrapper mStateWrapper;

  private final JSTouchDispatcher mJSTouchDispatcher = new JSTouchDispatcher(this);

  public DialogRootViewGroup(Context context) {
    super(context);
  }

  @Override
  protected void onSizeChanged(final int w, final int h, int oldw, int oldh) {
    super.onSizeChanged(w, h, oldw, oldh);
    viewWidth = w;
    viewHeight = h;
    updateFirstChildView();
  }

  private void updateFirstChildView() {
    if (getChildCount() > 0) {
      hasAdjustedSize = false;
      if (mStateWrapper != null) {
        // This will only be called under Fabric
        updateState(mStateWrapper, viewWidth, viewHeight);
      } else {
        // TODO: T44725185 remove after full migration to Fabric
//        ReactContext reactContext = getReactContext();
//        reactContext.runOnNativeModulesQueueThread(
//          new GuardedRunnable(reactContext) {
//            @Override
//            public void runGuarded() {
//              (getReactContext())
//                .getNativeModule(UIManagerModule.class)
//                .updateNodeSize(viewTag, viewWidth, viewHeight);
//            }
//          });
      }
    } else {
      hasAdjustedSize = true;
    }
  }

  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    System.out.println("dialogRootViewGroup.measure " + FragmentModalBottomSheetKt.getPublicPeekHeight() + " h: " + MeasureSpec.getSize(heightMeasureSpec));
    if (FragmentModalBottomSheetKt.getPublicPeekHeight() > 0 ) {
      super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec((int) FragmentModalBottomSheetKt.getPublicPeekHeight(), MeasureSpec.EXACTLY));
    } else {
      super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }
  }

  @UiThread
  public void updateState(StateWrapper stateWrapper, int width, int height) {
    mStateWrapper = stateWrapper;
    WritableMap map = new WritableNativeMap();
    map.putDouble("screenWidth", PixelUtil.toDIPFromPixel(width));
    map.putDouble("screenHeight", PixelUtil.toDIPFromPixel(height));
    //stateWrapper.updateState(map);
  }

  @Override
  public void addView(View child, int index, LayoutParams params) {
    super.addView(child, index, params);
    // call only if peekHeight is not zero
    if (FragmentModalBottomSheetKt.getPublicPeekHeight() > 0) {
      ReactNativeReflection.setSize(getChildAt(0), getReactContext());
    }
  }

  @Override
  public void handleException(Throwable t) {
    getReactContext().handleException(new RuntimeException(t));
  }

  private ReactContext getReactContext() {
    return (ReactContext) getContext();
  }

  @Override
  public boolean onInterceptTouchEvent(MotionEvent event) {
    mJSTouchDispatcher.handleTouchEvent(event, getEventDispatcher());
    return super.onInterceptTouchEvent(event);
  }

  @Override
  public boolean onTouchEvent(MotionEvent event) {
    mJSTouchDispatcher.handleTouchEvent(event, getEventDispatcher());
    super.onTouchEvent(event);
    // In case when there is no children interested in handling touch event, we return true from
    // the root view in order to receive subsequent events related to that gesture
    return true;
  }

  @Override
  public void onChildStartedNativeGesture(MotionEvent androidEvent) {
    mJSTouchDispatcher.onChildStartedNativeGesture(androidEvent, getEventDispatcher());
  }

  @Override
  public void requestDisallowInterceptTouchEvent(boolean disallowIntercept) {
    // No-op - override in order to still receive events to onInterceptTouchEvent
    // even when some other view disallow that
  }

  private EventDispatcher getEventDispatcher() {
    ReactContext reactContext = getReactContext();
    return reactContext.getNativeModule(UIManagerModule.class).getEventDispatcher();
  }
}
