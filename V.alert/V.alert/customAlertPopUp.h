#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SharedData.h"

@interface customAlertPopUp : UIView
{
    IBOutlet UIView *viewAlertPopUp;
    IBOutlet UIImageView *imgViewBG;
    IBOutlet UILabel *lblAlertMessage;
     IBOutlet UIButton *btnOk;
    IBOutlet UIImageView *imgViewSelfViewBG;
    IBOutlet UIImageView *imgViewCancel;
}

@property (strong, nonatomic) IBOutlet UILabel *lblInternetConnectionStatus;


@property (strong, nonatomic) IBOutlet UIButton *btnPopupViewLoad;
@property (nonatomic, strong) IBOutlet UILabel *lblAlertMessage;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewBG;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *rootView;
@property (weak, nonatomic) IBOutlet UIView *confirmBar;

+(customAlertPopUp *)sharedInstance;


- (void)didCustomPopUpAlertLoad:(UIView *)parentView andtitle:(NSString *)strTitle;
-(IBAction)didActionOkAlertPopUp:(id)sender;
-(void)didCustomPopUpUnload;

@end
