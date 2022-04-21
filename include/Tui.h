#import <Foundation/Foundation.h>
#import "../../include/DateHelper.h"
#import "Store.h"
#import "config.h"
#include <ncurses.h>

#define GREEN_TEXT 2
#define YELLOW_TEXT 3

@interface Tui : NSObject {
  BOOL refresh_chat_list; // Флаг для обновления списка чатов
  int refresh_main_win;
  int num_of_text_lines;
  int last_index;
  int buffer_lines;
  int buffer_offset;
  int chats_count; // Количество чатов (в правой панели)
  WINDOW *header_win;
  WINDOW *main_win;
  WINDOW *status_bar;
  WINDOW *list_bar;
  WINDOW *input_bar;
  NSString *current_chat_id;
  NSString *current_input_type;
}
- (void)start;
- (void)dictionaryObserver;
- (void)addTextToMainWin:(NSString *)text;
@end
