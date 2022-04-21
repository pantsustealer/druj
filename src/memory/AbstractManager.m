#import "../../include/AbstractManager.h"

@implementation AbstractManager

+ (NSMutableDictionary *)getManager:(NSString *)key
{
  NSMutableDictionary *thread_dictionary = [
      [NSThread mainThread] threadDictionary
  ];

  if ([thread_dictionary objectForKey:key] == nil)
    {
      NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
      [thread_dictionary setObject:dict
                            forKey:key];
    }

  return [thread_dictionary objectForKey:key];
}


@end