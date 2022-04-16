#import "../include/Tui.h"
#import "../include/ChatListManager.h"
#import "../include/ChatMessageManager.h"
#import "../include/ChatMessage.h"

@implementation Tui

- (instancetype)init
{
  self = [super init];

  if (self)
    {
      refresh_main_win = 1; // Разрешаем обновление экрана с сообщениями
      current_chat_id = nil;
      current_input_type = nil;
      last_index = 0;
      buffer_lines = 0;
      buffer_offset = 0;
      chats_count = 0; // Количество чатов (в правой панели)
    }

  return self;
}

- (void)dealloc
{
  delwin (main_win);
  endwin ();

  [super dealloc];
}

//
// Инициализация ncurses
//
- (void)start
{
  setlocale (LC_ALL, "");
  initscr ();

  clear();
  noecho ();
  cbreak ();

  // Colors
  start_color ();
  use_default_colors ();
  init_pair (1, COLOR_WHITE, COLOR_BLUE);

  int padding = 16;
  main_win = newpad (10000, COLS - (padding + 2));
  header_win = subwin (stdscr, 1, COLS, 0, 0);
  status_bar = subwin (stdscr, 1, COLS, LINES - 2, 0);
  list_bar = subwin (stdscr, LINES - 4, padding, 1, COLS - padding);
  input_bar = subwin (stdscr, 1, COLS, LINES - 1, 0);

  // Header
  wattron(header_win, COLOR_PAIR (1));
  waddstr(header_win, "Title");
  wbkgd (header_win, COLOR_PAIR(1));
  wattroff(header_win, COLOR_PAIR (1));

  // Status bar
  wbkgd (status_bar, COLOR_PAIR(1));

  // List bar
  waddstr(list_bar, "List");

  refresh();

  keypad (main_win, TRUE);
  nodelay (stdscr, TRUE);
  scrollok (main_win, TRUE);
  curs_set (2);

  [self performSelectorInBackground:@selector (eventObserver)
                         withObject:nil];

  [self performSelectorInBackground:@selector (listObserver)
                         withObject:nil];

  // Запуск обсервера новых сообщений в отдельном треде
  // для того, чтобы избежать блокировки tui
  [self performSelectorInBackground:@selector (dictionaryObserver)
                         withObject:nil];

  [self performSelectorInBackground:@selector (keyboardObserver)
                         withObject:nil];

  // При старте выводим окно с логом
  [NSThread sleepForTimeInterval:1.0f];
  [self switchToLogWindow];
}

- (void)printStatusBar:(NSString *)value
{
  wclear (status_bar);
  wattron(status_bar, COLOR_PAIR (1));
  wprintw (status_bar, " [ %s ]", [value UTF8String]);
  wattroff(status_bar, COLOR_PAIR (1));
  wrefresh (status_bar);
}

- (void)eventObserver
{
  ENTER_POOL

        BOOL loop = YES;

        while (loop == YES)
          {
            NSMutableDictionary *list = [Store getEvents];

            for (NSString *event in [list allKeys])
              {
                if ([event isEqualToString:EVENT_PHONE_REQUEST])
                  {
                    current_input_type = EVENT_PHONE_REQUEST;
                    [self printStatusBar:@"Введите номер телефона"];
                    [list removeObjectForKey:EVENT_PHONE_REQUEST];
                  }

                if ([event isEqualToString:EVENT_CODE_REQUEST])
                  {
                    current_input_type = EVENT_CODE_REQUEST;
                    [self printStatusBar:@"Введите код подтверждения"];
                    [list removeObjectForKey:EVENT_CODE_REQUEST];
                  }

                if ([event isEqualToString:EVENT_SYSTEM_READY])
                  {
                    current_input_type = nil;
                    [self printStatusBar:@"Connected"];
                    [list removeObjectForKey:EVENT_SYSTEM_READY];
                  }
              }

            [NSThread sleepForTimeInterval:1.001f];
          }

  LEAVE_POOL
}

