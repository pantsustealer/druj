#import "../include/Store.h"

@implementation Store

- (instancetype)init
{
  self = [super init];

  if (self)
    {

    }

  return self;
}

+ (NSString *)currentTime
{
  NSDateFormatter *date = [[NSDateFormatter alloc] init];
  [date setDateFormat:@"HH:mm:ss"];

  return [date stringFromDate:[NSDate date]];
}

+ (void)addLogMessage:(NSString *)message
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];

  if (![dict objectForKey:CONFIG_INCOMING_MESSAGE])
    {
      [dict setValue:[[NSMutableArray alloc] init] forKey:CONFIG_INCOMING_MESSAGE];
    }

  NSMutableArray *logs = [dict objectForKey:CONFIG_INCOMING_MESSAGE];

  [logs addObject:[NSString stringWithFormat:@"%@ - %@",
                                             [Store currentTime], message]
  ];
}

//
// Добавляет событие
//
+ (void)addEvent:(NSString *)event_name
        withData:(id)data
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  NSMutableDictionary *events = [dict objectForKey:STORE_KEY_EVENT];

  if (!events)
    {
      [dict setValue:[[[NSMutableDictionary alloc] init] autorelease]
              forKey:STORE_KEY_EVENT];
    }

  [events setValue:data
            forKey:event_name];

  NSAssert([events count] > 0, @"events count: 0");

  return;
}

//
// Вовзращает список событий
//
+ (NSMutableDictionary *)getEvents
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  NSMutableDictionary *list = [dict objectForKey:STORE_KEY_EVENT];

  if (!list)
    {
      [dict setValue:[[NSMutableDictionary alloc] init]
              forKey:STORE_KEY_EVENT];
    }

  return list;
}

+ (void)addMessage:(NSString *)message forChat:(NSString *)chat_id withId:(NSString *)message_id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  if (![dict objectForKey:@"messages"])
    {
      [dict setValue:[[NSMutableDictionary alloc] init]
              forKey:@"messages"];
    }

  NSMutableDictionary *messages = [dict objectForKey:@"messages"];
  if (![messages objectForKey:chat_id])
    {
      [messages setValue:[[NSMutableArray alloc] init]
                  forKey:chat_id];
    }

  NSMutableArray *chat = [messages objectForKey:chat_id];
  NSDictionary *message_model = [[NSDictionary alloc] initWithObjectsAndKeys:
      message, @"message",
      message_id, @"message_id",
          nil];

  [chat addObject:message_model];
}

//
//
//
+ (NSMutableArray *)getMessages:(NSString *)chat_id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  if (![dict objectForKey:@"messages"])
    {
      [dict setValue:[[NSMutableDictionary alloc] init]
              forKey:@"messages"];
    }

  NSMutableDictionary *messages = [dict objectForKey:@"messages"];
  if (![messages objectForKey:chat_id])
    {
      [messages setValue:[[NSMutableArray alloc] init]
                  forKey:chat_id];
    }

  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"message_id" ascending:YES];
  NSArray *sort_descriptors = [NSArray arrayWithObject:descriptor];
  NSDictionary *sorted_dictionary = [[messages objectForKey:chat_id] sortedArrayUsingDescriptors:sort_descriptors];

  return [sorted_dictionary valueForKeyPath:@"message"];
}

+ (void)setNickname:(NSString *)nickname
              forId:(NSString *)id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];

  if (![dict objectForKey:@"nicknames"])
    {
      [dict setValue:[[NSMutableDictionary alloc] init] forKey:@"nicknames"];
    }

  NSMutableDictionary *nicknames = [dict objectForKey:@"nicknames"];
  [nicknames setObject:nickname forKey:id];
}

+ (NSString *)getNickName:(NSString *)id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  NSMutableDictionary *nicknames = [dict objectForKey:@"nicknames"];

  return [nicknames objectForKey:id];
}

+ (void)setChatName:(NSString *)chatname forId:(NSString *)id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];

  if (![dict objectForKey:@"chats"])
    {
      [dict setValue:[[NSMutableDictionary alloc] init] forKey:@"chats"];
    }

  NSMutableDictionary *chat = [dict objectForKey:@"chats"];
  [chat setObject:chatname forKey:id];
}

+ (NSString *)getChatName:(NSString *)id
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  NSMutableDictionary *chatnames = [dict objectForKey:@"chats"];

  return [chatnames objectForKey:id];
}

+ (NSMutableDictionary *)getChats
{
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];

  if (![dict objectForKey:@"chats"])
    {
      [dict setValue:[[NSMutableDictionary alloc] init] forKey:@"chats"];
    }

  return [dict objectForKey:@"chats"];
}

+ (NSString *)getChatIdByIndex:(NSNumber *)index
{
  NSArray *keys = [[Store getChats] allKeys];

  return [keys objectAtIndex:index];
}

@end