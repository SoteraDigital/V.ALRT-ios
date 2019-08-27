#import "UINavigationController+UINavigationController_rotation_h.h"

@implementation UINavigationController (UINavigationController_rotation_h)
- (BOOL) shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
