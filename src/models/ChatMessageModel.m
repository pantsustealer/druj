#import "../../include/ChatMessageModel.h"

@implementation ChatMessageModel

@synthesize message_id = _message_id;
@synthesize user_id = _user_id;
@synthesize message = _message;
@synthesize timestamp = _timestamp;

- (NSComparisonResult)compare:(ChatMessageModel *)chat_message_model
{
  return [self.message_id compare:chat_message_model.message_id];
}

- (void)dealloc
{
  [_message_id release];
  [_user_id release];
  [_message release];
  [_timestamp release];
  [super dealloc];
}
@end