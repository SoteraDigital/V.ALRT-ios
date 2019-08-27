#import <UIKit/UIKit.h>

@interface TermsViewController : UIViewController<UIWebViewDelegate>

{
    
}
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIWebView *webAgreementDescription;

- (IBAction)didActionBackViewController:(id)sender;
@end
