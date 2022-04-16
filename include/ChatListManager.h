#import <Foundation/Foundation.h>

#define KEY @"ChatList"

@interface ChatListManager : NSObject {
 @private
  NSMutableDictionary *dict;
 @protected
 @public
}
- (void)addChatName:(NSString *)name
             withId:(NSString *)id;

-(int) getChatTotal;

- (NSMutableDictionary *)getChatList;

- (NSString *)getChatNameByOffset:(int)offset;
@end