#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WelcomeViewController : UIViewController<UIWebViewDelegate,MFMailComposeViewControllerDelegate>
{
    NSURLRequest *requestURL;
    
    }
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsAndConditions;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsandConditionsDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblAcceptTermsandConditions;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewCheckBox;
@property (strong, nonatomic) IBOutlet UIWebView *webTermsandConditionsDescription;
@property(nonatomic,assign) BOOL alertShowing;
@property (strong, nonatomic) IBOutlet UIButton *btnAcceptTermsAndConditions;
@property (strong, nonatomic) IBOutlet UIButton *btnNExtViewController;


- (IBAction)didActionAcceptTermsAndConditions:(id)sender;
- (IBAction)didActionNextViewController:(id)sender;
- (IBAction)actionEmailComposer:(id)sender;

@end
