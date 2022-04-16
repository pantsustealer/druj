#import "../include/Application.h"

@implementation Application

- (instancetype) init
{
    self = [super init];
 
    if (self)
    {
        tui      = [[Tui alloc] init];
        //xmpp     = [[Xmpp alloc] init];
        telegram = [[Telegram alloc] init];

        // xmpp наследуется от NSThread и выполняется в отдельном треде
        //[xmpp start];

        [telegram start];

        // консольный интерфейс
        [tui start];
    }

    return self;
}

- (void) dealloc 
{
    [tui release];
//    [xmpp release];

    [super dealloc];
}

@end
