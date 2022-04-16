#import "../include/Telegram.h"
#import "../include/DevLog.h"
#import "../include/ChatListManager.h"
#import "../include/ChatMessageManager.h"

@implementation Telegram

- (instancetype)init
{
  self = [super init];

  if (self)
    {
      td_set_log_verbosity_level (0);
      client = td_json_client_create ();
      is_closed = 0;
      history_requests = [[NSMutableArray alloc] init];

      [self performSelectorInBackground:@selector (eventObserver)
                             withObject:nil];
    }

  return self;
}

//
//
//
- (void)eventObserver
{
  ENTER_POOL
        BOOL loop = YES;

        while (loop == YES)
          {
            NSMutableDictionary *list = [Store getEvents];

            for (NSString *event in [list allKeys])
              {
                // Отправка номера телефона
                if ([event isEqualToString:EVENT_PHONE_RESPONSE])
                  {
                    //[Store addLogMessage:[list objectForKey:EVENT_PHONE_RESPONSE]];

                    NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"setAuthenticationPhoneNumber",
                        @"@type",
                        [list objectForKey:EVENT_PHONE_RESPONSE],
                        @"phone_number",
                            nil];

                    [self send:entry];
                    [list removeObjectForKey:EVENT_PHONE_RESPONSE];
                    [entry release];
                  }

                // Отправка кода
                if ([event isEqualToString:EVENT_CODE_RESPONSE])
                  {
                    //[Store addLogMessage:[list objectForKey:EVENT_CODE_RESPONSE]];

                    NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"checkAuthenticationCode", @"@type",
                        [list objectForKey:EVENT_CODE_RESPONSE], @"code",
                            nil];

                    [self send:entry];
                    [list removeObjectForKey:EVENT_CODE_RESPONSE];
                    [entry release];
                  }

                //
                // Отправка сообщения
                //
                if ([event isEqualToString:EVENT_MESSAGE_OUTGOING])
                  {
                    NSString *chat_id = [[list objectForKey:EVENT_MESSAGE_OUTGOING] objectForKey:@"chat_id"];
                    NSString *message = [[list objectForKey:EVENT_MESSAGE_OUTGOING] objectForKey:@"message"];

                    NSDictionary *text = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"formattedText", @"@type",
                        message, @"text",
                            nil];

                    NSDictionary *input_message_content = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"inputMessageText", @"@type",
                        text, @"text",
                            nil];

                    NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                        @"sendMessage", @"@type",
                        chat_id, @"chat_id",
                        input_message_content, @"input_message_content",
                            nil];

                    [self send:entry];
                    [list removeObjectForKey:EVENT_MESSAGE_OUTGOING];
                  }

                if ([event isEqualToString:EVENT_SYSTEM_QUIT])
                  {
                    is_closed = 1;
                  }
              }

            [NSThread sleepForTimeInterval:1.001f];
          }

  LEAVE_POOL
}

