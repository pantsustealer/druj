#import "../../include/DateHelper.h"

@implementation DateHelper

/**
 *
 * @param timestamp
 * @return
 */
+ (NSString *)timeFromTimestamp:(NSString *)timestamp
{
  NSTimeInterval timeInterval = [timestamp doubleValue];
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

  [formatter setDateFormat:@"HH:mm:ss"];
  NSString *date_string = [formatter stringFromDate:date];

  [formatter release];

  return date_string;
}

@end