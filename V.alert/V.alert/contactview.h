#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
@interface contactview : UIViewController<ABPeoplePickerNavigationControllerDelegate,UITextFieldDelegate>
{
    int currentIndex;
    IBOutlet UILabel *txtLbl;
    IBOutlet UILabel *callLbl;
    IBOutlet UILabel *contactLbl;
    IBOutlet UILabel *addContactLbl;
    IBOutlet UIView *contactView;
     ABPeoplePickerNavigationController *pickContactViewController;
    IBOutlet UIButton *nextBtn;
    NSString *contactname;
    NSArray *contactnum;
    
}
@property (weak, nonatomic) IBOutlet UILabel *addContactTitle;
@property (weak, nonatomic) IBOutlet UIView *contactTitleBar;
- (IBAction)backAction:(id)sender;
-(void)checkEnableNextbtn;
-(void)bindContactsandcall;
-(void)bindEnabletextCall;
-(void)addContact:(int)tagIndex;
-(BOOL)checkEnable:(int)tagIndex;
-(void)enabledisableText:(int)tagIndex;
-(void)enabledisableCall:(int)tagIndex;
- (IBAction)frameTapGesture:(id)sender;
-(void)removeContact:(int)tagIndex;
-(void)alertMessage;
- (IBAction)contactAction:(id)sender;
- (IBAction)textAction:(id)sender;
- (IBAction)callAction:(id)sender;

@end
