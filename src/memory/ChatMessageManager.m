#import "../../include/ChatMessageManager.h"
#import "../../include/ChatMessageModel.h"

@implementation ChatMessageManager

- (id)init
{
  self = [super init];

  if (self != nil)
    {
      threadDictionary = [[NSThread mainThread] threadDictionary];

      if ([threadDictionary objectForKey:KEY] == nil)
        {
          [threadDictionary setObject:[[[NSMutableDictionary alloc] init] autorelease]
                               forKey:KEY];

        }
    }

  return self;
}

- (NSMutableArray *)getMessagesForChatId:(NSString *)chat_id
{
  NSMutableDictionary *thread = [threadDictionary objectForKey:KEY];
  NSMutableArray *messages = [thread objectForKey:chat_id];

  if (messages == nil)
    {
      [thread setObject:[[[NSMutableArray alloc] init] autorelease]
                 forKey:chat_id];
    }

  return messages;
}

- (NSMutableArray *)getMessagesForChatId:(NSString *)chat_id
                                   count:(int)count
{
  NSMutableArray *value = [[[self getMessagesForChatId:chat_id] mutableCopy] autorelease];

  NSRange endRange = NSMakeRange (value.count >= count ? value.count - count : 0, MIN(value.count, count));

  return [[[value subarrayWithRange:endRange] mutableCopy] autorelease];
}

- (void)addMessage:(NSString *)message
         forChatId:(NSString *)chat_id
        withUserId:(NSString *)user_id
      andMessageId:(NSString *)message_id
      andTimestamp:(NSString *)timestamp
{
  ChatMessageModel *chat_message = [[ChatMessageModel alloc] init];

  chat_message.message_id = message_id;
  chat_message.user_id = user_id;
  chat_message.message = message;
  chat_message.timestamp = timestamp;

  NSMutableArray *messages = [self getMessagesForChatId:chat_id];
  [messages addObject:chat_message];

  [chat_message release];
  return;
}

- (void)dealloc
{

  DEALLOC
}

@end