- (void)fetchChatHistoryForChatId:(NSString *)chat_id
                    fromMessageId:(NSString *)message_id
{
  if ([history_requests containsObject:chat_id] == NO)
    {
      [self send:[[[NSDictionary alloc] initWithObjectsAndKeys:
          @"getChatHistory", @"@type",
          chat_id, @"chat_id",
          @"50", @"limit",
          @"1", @"local_only",
          message_id, @"from_message_id",
              nil] autorelease]
      ];

      [history_requests addObject:chat_id];
    }

  return;
}
//
//
//
- (void)main
{
  ENTER_POOL
        const double WAIT_TIMEOUT = 5.0;
        unsigned int initial_chats_count = 0;
        DevLog *log = [[DevLog alloc] init];
        ChatListManager *chat_list_manager = [[ChatListManager alloc] init];
        ChatMessageManager *chat_message_manager = [[ChatMessageManager alloc] init];

        while (!is_closed)
          {
            const char *result = td_json_client_receive (client, WAIT_TIMEOUT);

            if (result)
              {
                NSData *jsonData = [[NSString stringWithFormat:@"%s", result] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
                NSString *type = [jsonDict objectForKey:@"@type"];

                //
                // updateAuthorizationState
                //
                if ([type isEqualToString:@"updateAuthorizationState"])
                  {
                    NSDictionary *authorizationState = [jsonDict objectForKey:@"authorization_state"];
                    NSString *authorizationStateType = [authorizationState objectForKey:@"@type"];
                    //
                    // authorizationStateWaitTdlibParameters
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateWaitTdlibParameters"])
                      {
                        NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"setTdlibParameters",
                            @"@type",
                            [[[NSDictionary alloc] initWithObjectsAndKeys:
                                @"Desktop",
                                @"device_model",
                                @"139533",
                                @"api_id",
                                @"c35f612846f5448bee3c11decbad6537",
                                @"api_hash",
                                @"en",
                                @"system_language_code",
                                @"0.0",
                                @"application_version",
                                [NSString stringWithFormat:@"%@/.config/druj", NSHomeDirectory ()],
                                @"database_directory",
                                    nil] autorelease],
                            @"parameters",
                                nil];

                        [self send:entry];
                        [entry release];
                      }
                    //
                    // authorizationStateWaitEncryptionKey
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateWaitEncryptionKey"])
                      {
                        NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"checkDatabaseEncryptionKey",
                            @"@type",
                            @"randomencryption",
                            @"encryption_key",
                                nil];

                        [self send:entry];
                        [entry release];
                      }
                    //
                    // authorizationStateWaitPhoneNumber
                    // Для авторизации требуется телефонный номер
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateWaitPhoneNumber"])
                      {
                        [Store addEvent:EVENT_PHONE_REQUEST
                               withData:type];
                      }
                    //
                    // authorizationStateWaitCode
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateWaitCode"])
                      {
                        [Store addEvent:EVENT_CODE_REQUEST
                               withData:type];
                      }
                    //
                    // authorizationStateWaitPassword
                    // Ожидание кода 2fa
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateWaitPassword"])
                      {

                        NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"checkAuthenticationPassword", @"@type",
                            @"penispenispenis", @"password",
                                nil];

                        [self send:entry];
                        [entry release];
                      }

                    //
                    // authorizationStateReady
                    // Успешное завершение подключения к тг
                    // Запрос списка чатов
                    //
                    if ([authorizationStateType isEqualToString:@"authorizationStateReady"])
                      {
                        [Store addEvent:EVENT_SYSTEM_READY
                               withData:type];

                        NSDictionary *entry = [[NSDictionary alloc] initWithObjectsAndKeys:
                            @"getChats", @"@type",
                            @"100", @"limit",
                                nil];

                        [self send:entry];
                        [entry release];
                      }
                  }

                // Получение списка чатов
                if ([type isEqualToString:@"chats"])
                  {
                    // В ответе приходит массив id чатов и их общее кол-во
                    NSArray *chat_ids = [jsonDict objectForKey:@"chat_ids"];
                    initial_chats_count = [[jsonDict objectForKey:@"total_count"] unsignedIntValue];
                    unsigned int i;

                    for (i = 0; i < initial_chats_count; ++i)
                      {
                        NSString *chat_id = [chat_ids objectAtIndex:(NSUInteger) i];

                        // Запрашиваем информацию о каждом чате
                        [self send:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"getChat", @"@type",
                            chat_id, @"chat_id",
                                nil] autorelease]
                        ];

                        // Запрашиваем историю
                        // не зная from_message_id всегда будет возвращаться 1 сообщение
                        // воспользуемся этим далее и получим в этом одиночном нужный from_message_id
                        [self send:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"getChatHistory", @"@type",
                            chat_id, @"chat_id",
                            @"1", @"limit",
                            @"0", @"from_message_id",
                                nil] autorelease]
                        ];
                      }
                  }

                // Получение информации о чате
                if ([type isEqualToString:@"chat"])
                  {
                    NSString *chat_id = [jsonDict objectForKey:@"id"];
                    NSString *chat_title = [jsonDict objectForKey:@"title"];

                    // Добавляем чат в список
                    [chat_list_manager addChatName:chat_title
                                            withId:chat_id];
                  }

                if ([type isEqualToString:@"messages"])
                  {
                    NSArray *messages = [jsonDict objectForKey:@"messages"];

                    for (NSDictionary *message in messages)
                      {
                        NSString *chat_id = [message objectForKey:@"chat_id"];
                        NSString *message_type = [message objectForKey:@"@type"];
                        NSString *message_id = [message objectForKey:@"id"];
                        NSDictionary *sender = [message objectForKey:@"sender_id"];
                        NSString *user_id = [sender objectForKey:@"user_id"];
                        NSDictionary *content = [message objectForKey:@"content"];
                        NSDictionary *text = [content objectForKey:@"text"];
                        NSString *message_string = [text objectForKey:@"text"];
                        NSString *nickname = [Store getNickName:user_id];

                        [self fetchChatHistoryForChatId:chat_id
                                          fromMessageId:message_id];

                        if ([message_type isEqualToString:@"message"])
                          {
                            NSString *content_type = [content objectForKey:@"@type"];
                            [log write:content_type];

                            // Событие нового сообщения
                            if ([content_type isEqualToString:@"messageText"])
                              {
                                [chat_message_manager addMessage:message_string
                                                       forChatId:chat_id
                                                      withUserId:user_id
                                                    andMessageId:message_id
                                                    andTimestamp:@"0"
                                ];

                              }
                              // Событие входа в чат пользователя
                            else if ([content_type isEqualToString:@"messageChatDeleteMember"])
                              {
                                NSString *nickname = [Store getNickName:user_id];
                                NSString *final_string = [NSString stringWithFormat:@"<- %@ has left the room", nickname];

                                [chat_message_manager addMessage:final_string
                                                       forChatId:chat_id
                                                      withUserId:user_id
                                                    andMessageId:message_id
                                                    andTimestamp:@"0"];
                              }
                            else if ([content_type isEqualToString:@"messageChatAddMembers"])
                              {
                                NSString *member_user_ids = [content objectForKey:@"member_user_ids"];

                                for (NSString *member_user_id in member_user_ids)
                                  {
                                    NSString *nickname = [Store getNickName:member_user_id];
                                    NSString *final_string = [NSString stringWithFormat:@"-> %@ has joined the room", nickname];

                                    [chat_message_manager addMessage:final_string
                                                           forChatId:chat_id
                                                          withUserId:user_id
                                                        andMessageId:message_id
                                                        andTimestamp:@"0"];
                                  }
                              }
                            else
                              {
                                [chat_message_manager addMessage:content_type
                                                       forChatId:chat_id
                                                      withUserId:user_id
                                                    andMessageId:message_id
                                                    andTimestamp:@"0"
                                ];
                              }
                          }
                      }
                  }

                if ([type isEqualToString:@"error"])
                  {
//                    NSLog (@"%@", jsonDict);
//                    exit (1);
                  }

                if ([type isEqualToString:@"updateSupergroup"])
                  {
                    //NSLog(@"%@", jsonDict);
                  }

                if ([type isEqualToString:@"updateNewChat"])
                  {
                    NSDictionary *chat = [jsonDict objectForKey:@"chat"];
                    NSString *chat_title = [chat objectForKey:@"title"];
                    NSString *chat_id = [chat objectForKey:@"id"];

                    [Store setChatName:chat_title forId:chat_id];
                    [Store addLogMessage:chat_id];
                  }

                if ([type isEqualToString:@"updateUser"])
                  {
                    NSDictionary *user = [jsonDict objectForKey:@"user"];
                    NSNumber *user_id = [user objectForKey:@"id"];
                    NSString *user_first_name = [user objectForKey:@"first_name"];

                    [Store setNickname:user_first_name
                                 forId:user_id];
                  }

                if ([type isEqualToString:@"updateNewMessage"])
                  {
                    NSDictionary *message = [jsonDict objectForKey:@"message"];
                    NSString *message_id = [message objectForKey:@"id"];
                    NSString *chat_id = [message objectForKey:@"chat_id"];
                    NSDictionary *sender = [message objectForKey:@"sender_id"];
                    NSString *user_id = [sender objectForKey:@"user_id"];
                    NSDictionary *content = [message objectForKey:@"content"];
                    NSDictionary *text = [content objectForKey:@"text"];
                    NSString *message_string = [text objectForKey:@"text"];

                    [chat_message_manager addMessage:message_string
                                           forChatId:chat_id
                                          withUserId:user_id
                                        andMessageId:message_id
                                        andTimestamp:@"0"];
                  }
              }

          }

        [log release];
        td_json_client_destroy (client);

  LEAVE_POOL
}

/**
 * Отправка данных в телеграм
 * @param dict
 */
- (void)send:(NSDictionary *)dict
{
  NSError *error;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                     options:0
                                                       error:&error];

  if (error == nil)
    {
      NSString *response = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];

      td_json_client_send (client, [response UTF8String]);
      [response release];
    }

  return;
}

@end
