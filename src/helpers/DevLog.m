#import "../../include/DevLog.h"

@implementation DevLog

- (id)init
{
  self = [super init];

  if (self != nil)
    {
      NSString *log_file = [NSString stringWithFormat:@"%@/.config/druj/log.txt", NSHomeDirectory ()];
      BOOL file_exists = [[NSFileManager defaultManager] fileExistsAtPath:log_file];

      if (file_exists == NO)
        {
          [[NSFileManager defaultManager] createFileAtPath:log_file
                                                  contents:nil
                                                attributes:nil];
        }

      handler = [NSFileHandle fileHandleForUpdatingAtPath:log_file];
    }

  return self;
}

/**
 *
 * @param data
 */
- (void)write:(NSString *)string
{
  NSData *data = [
      [NSString stringWithFormat:@"%@\n", string] dataUsingEncoding:NSUTF8StringEncoding
  ];

  [handler writeData:data];
}

- (void)dealloc
{
  [handler closeFile];
  DEALLOC
}

@end