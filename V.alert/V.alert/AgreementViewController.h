#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AgreementViewController : UIViewController<UIWebViewDelegate>
{
    NSURLRequest *requestURL;
}
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsAndConditions;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsandConditionsDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewCheckBox;
@property (strong, nonatomic) IBOutlet UIWebView *webAgreementDescription;

@property (strong, nonatomic) IBOutlet UIButton *btnNextView;
- (IBAction)didActionNextView:(id)sender;

@end
