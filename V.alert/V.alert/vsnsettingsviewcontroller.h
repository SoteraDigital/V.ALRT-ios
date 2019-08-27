#import <UIKit/UIKit.h>
#import "BLEConnectionClass.h"
#import "AlertInProgress.h"
#import "dbConnect.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface vsnsettingsviewcontroller : UIViewController<ABPeoplePickerNavigationControllerDelegate,BLEConnectionDelegate,alertinDelegate>
{
    NSString*alertMsg;
    NSString*alertTitle;
    int currentIndex;
    IBOutlet UIView *contactView;
    IBOutlet UIView *messageView;
    IBOutlet UIView *soundView;
    IBOutlet UIButton *deviceSilentBtn;
    IBOutlet UIButton *phoneSilentBtn;
    IBOutlet UIButton *backBtn;
    IBOutlet UIButton *nextBtn;
    IBOutlet UIButton *cancelBtn;
    IBOutlet UIButton *saveBtn;
    IBOutlet UILabel *alertsoundLbl;
    IBOutlet UILabel *silentmodeLbl;
    IBOutlet UILabel *valrtdevicemodeLbl;
    IBOutlet UILabel *phoneapplnmodeLbl;
    IBOutlet UILabel *alertsoundDftLbl;
    IBOutlet UILabel *personalInfoLbl;
    IBOutlet UILabel *personalinfoTitleLbl;
    IBOutlet UILabel *addeditLbl;
    IBOutlet UILabel *txtLbl;
    IBOutlet UILabel *callLbl;
    IBOutlet UILabel *navLbl;
    IBOutlet UILabel *contactLbl;
    IBOutlet UILabel *addContactLbl;
    IBOutlet UILabel *msgDefaultLbl;
    IBOutlet UILabel *messageLbl;
    IBOutlet UILabel *messageDescLbl;
    IBOutlet UILabel *messagetitleLbl;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *phoneField;
    IBOutlet UIView *personalInfoSubview;
    ABPeoplePickerNavigationController *pickContactViewController;
    int btnNextFlag;
    BLEConnectionClass *ObjBLEConnection;
    dbConnect *dConnect;
    
}
@property(strong,nonatomic) CBPeripheral*normalPeriperal;
@property (strong, nonatomic) IBOutlet UIView *viewShowAlertMessage;
@property (strong, nonatomic) IBOutlet UIView *viewShowPersonalinfo;
@property (strong, nonatomic) IBOutlet UITextView *txtFieldEnterAlertMessage;
-(void)languagetranslate;
-(void)bindContactsandcall;
-(void)bindEnabletextCall;
-(void)drawLines;
-(void)checkEnableNextbtn;
-(BOOL)checkEnable:(int)tagIndex;
-(void)enabledisableText:(int)tagIndex;
-(void)enabledisableCall:(int)tagIndex;
-(void)addContact:(int)tagIndex;
-(void)removeContact:(int)tagIndex;
- (IBAction)contactAction:(id)sender;
- (IBAction)textAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)nextAction:(id)sender;
@end
