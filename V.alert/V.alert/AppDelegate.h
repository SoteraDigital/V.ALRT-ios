#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "AlertInProgress.h"
#import "ManageDevicesViewController.h"
#import "Reachability.h"
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>{
    
    NSMutableArray *dataArray;
    
    ManageDevicesViewController *manageDevice;
    
    int repeatToneFlag;
    NSTimer*falldetectTimer;
    int secondsLeft,seconds;
    NSUserDefaults *pref;
    __block BOOL isBlockCancel;
    BOOL alertBool;
    dbConnect*dConnect;
    CTCallCenter*_callCenter;
    CLLocationManager *locationManager;
}
-(void)callObserver;
-(void)launchNotification;
@property (strong, nonatomic) ManageDevicesViewController *manageDevice;
@property (nonatomic, assign) int repeatToneFlag;
@property (nonatomic, assign) int inCall;
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) NSTimer *vibrateTimer;
@property (strong, nonatomic) NSMutableArray *dataArray;
//Reachability
@property (nonatomic,retain) Reachability *internetReachability;
@end
