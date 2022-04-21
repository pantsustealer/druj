#import "../../include/ChatUserModel.h"

@implementation ChatUserModel

@synthesize user_id = _user_id;
@synthesize user_nickname = _user_nickname;

- (void)dealloc
{
  [_user_id release];
  [_user_nickname release];
  [super dealloc];
}

@end