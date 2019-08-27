#import <UIKit/UIKit.h>
#import "Constants.h"

@interface HelpInfoViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lblLink;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIWebView *webAgreementDescription;

- (IBAction)didActionBack:(id)sender;


@end
