#import <Foundation/Foundation.h>

@interface AbstractManager : NSObject {
 @private
 @protected
 @public
}
+ (NSMutableDictionary *)getManager:(NSString *)key;
@end