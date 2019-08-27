#import <UIKit/UIKit.h>

@interface messageview : UIViewController
{
    IBOutlet UIButton *nextBtn;
    IBOutlet UITextView *messageTxt;
}
@property (weak, nonatomic) IBOutlet UILabel *alertMessageTitle;
@property (weak, nonatomic) IBOutlet UIView *alertMessageBar;
- (IBAction)backAction:(id)sender;
-(void)checkEnableNextbtn;
- (IBAction)nextAction:(id)sender;
@end
