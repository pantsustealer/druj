#import "../../include/ChatUserManager.h"

/**
 * Операции с моделями участников чата
 */
@implementation ChatUserManager

/**
 * Добавляет нового участника
 *
 * @param user_nickname
 * @param user_id
 */
+ (void)addUserNickname:(NSString *)user_nickname
             withUserId:(NSString *)user_id
{
  ChatUserModel *user_model = [[ChatUserModel alloc] init];
  NSMutableDictionary *manager = [ChatUserManager getManager:@"UserManager"];

  user_model.user_nickname = user_nickname;
  user_model.user_id = user_id;

  [manager setObject:user_model
              forKey:user_id];

  return;
}

+ (ChatUserModel *)getUserModelByKey:(NSString *)key
{
  NSMutableDictionary *manager = [ChatUserManager getManager:@"UserManager"];
  ChatUserModel *chat_user_model = [manager objectForKey: key];

  return chat_user_model;
}

@end