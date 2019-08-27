#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "dbConnect.h"
#import "AlertInProgress.h"
#import "MBProgressHUD.h"
@interface HomeViewController : UIViewController<BLEConnectionDelegate,alertinDelegate,MBProgressHUDDelegate> {
    BLEConnectionClass* ObjBLEConnection;
    dbConnect* dConnect;
    CBPeripheral* p;
    IBOutlet UIView* mydeviceView;
    IBOutlet UIView* mysettingView;
    IBOutlet UIImageView* managedeviceimgView;
    IBOutlet UIImageView* helpimgView;
    IBOutlet UILabel* managedeviceLbl;
    IBOutlet UILabel* helpiconLbl;
    IBOutlet UISwitch* valrtswitch;
    IBOutlet UIButton*deviceoffBtn;
    MBProgressHUD* HUD;
    IBOutlet UIImageView* deviceoffImg;
    IBOutlet UILabel* deviceonoffLbl;
    IBOutlet UIImageView* logoImg;
}

-(void)intializeble;
-(void)switchOn;
-(void)switchOff;
- (IBAction)didActionDeviceDashboard:(id)sender;
- (IBAction)didActionDeviceSettings:(id)sender;
- (IBAction)didActionManageDeviceSettings:(id)sender;
- (IBAction)didActionAboutValert:(id)sender;
- (IBAction)deviceswitchoffandonAction:(id)sender;

@property (strong, nonatomic)BLEConnectionClass *ObjBLEConnection;
@property(strong,nonatomic) CBPeripheral*normalPeriperal;
@property (strong, nonatomic) IBOutlet UIButton *btnDeviceDashboard;
@property (strong, nonatomic) IBOutlet UIButton *btnDeviceSettings;
@property (strong, nonatomic) IBOutlet UIButton *btnManageDevices;
@property (strong, nonatomic) IBOutlet UIButton *btnAboutValert;
@property (strong, nonatomic) IBOutlet UILabel *lblHomeText;
@property (strong, nonatomic) IBOutlet UILabel *lblNotifyEnableDisableTextsandCalls;
@property (strong, nonatomic) IBOutlet UILabel *lblNotifyValertDeviceSilentMode;
@property (strong, nonatomic) IBOutlet UILabel *lblNotifyPhoneApplicationSilentMode;
@property (retain, nonatomic) NSTimer *vibrateTimer;
@property (retain, nonatomic) NSTimer *falldetectTimer;

@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomimgView;
@property (strong, nonatomic) IBOutlet UIImageView *bottomlineView;
@property (strong, nonatomic) IBOutlet UILabel *lblDeviceDashboard;
@property (strong, nonatomic) IBOutlet UILabel *lblDeviceSettings;
@property (strong, nonatomic) IBOutlet UILabel *lblmanageDevice;
@property (strong, nonatomic) IBOutlet UILabel *lblhelp;
@property (strong, nonatomic) IBOutlet UILabel *lbltextCalls;
@property (strong, nonatomic) IBOutlet UILabel *lblSilent;
@property (strong, nonatomic) IBOutlet UILabel *lblvAlertDevice;
@property (strong, nonatomic) IBOutlet UILabel *lblphoneApp;
@property (strong, nonatomic) IBOutlet UIImageView *imgAlertDev;
@property (strong, nonatomic) IBOutlet UIImageView *imgphoneApp;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLine;

@property(strong,nonatomic)IBOutlet UIView *dashBoardView;
@property(strong,nonatomic)IBOutlet UIView *valrtView;
@property(strong,nonatomic)IBOutlet UIView *manageDeviceView;
@property(strong,nonatomic)IBOutlet UIView *helpView;
@end
