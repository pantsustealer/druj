#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject {
 @public
  NSString *_message_id;
  NSString *_user_id;
  NSString *_message;
  NSString *_timestamp;
}
@property(nonatomic, copy) NSString *message_id;
@property(nonatomic, copy) NSString *user_id;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, copy) NSString *timestamp;
@end