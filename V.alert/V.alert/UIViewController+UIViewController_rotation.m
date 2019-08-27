#import "UIViewController+UIViewController_rotation.h"

@implementation UIViewController (UIViewController_rotation)
- (BOOL) shouldAutorotate
{
    return NO;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
@end
