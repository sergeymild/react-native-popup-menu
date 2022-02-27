#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>

@interface RCT_EXTERN_MODULE(PopupMenu, NSObject)

RCT_EXTERN_METHOD(showPopup:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(configurePopup:(NSDictionary *)options)

@end


@interface RCT_EXTERN_MODULE(AppFitterSheet, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(dismissKeyboardOnScroll, BOOL)
RCT_EXPORT_VIEW_PROPERTY(sheetSize, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(sheetMaxWidthSize, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(increaseHeight, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(decreaseHeight, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(onSheetDismiss, RCTBubblingEventBlock)
RCT_EXTERN_METHOD(dismiss)
@end


@interface RCT_EXTERN_MODULE(ScalePressViewManager, RCTViewManager)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLongPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(scale, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(durationIn, NSNumber)
RCT_EXPORT_VIEW_PROPERTY(durationOut, NSNumber)
@end
