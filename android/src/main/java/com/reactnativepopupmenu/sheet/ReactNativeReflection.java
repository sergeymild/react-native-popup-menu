package com.reactnativepopupmenu.sheet;

import android.util.SparseArray;
import android.view.View;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.NativeViewHierarchyOptimizer;
import com.facebook.react.uimanager.OnLayoutEvent;
import com.facebook.react.uimanager.ReactShadowNode;
import com.facebook.react.uimanager.ShadowNodeRegistry;
import com.facebook.react.uimanager.UIImplementation;
import com.facebook.react.uimanager.UIManagerHelper;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.UIViewOperationQueue;
import com.facebook.react.uimanager.events.EventDispatcher;

import java.lang.reflect.Field;

public class ReactNativeReflection {
  static Class<? extends UIImplementation> uiImplementationClass;
  static UIImplementation uiImplementation;
  static UIViewOperationQueue uiViewOperationQueue;
  static NativeViewHierarchyOptimizer nativeViewHierarchyOptimizer;
  static EventDispatcher eventDispatcher;
  static UIImplementation.LayoutUpdateListener layoutUpdateListener;
  static SparseArray<ReactShadowNode> shadowNodeSparseArray;
  static boolean isInitialized = false;

  static void initialize(ReactContext context) throws NoSuchFieldException, IllegalAccessException {
    if (isInitialized) return;
    uiImplementation = getUiImplementation(context);
    uiImplementationClass = uiImplementation.getClass();

    String name = uiImplementationClass.getName();
    while (!name.equals("com.facebook.react.uimanager.UIImplementation") && !name.equals("java.lang.Object") && uiImplementationClass != null) {
      uiImplementationClass = (Class<? extends UIImplementation>) uiImplementationClass.getSuperclass();
      name = uiImplementationClass.getName();
    }

    uiViewOperationQueue = getUiViewOperationQueue();
    nativeViewHierarchyOptimizer = getNativeViewHierarchyOptimizer();
    eventDispatcher = getEventDispatcher();
    layoutUpdateListener = getLayoutUpdateListener();
    shadowNodeSparseArray = getShadowNodeRegistryClass();
    isInitialized = true;
  }


  static UIImplementation getUiImplementation(ReactContext context) {
    return context.getNativeModule(UIManagerModule.class).getUIImplementation();
  }

  static UIViewOperationQueue getUiViewOperationQueue() throws NoSuchFieldException, IllegalAccessException {
    Field mOperationsQueue = uiImplementationClass.getDeclaredField("mOperationsQueue");
    mOperationsQueue.setAccessible(true);
    return (UIViewOperationQueue) mOperationsQueue.get(uiImplementation);
  }

  static NativeViewHierarchyOptimizer getNativeViewHierarchyOptimizer() throws NoSuchFieldException, IllegalAccessException {
    Field mNativeViewHierarchyOptimizerField = uiImplementationClass.getDeclaredField("mNativeViewHierarchyOptimizer");
    mNativeViewHierarchyOptimizerField.setAccessible(true);
    return (NativeViewHierarchyOptimizer) mNativeViewHierarchyOptimizerField.get(uiImplementation);
  }

  static EventDispatcher getEventDispatcher() throws IllegalAccessException, NoSuchFieldException {
    Field mEventDispatcher = uiImplementationClass.getDeclaredField("mEventDispatcher");
    mEventDispatcher.setAccessible(true);
    return (EventDispatcher) mEventDispatcher.get(uiImplementation);
  }

  static UIImplementation.LayoutUpdateListener getLayoutUpdateListener() throws NoSuchFieldException, IllegalAccessException {
    Field mLayoutUpdateListener = uiImplementationClass.getDeclaredField("mLayoutUpdateListener");
    mLayoutUpdateListener.setAccessible(true);
    return (UIImplementation.LayoutUpdateListener) mLayoutUpdateListener.get(uiImplementation);
  }

