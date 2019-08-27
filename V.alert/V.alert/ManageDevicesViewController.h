#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "AvailableDevicesCustomCell.h"
#import "PairedDevicesCustomCell.h"
#import "DeviceDashboardViewController.h"
#import "SharedData.h"
#import "dbConnect.h"
#import "AlertInProgress.h"
#import "MBProgressHUD.h"

@interface ManageDevicesViewController : UIViewController<BLEConnectionDelegate,alertinDelegate,UIAlertViewDelegate,UITextFieldDelegate,MBProgressHUDDelegate>{
    
    BLEConnectionClass *ObjBLEConnection; //BLE Device connection class (private)
    DeviceDashboardViewController *ObjDeviceDashBoard;
    CBPeripheral *activePeripheral;
    NSData *receivedData;
    
    IBOutlet UILabel *headerLabel;
    IBOutlet UIImageView * imageView;
    IBOutlet UIImageView * handimageView;
    UIView *loadingView;
    UILabel*timerLbl;
    UILabel*falldetectLbl;
    UIButton *cancelbutton;
    int hours, minutes, seconds;
    int secondsLeft;
    dbConnect *dConnect;
    NSTimer*scanTimer;
    NSTimer *scanTimerForDeviceStatus;
    UIAlertView *alertBox1;
    IBOutlet UIView *availableView;
    IBOutlet UIView * manageimageView;
    UIActivityIndicatorView *activityManage;
    MBProgressHUD *HUD;//Progress view
}
-(void)tableviewreloaddata;
-(void)checkAvailableorPaired;
//Button Actions for Back and Next
- (IBAction)didActionBackViewController:(id)sender;
- (IBAction)didActionNextViewController:(id)sender;
- (IBAction)pairedDeviceAction:(id)sender;
- (IBAction)AvailableDeviceAction:(id)sender;



//Instance Properties
@property(strong,nonatomic)BLEConnectionClass *ObjBLEConnection;
@property(strong,nonatomic) CBPeripheral*normalPeriperal;
@property(strong,nonatomic) CBPeripheral*activePeripheral;
@property (strong, nonatomic) IBOutlet UIButton * btnActionBack;
@property (strong, nonatomic) IBOutlet UIButton * btnActionNext;
@property (strong, nonatomic) IBOutlet UITableView * tblViewPairedDevices;
@property (strong, nonatomic) IBOutlet UITableView * tblViewAvailableDevices;
@property (retain, nonatomic) NSTimer *vibrateTimer;
@property (retain, nonatomic) NSTimer *falldetectTimer;
@property (weak, nonatomic) IBOutlet UIView *manageImageBar;
@property (weak, nonatomic) IBOutlet UILabel *handImageLabel;
@property (strong, nonatomic) IBOutlet UILabel *activateLbl;

@property(strong,nonatomic)IBOutlet UILabel *handSecondsLbl;
-(void)invalidateTimer;


@end
