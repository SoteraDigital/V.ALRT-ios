#import <UIKit/UIKit.h>

@interface Qsgview : UIViewController<UIWebViewDelegate>
{
    UIWebView*QsgView;
    UILabel *navLbl;
}
@property (strong, nonatomic) NSString *urlLinkstr;
@property (strong, nonatomic) NSString *strPageTitle;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIWebView *QsgView;
@property (strong, nonatomic) IBOutlet UILabel *navLbl;

- (IBAction)backAction:(id)sender;
@end
