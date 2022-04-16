#import <Foundation/Foundation.h>
#import "config.h"

#define STORE_KEY_EVENT @"events"
#define EVENT_SYSTEM_QUIT @"quit"
#define EVENT_PHONE_REQUEST @"event_phone_request"
#define EVENT_PHONE_RESPONSE @"event_phone_response"
#define EVENT_CODE_REQUEST @"event_code_request"
#define EVENT_CODE_RESPONSE @"event_code_response"
#define EVENT_SYSTEM_READY @"event_system_ready"
#define EVENT_MESSAGE_OUTGOING @"event_message_outgoing"

@interface Store: NSObject
{
}
+ (void) addLogMessage: (NSString *) message;

// Events
+ (void) addEvent: (NSString *) event_name withData: (id) data;
+ (NSMutableDictionary *) getEvents;

+ (void) setNickname: (NSString *) nickname forId: (NSString *) id;
+ (NSString *) getNickName: (NSString *) id;
+ (void) setChatName: (NSString *) chatname forId: (NSString *) id;
+ (NSString *) getChatName: (NSString *) id;
+ (NSMutableDictionary *) getChats;
+ (NSString *) getChatIdByIndex: (NSNumber *) index;

// Messages
+ (void) addMessage: (NSString *) message forChat: (NSString *) chat_id withId: (NSString *) message_id;
+ (NSMutableArray *) getMessages: (NSString *) chat_id;
@end
