#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SharedData.h"

@interface editContactPopUp : UIView
{
    IBOutlet UIView *viewAlertPopUp;
    IBOutlet UIImageView *imgViewBG;
    IBOutlet UILabel *lblAlertMessage;
     IBOutlet UIButton *btnOk;
    IBOutlet UIImageView *imgViewSelfViewBG;
    IBOutlet UIImageView *imgViewCancel;
    editContactPopUp *newView;
    
}

@property (strong, nonatomic) IBOutlet UILabel *lblInternetConnectionStatus;


@property (strong, nonatomic) IBOutlet UIButton *btnPopupViewLoad;
@property (nonatomic, strong) IBOutlet UILabel *lblAlertMessage;
@property (nonatomic, strong) IBOutlet UILabel *lblAlertMessagetext2;
@property (nonatomic, strong) IBOutlet UITextField *contactField;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewBG;
@property (weak, nonatomic) IBOutlet UIView *titleBar;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *rootView;

+(editContactPopUp *)sharedInstance;

- (void)changeText:(NSString *)titelTxt;

- (void)didCustomPopUpAlertLoad:(UIView *)parentView
                       strTitle:(NSString *)strTitle
                      strTitle2:(NSString *)strTitle2
                       txtTitle:(NSString *)txtTitle;
-(IBAction)didActionOkAlertPopUp:(id)sender;
-(void)didCustomPopUpUnload;

@end
