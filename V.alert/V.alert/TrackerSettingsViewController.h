#import <UIKit/UIKit.h>
#import "dbConnect.h"

@interface TrackerSettingsViewController : UIViewController
{
    dbConnect*dConnect;
    NSString*_date;
}
@property (weak, nonatomic) IBOutlet UILabel *trackerTitle;
@property (weak, nonatomic) IBOutlet UIView *trackerBar;
@end
