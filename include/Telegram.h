#import <Foundation/Foundation.h>
#import "td_json_client.h"
#import "Store.h"

@interface Telegram : NSThread {
 @private
  void *client;
  int is_closed;
  NSMutableArray *history_requests;
 @protected
 @public
}
@end
