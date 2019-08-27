#import "UIAlertView+UIAlertViewController.h"

@implementation UIAlertView (UIAlertViewController)
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}
@end
