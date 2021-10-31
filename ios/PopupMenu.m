#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PopupMenu, NSObject)

RCT_EXTERN_METHOD(showPopup:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback)

@end
