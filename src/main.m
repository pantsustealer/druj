#import <Foundation/Foundation.h>
#import "../include/Application.h"

int main ()
{
  ENTER_POOL

        Application *a = [[Application alloc] init];
        [[NSRunLoop currentRunLoop] run];
        [a release];

  LEAVE_POOL

  return EXIT_SUCCESS;
}