  static SparseArray<ReactShadowNode> getShadowNodeRegistryClass() throws NoSuchFieldException, IllegalAccessException {
    Field mShadowNodeRegistryField = uiImplementationClass.getDeclaredField("mShadowNodeRegistry");
    mShadowNodeRegistryField.setAccessible(true);
    ShadowNodeRegistry shadowNodeRegistry = (ShadowNodeRegistry) mShadowNodeRegistryField.get(uiImplementation);
    Class<? extends ShadowNodeRegistry> shadowNodeRegistryClass = shadowNodeRegistry.getClass();

    Field mTagsToCSSNodes = shadowNodeRegistryClass.getDeclaredField("mTagsToCSSNodes");
    mTagsToCSSNodes.setAccessible(true);
    return (SparseArray<ReactShadowNode>) mTagsToCSSNodes.get(shadowNodeRegistry);
  }


//  static void setSize(View view, ReactContext reactContext) {
//    final int viewTag = view.getId();
//    Point modalHostSize = ModalHostHelper.getModalHostSize(reactContext);
//    ReactShadowNode reactShadowNode = shadowNodeSparseArray.get(viewTag);
//    reactShadowNode.setStyleWidth(modalHostSize.x);
//    reactShadowNode.setStyleHeight((int) FragmentModalBottomSheetKt.getPublicPeekHeight());
//    applyUpdatesRecursive(reactShadowNode, ReactNativeReflection.uiViewOperationQueue, ReactNativeReflection.nativeViewHierarchyOptimizer, ReactNativeReflection.eventDispatcher, 0f, 0f);
//
//    ReactNativeReflection.eventDispatcher.dispatchEvent(
//      OnLayoutEvent.obtain(
//        viewTag,
//        reactShadowNode.getScreenX(),
//        reactShadowNode.getScreenY(),
//        reactShadowNode.getScreenWidth(),
//        reactShadowNode.getScreenHeight()));
//    if (ReactNativeReflection.layoutUpdateListener != null) {
//      ReactNativeReflection.layoutUpdateListener.onLayoutUpdated(reactShadowNode);
//    }
//  }

  static void setSize(View view, int width, int height) {
    final int viewTag = view.getId();
    ReactShadowNode reactShadowNode = shadowNodeSparseArray.get(viewTag);
    reactShadowNode.setStyleWidth(width);
    reactShadowNode.setStyleHeight(height);
    applyUpdatesRecursive(reactShadowNode, ReactNativeReflection.uiViewOperationQueue, ReactNativeReflection.nativeViewHierarchyOptimizer, ReactNativeReflection.eventDispatcher, 0f, 0f);

    ReactNativeReflection.eventDispatcher.dispatchEvent(
      OnLayoutEvent.obtain(
        viewTag,
        reactShadowNode.getScreenX(),
        reactShadowNode.getScreenY(),
        reactShadowNode.getScreenWidth(),
        reactShadowNode.getScreenHeight()));
    if (ReactNativeReflection.layoutUpdateListener != null) {
      ReactNativeReflection.layoutUpdateListener.onLayoutUpdated(reactShadowNode);
    }
  }

  static void applyUpdatesRecursive(
    ReactShadowNode cssNode,
    UIViewOperationQueue uiViewOperationQueue,
    NativeViewHierarchyOptimizer nativeViewHierarchyOptimizer,
    EventDispatcher eventDispatcher,
    float absoluteX,
    float absoluteY
  ) {
    if (!cssNode.hasUpdates()) {
      return;
    }

    Iterable<? extends ReactShadowNode> cssChildren = cssNode.calculateLayoutOnChildren();
    if (cssChildren != null) {
      for (ReactShadowNode cssChild : cssChildren) {
        applyUpdatesRecursive(
          cssChild, uiViewOperationQueue, nativeViewHierarchyOptimizer, eventDispatcher, absoluteX + cssNode.getLayoutX(), absoluteY + cssNode.getLayoutY());
      }
    }

    int tag = cssNode.getReactTag();
    boolean frameDidChange =
      cssNode.dispatchUpdates(
        absoluteX, absoluteY, uiViewOperationQueue, nativeViewHierarchyOptimizer);
    if (frameDidChange && cssNode.shouldNotifyOnLayout()) {
      eventDispatcher.dispatchEvent(
        OnLayoutEvent.obtain(
          tag,
          cssNode.getScreenX(),
          cssNode.getScreenY(),
          cssNode.getScreenWidth(),
          cssNode.getScreenHeight()));
    }

    cssNode.markUpdateSeen();
  }
}
