#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "BLEConnectionClass.h"
#import "SharedData.h"

#import "ManageDevicesViewController.h"



@interface ViewController : UIViewController<BLEConnectionDelegate>{
    
    BLEConnectionClass *ObjBLEConnection; //BLE Device connection class (private)
    ManageDevicesViewController *ObjManageDevicesViewController;
    BOOL isFirstTime;
    CLLocationManager *locationManager;
    NSTimer *progressTimer;
    float progressValue;
}

-(void)startLoading;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorSplash;
@property (strong, nonatomic) IBOutlet UIImageView *imageSplashScreen;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@end
