#import "AbstractManager.h"
#import "ChatUserModel.h"

@interface ChatUserManager : AbstractManager {
 @private
 @protected
 @public
}

/**
 *
 * @param user_nickname
 * @param user_id
 */
+ (void)addUserNickname:(NSString *)user_nickname
             withUserId:(NSString *)user_id;


/**
 *
 * @param key
 * @return
 */
+ (ChatUserModel *)getUserModelByKey:(NSString *)key;

@end