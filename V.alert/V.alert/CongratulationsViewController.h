#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "MBProgressHUD.h"
#import "dbConnect.h"
#import "HomeViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface CongratulationsViewController : UIViewController<BLEConnectionDelegate,CLLocationManagerDelegate,MBProgressHUDDelegate>
{
    BLEConnectionClass *ObjBLEConnection;
    
    //user feedback changes starts
     UILabel *primaryLabel;
    //user feedback changes ends
    CLLocationManager *locationManager;
    int failedFirstSmsRetryCount;
    NSMutableArray*smsArray;
     MBProgressHUD *HUD;
    HomeViewController *ObjHomeViewController;
    dbConnect*dConnect;
}
-(void)sendFirstSms;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle1;
@property (strong, nonatomic) IBOutlet UILabel *lblTermsandConditionsDescription;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewCheckBox;
@property (strong, nonatomic)BLEConnectionClass *ObjBLEConnection;

- (IBAction)didActionDoneSetUp:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *btnActionDoneSetUp;

@end
