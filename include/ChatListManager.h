#import <Foundation/Foundation.h>

#define KEY @"ChatList"

@interface ChatListManager : NSObject {
 @private
  NSMutableDictionary *dict;
 @protected
 @public
}
- (void)addChatName:(NSString *)name
            withKey:(NSString *)key;

-(int) getChatTotal;

- (NSMutableDictionary *)getChatList;

-(NSString *)getChatNameByKey: (NSString *)key;

- (NSString *)getChatNameByOffset:(int)offset;
@end