//
// Выводит список диалогов
//
- (void)listObserver
{
  ENTER_POOL
        ChatListManager *chat_list_manager = [[ChatListManager alloc] init];
        BOOL loop = YES;

        while (loop == YES)
          {
            NSMutableDictionary *list = [chat_list_manager getChatList];

            // Чтобы экран не мерцал, проверяем предыдущее состояние
            // количества доступных чатов с текущим
            if (chats_count < (int) [list count])
              {
                // Количество чатов изменилось -
                // производим очистку, новый вывод и применение нового значения
                werase (list_bar);

                for (id key in [list allKeys])
                  {
                    wprintw (list_bar, "%s\n", [[list objectForKey:key] UTF8String]);
                  }

                chats_count = (int) [list count];
                wrefresh (list_bar);
              }

            [NSThread sleepForTimeInterval:1.0f];
          }

  LEAVE_POOL
}

- (int)getLinesForString:(NSString *)string
{
  NSInteger lines = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] count];

  return (int) lines;
}

//
// Метод вызывается в отдельном треде
//
- (void)dictionaryObserver
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableDictionary *dict = [[NSThread mainThread] threadDictionary];
  ChatMessageManager *chat_message_manager = [[ChatMessageManager alloc] init];
  BOOL loop = YES;

  while (loop == YES)
    {
      if (current_chat_id != nil)
        {
          if ([chat_message_manager getMessagesForChatId:current_chat_id].count > last_index)
            {
              wclear(main_win);

              NSArray *messages = [chat_message_manager
                  getMessagesForChatId:current_chat_id
              ];

              int count = 10;
              NSArray *sorted_array = [messages sortedArrayUsingSelector:@selector (compare:)];
              NSRange end_range = NSMakeRange (sorted_array.count >= count ? sorted_array.count - count : 0, MIN(sorted_array.count, count));
              NSArray *limited_array = [sorted_array subarrayWithRange:end_range];

              for (ChatMessage *chat_message in limited_array)
                {

                  wprintw (main_win, "%s\n", [
                               [NSString stringWithFormat:@"%@",
                                                          chat_message.message
                               ] UTF8String
                           ]
                  );

                  last_index += 1;

                }


              // Скролл к последнему сообщению
              prefresh (main_win, buffer_offset, 0, 1, 0, LINES - 4, COLS);
            }
        }

      [NSThread sleepForTimeInterval:0.1f];
    }
}

//
//
//
- (void)keyboardObserver
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableString *input = [[NSMutableString alloc] init];
  int chat_window_offset = 0;
  int c;

  while ((wget_wch (main_win, &c)) != 1)
    {
      // todo курсор в инпуте

      if (c > 0)
        {
          if (has_key (c) || c == '\n')
            {
              switch (c)
                {
                  case KEY_NPAGE:
                    //if (buffer_offset < 0)
                    //{
                    buffer_offset += (LINES - 4 - 1);
                  prefresh (main_win, buffer_offset, 0, 1, 0, LINES - 4, COLS);
                  //}
                  break;

                  // Page Down
                  case KEY_PPAGE:
                    // дополнительно -1, чтобы отобразилось последнее сообщение с
                    // предыдущего экрана
                    if (buffer_offset > 0)
                      {
                        buffer_offset -= (LINES - 4 - 1);
                        prefresh (main_win, buffer_offset, 0, 1, 0, LINES - 4, COLS);
                      }
                  if (buffer_offset < 0)
                    {
                      buffer_offset = 0;
                    }
                  break;

                  case KEY_BACKSPACE:
                    if ([input length])
                      {
                        [input setString:
                            [input substringToIndex:[input length] - 1]
                        ];

                        wclear (input_bar);
                        wprintw (input_bar, "%s", [input UTF8String]);
                        wrefresh (input_bar);
                      }
                  break;

                  // Enter
                  case 10:
                    if ([input isEqualToString:@"/quit"])
                      {
                        [self addTextToMainWin:@"Bye!"];

                        [Store addEvent:EVENT_SYSTEM_QUIT
                               withData:@"/quit"];

                      }
                  // Событие отправки номера телефона
                  if ([current_input_type isEqualToString:EVENT_PHONE_REQUEST])
                    {
                      // Очистка ввода приведёт к изменению переданной строки - копируем в новую
                      NSString *phone = [NSString stringWithString:input];

                      [Store addEvent:EVENT_PHONE_RESPONSE
                             withData:phone];

                      // Сброс строки статуса
                      [self printStatusBar:@"Ожидание получения кода..."];

                      // Очистка строки ввода
                      [input setString:@""];
                      wclear (input_bar);
                      wrefresh (input_bar);
                    }

                  // Событие отправки кода
                  if ([current_input_type isEqualToString:EVENT_CODE_REQUEST])
                    {
                      NSString *code = [NSString stringWithString:input];
                      [Store addEvent:EVENT_CODE_RESPONSE
                             withData:code];

                      [self printStatusBar:@"Awaiting data..."];
                      [input setString:@""];
                      wclear (input_bar);
                      wrefresh (input_bar);
                    }

                  //
                  // Отправка тестовых сообщений в текущий (current_chat_id) чат
                  //
                  if (current_input_type == nil)
                    {
                      NSString *message = [NSString stringWithString:input];
                      NSString *first_letter = [message substringFromIndex:0];

                      if ([first_letter isEqualToString:@"/"])
                        {
                          [self addTextToMainWin:@"Unknown command"];

                          [input setString:@""];
                          wclear (input_bar);
                          wrefresh (input_bar);
                        }
                      else
                        {
                          NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                              message, @"message",
                              current_chat_id, @"chat_id",
                                  nil];

                          [Store addEvent:EVENT_MESSAGE_OUTGOING
                                 withData:data
                          ];

                          [input setString:@""];
                          wclear (input_bar);
                          wrefresh (input_bar);
                        }
                    }
                  break;

                  case KEY_F(1):
                    if (current_chat_id != nil)
                      {
                        last_index = 0;
                        [self switchToLogWindow];
                        [self clear];
                      }
                  break;

                  case KEY_F(2):
                    [self switchToWindow:0];
                  chat_window_offset = 0;
                  break;

                  case KEY_F(5):
                    chat_window_offset--;

                  if (chat_window_offset <= 0)
                    {
                      chat_window_offset = 0;
                    }
                  [self switchToWindow:chat_window_offset];
                  break;

                  case KEY_F(6):
                    chat_window_offset++;
                  [self switchToWindow:chat_window_offset];
                  break;
                }
            }
          else
            {
              [input appendString:
                  [NSString stringWithFormat:@"%C", (unsigned short) c]
              ];

              wclear (input_bar);
              wprintw (input_bar, "%s", [input UTF8String]);
              wrefresh (input_bar);
            }
        }

      [NSThread sleepForTimeInterval:0.1f];
    }

  [pool release];
}

