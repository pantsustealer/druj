#import <Foundation/Foundation.h>

@interface DevLog : NSObject {
 @private
  NSFileHandle *handler;
 @protected
 @public
}

-(void) write: (NSString *)data;
@end