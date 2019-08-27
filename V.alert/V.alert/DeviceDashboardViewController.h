#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "HomeViewController.h"
#import "dbConnect.h"
#import "PopViewController.h"
#import "AlertInProgress.h"
#import "UIViewController+UIViewController_rotation.h"
@interface DeviceDashboardViewController : UIViewController<BLEConnectionDelegate,alertinDelegate,UIAlertViewDelegate,UITextFieldDelegate>{
    BLEConnectionClass *ObjBLEConnection;
    CBPeripheralManager *manager;
    dbConnect *dConnect;
    int indexofDevice;
    UIView *loadingView;
    UILabel*timerLbl;
    UILabel*falldetectLbl;
    UIButton *cancelbutton;
    int hours, minutes, seconds;
    int secondsLeft;
    //PopViewController *popviewController;
    NSMutableArray*arrActivePeripherals;
    int deviceStatus;
     IBOutlet UIScrollView*scroller;
}
-(void)getBatteryStatus;
- (IBAction)didActionFindMe:(id)sender;
- (IBAction)didActionChangeName:(id)sender;
- (IBAction)didactionFallDetection:(id)sender;
- (IBAction)didActionForgetMe:(id)sender;
- (IBAction)didActionBackViewController:(id)sender;

//Instance Properties
@property (strong, nonatomic) IBOutlet UIImageView *imgFall;
@property (strong, nonatomic) IBOutlet UILabel *lblFallStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnFindMe;
@property (strong, nonatomic) IBOutlet UIButton *btnChangeName;
@property (strong, nonatomic) IBOutlet UIButton *btnFallDetection;
@property (strong, nonatomic) IBOutlet UIButton *btnForgetMe;
@property (strong, nonatomic) IBOutlet UIButton *btnBackaction;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewShowSignalStregnth;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewShowBatteryStatus;

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *lblShowBatteryPercentage;
@property (strong, nonatomic) IBOutlet UILabel *lblShowDeviceName;
@property (strong, nonatomic) IBOutlet UILabel *lblShowSignalPercentage;

//Active BLE Peripheral
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) BLEConnectionClass *ObjBLEConnection;
@property(strong,nonatomic) CBPeripheral*normalPeriperal;
@property (weak, nonatomic) IBOutlet UIScrollView *scrlViewMultipleDevices;
@property (strong, nonatomic) IBOutlet UIPageControl *pgeCtrlrAvailableDevices;
@property (retain, nonatomic) NSTimer *falldetectTimer;

@property (retain, nonatomic) NSTimer *vibrateTimer;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLine;

@property (strong, nonatomic) IBOutlet UILabel *findVLRTLbl;
@property (strong, nonatomic) IBOutlet UILabel *forgetMeLbl;
@property (strong, nonatomic) IBOutlet UILabel *renameLbl;
@property (strong, nonatomic) IBOutlet UILabel *fallDetectionLbl;
@end