- (void)switchToLogWindow
{
  current_chat_id = nil;
//
//  wclear (status_bar);
//  wattron(status_bar, COLOR_PAIR (1));
//  wprintw (status_bar, " %s\n", [@"[Log]" UTF8String]);
//  wattroff(status_bar, COLOR_PAIR (1));
//  wrefresh (status_bar);
}

//
//
//
- (void)switchToWindow:(int)index
{
  ChatListManager *chat_list_manager = [[ChatListManager alloc] init];
  NSMutableDictionary *list = [chat_list_manager getChatList];
  int total_windows = (int) ([list count] - 1);

  if (total_windows >= index)
    {
      // Чат должен присутствовать в массиве
      if ([chat_list_manager getChatNameByOffset:index] != nil)
        {
          NSString *chat_id = [chat_list_manager getChatNameByOffset:index];

          //if ([[Store getMessages: chat_id] count] > 0)
          //{
          last_index = 0;
          buffer_lines = 0; // Сбрасываем счётчик количества строк в буфере
          current_chat_id = chat_id;
          NSString *chat_name = [Store getChatName:chat_id];

          wclear (status_bar);
          wattron(status_bar, COLOR_PAIR (1));

          // т.к. отсчёт с нуля, отображаем 0 как 1: index + 1
          wprintw (status_bar, " %i/%i: [ %s ] %s",
                   index + 1,
                   [list count],
                   [chat_name UTF8String],
                   [[NSString stringWithFormat:@"%@", chat_id] UTF8String]
          );
          wattroff(status_bar, COLOR_PAIR (1));
          wrefresh (status_bar);

          [self clear];
          //}
        }
    }

  [chat_list_manager release];
}

//
// Очищает окно с сообщениями
//
- (void)clear
{
  werase (main_win);
  prefresh (main_win, 0, 0, 1, 0, LINES - 4, COLS);
}

- (void)addTextToMainWin:(NSString *)text
{
  wprintw (main_win, "%s\n", [[NSString stringWithFormat:@"%@", text] UTF8String]);
  prefresh (main_win, 0, 0, 1, 0, LINES - 4, COLS);
}

@end
