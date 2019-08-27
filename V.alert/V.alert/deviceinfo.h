#import <UIKit/UIKit.h>
#import "dbConnect.h"

@interface deviceinfo : UIViewController<UIWebViewDelegate>
{
    dbConnect*dbconnectObj;
    NSMutableArray*deviceInfoArr;
    IBOutlet UITableView*deviceInfoTbl;
    
}
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnBack;
@property (strong, nonatomic) IBOutlet UIWebView *webAgreementDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewCheckBox;
- (IBAction)didActionBack:(id)sender;
@end
