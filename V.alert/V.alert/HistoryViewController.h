#import <UIKit/UIKit.h>
#import "dbConnect.h"
#import <MessageUI/MessageUI.h>


@interface HistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate> {

    IBOutlet UITableView *tableView;
    dbConnect *dConnect;
    NSMutableArray*recordArray;

}
@property(nonatomic,retain)IBOutlet UILabel *historyLogLbl;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
- (IBAction)didActionBackViewController:(id)sender;
-(IBAction)sendLogMail:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *btnBackSettings;
@end
