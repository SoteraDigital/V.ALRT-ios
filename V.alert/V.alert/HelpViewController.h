#import <UIKit/UIKit.h>
#import "HelpInfoViewController.h"
#import "HistoryViewController.h"

@interface HelpViewController : UIViewController<UIAlertViewDelegate>
{
    IBOutlet UIScrollView*scroller;
}
@property (strong, nonatomic) IBOutlet UIButton *btnBackViewController;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgHistory;
@property (strong, nonatomic) IBOutlet UIImageView *imgInstructionManual;
@property (strong, nonatomic) IBOutlet UIImageView *imgInstructionVideo;
@property (strong, nonatomic) IBOutlet UIImageView *imgProductInfo;
@property (strong, nonatomic) IBOutlet UIImageView *imgAboutVsn;
@property (strong, nonatomic) IBOutlet UIImageView *imgTerms;

@property (strong, nonatomic) IBOutlet UIButton *btnHistory;
@property (strong, nonatomic) IBOutlet UIButton *btnInstructionManual;
@property (strong, nonatomic) IBOutlet UIButton *btnInstructionVideo;
@property (strong, nonatomic) IBOutlet UIButton *btnProductInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnAboutVsn;
@property (strong, nonatomic) IBOutlet UIButton *btnTerms;

@property (strong, nonatomic) IBOutlet UILabel *lblHistory;
@property (strong, nonatomic) IBOutlet UILabel *lblInstructionManual;
@property (strong, nonatomic) IBOutlet UILabel *lblInstructionVideo;
@property (strong, nonatomic) IBOutlet UILabel *lblProductInfo;
@property (strong, nonatomic) IBOutlet UILabel *lblAboutVsn;
@property (strong, nonatomic) IBOutlet UILabel *lblTerms;
@property (strong, nonatomic) IBOutlet UIView *viewInstructionVideo;
@property (strong, nonatomic) IBOutlet UIView *viewProductInfo;
@property (strong, nonatomic) IBOutlet UIView *viewQSG;


- (IBAction)didActionBackViewController:(id)sender;

-(IBAction)history:(id)sender;
-(IBAction)instructionManual:(id)sender;
-(IBAction)instructionVideo:(id)sender;
-(IBAction)productInfo:(id)sender;
-(IBAction)aboutVsn:(id)sender;
-(IBAction)terms:(id)sender;

@end
