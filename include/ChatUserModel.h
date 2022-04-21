#import <Foundation/Foundation.h>

@interface ChatUserModel : NSObject {
 @public
  NSString *_user_id;
  NSString *_user_nickname;
}
@property(nonatomic, copy) NSString *user_id;
@property(nonatomic, copy) NSString *user_nickname;

@end