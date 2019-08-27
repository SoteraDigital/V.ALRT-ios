#import "BLEConnectionClass.h"
#import "AlertInProgress.h"
#import "dbConnect.h"
#import "CountryPicker.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface vsnsettingsviewcontroller : UIViewController<ABPeoplePickerNavigationControllerDelegate,BLEConnectionDelegate,alertinDelegate,CountryPickerDelegate,UITextFieldDelegate>
{
    BLEConnectionClass *ObjBLEConnection;
    NSString*alertMsg;
    NSString*alertTitle;
    NSString*countryNameStr;
    NSString*countryCodeStr;
    int currentIndex;
    IBOutlet UIView *contactView;
    IBOutlet UIView *messageView;
    IBOutlet UIView *soundView;
     IBOutlet UIView *CountryView;
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
    IBOutlet UILabel *devicetrackerStatusLbl;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *phoneField;
     IBOutlet UITextField *countryField;
    IBOutlet UIView *personalInfoSubview;
    IBOutlet UIScrollView *baseScroll;
    ABPeoplePickerNavigationController *pickContactViewController;
    int btnNextFlag;
    
    dbConnect *dConnect;
    NSString *contactname;
    NSArray *contactnum;
    
}
@property(strong,nonatomic) CBPeripheral*normalPeriperal;
@property(strong,nonatomic) BLEConnectionClass  *ObjBLEConnection;
@property (strong, nonatomic) IBOutlet UIView *viewShowAlertMessage;
@property (strong, nonatomic) IBOutlet UIView *viewShowPersonalinfo;
@property (strong, nonatomic) IBOutlet UITextView *txtFieldEnterAlertMessage;
@property (weak, nonatomic) IBOutlet UIView *contactViewBar;
@property (weak, nonatomic) IBOutlet UIView *trackerViewBar;
-(void)languagetranslate;
-(void)bindContactsandcall;
-(void)bindEnabletextCall;
-(void)drawLines;
-(void)checkEnableNextbtn;
-(BOOL)checkEnable:(int)tagIndex;
-(void)enabledisableText:(int)tagIndex;
-(void)enabledisableCall:(int)tagIndex;
-(void)addContact:(int)tagIndex;
- (IBAction)advanceview:(id)sender;
- (IBAction)frameTapGesture:(id)sender;
-(void)alertMessage;
-(void)removeContact:(int)tagIndex;
- (IBAction)contactAction:(id)sender;
- (IBAction)textAction:(id)sender;
- (IBAction)callAction:(id)sender;
- (IBAction)cancelAction:(id)sender;
- (IBAction)backAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)nextAction:(id)sender;
@end
