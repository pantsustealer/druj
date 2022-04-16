#import <Foundation/Foundation.h>

#define KEY @"MessageList"

@interface ChatMessageManager : NSObject {
 @private
  NSMutableDictionary *threadDictionary;
 @protected
 @public
}

- (NSArray *)getMessagesForChatId:(NSString *)chat_id;

- (NSMutableArray *)getMessagesForChatId:(NSString *)chat_id
                                   count:(int)count;

- (void)addMessage:(NSString *)message
         forChatId:(NSString *)chat_id
        withUserId:(NSString *)user_id
      andMessageId:(NSString *)message_id
      andTimestamp:(NSString *)timestamp;
@end