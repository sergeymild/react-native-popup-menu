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
RCT_EXPORT_VIEW_PROPERTY(onDismiss, RCTBubblingEventBlock)
RCT_EXTERN_METHOD(dismiss)


@end
