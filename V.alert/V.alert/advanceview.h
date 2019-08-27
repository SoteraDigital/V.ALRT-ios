#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "dbConnect.h"
@interface advanceview : UIViewController<BLEConnectionDelegate>
{
     BLEConnectionClass *ObjBLEConnection;
    IBOutlet UILabel *alertsoundLbl;
    IBOutlet UILabel *silentmodeLbl;
    IBOutlet UILabel *valrtdevicemodeLbl;
    IBOutlet UILabel *phoneapplnmodeLbl;
    IBOutlet UILabel *alertsoundDftLbl;
    IBOutlet UIButton *arrowBtn;
    IBOutlet UIButton *deviceSilentBtn;
    IBOutlet UIButton *phoneSilentBtn;
    IBOutlet UIImageView *arrowImg;
    NSString*alertMsg;
    NSString*alertTitle;
    IBOutlet UIButton *skipBtn;
    dbConnect*dConnect;
    NSString *_date;
}
@property(strong,nonatomic)BLEConnectionClass *ObjBLEConnection;
@property (weak, nonatomic) IBOutlet UILabel *advanceTitle;
@property (weak, nonatomic) IBOutlet UIView *silentModeBar;
@property (weak, nonatomic) IBOutlet UIView *alertSoundBar;
@property (strong, nonatomic) IBOutlet UILabel *silentModeTextLbl;
- (IBAction)backAction:(id)sender;
- (IBAction)tapGestureAlertSound:(id)sender;
- (IBAction)tapPanicSound:(UIButton *)sender;
- (IBAction)taplabelClcikPanicSound:(id)sender;
@end
