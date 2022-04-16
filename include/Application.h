#import <Foundation/Foundation.h>
#import "Tui.h"
#import "Telegram.h"

@interface Application: NSObject
{
    Tui      *tui;
//    Xmpp     *xmpp;
    Telegram *telegram;
}
@end