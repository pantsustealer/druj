#import "../../include/ChatListManager.h"

/**
 * Работа со списком чатов
 */
@implementation ChatListManager

- (id)init
{
  self = [super init];

  if (self != nil)
    {
      NSMutableDictionary *threadDictionary = [
          [NSThread mainThread] threadDictionary
      ];

      if ([threadDictionary objectForKey:KEY] == nil)
        {
          dict = [[NSMutableDictionary alloc] init];

          [threadDictionary setObject:dict
                               forKey:KEY];
        }
    }

  return self;
}

/**
 * Добавляет чат в список
 *
 * @param name - отображаемое название чата
 * @param id - id чата
 */
- (void)addChatName:(NSString *)name
             withId:(NSString *)id;
{
  [dict setObject:name
           forKey:id];

  return;
}

- (int)getChatTotal
{
  NSMutableDictionary *threadDictionary = [
      [NSThread mainThread] threadDictionary
  ];

  return (int) [[threadDictionary objectForKey:KEY] count];
}

/**
 *
 * @return
 */
- (NSMutableDictionary *)getChatList
{
  NSMutableDictionary *threadDictionary = [
      [NSThread mainThread] threadDictionary
  ];

  return [threadDictionary objectForKey:KEY];
}

/**
 *
 * @param offset
 * @return
 */
- (NSString *)getChatNameByOffset:(int)offset
{
  NSArray *keys = [[self getChatList] allKeys];

  return [keys objectAtIndex:(NSUInteger) offset];
}

- (void)dealloc
{

  DEALLOC
}

@end