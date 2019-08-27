#import <UIKit/UIKit.h>
#import "Constants.h"
@protocol settingManageDelegate
@optional
@required
-(void) calltextEnableDisable ;
@end

@interface SettingsManageContactsCell : UITableViewCell
@property (nonatomic,assign) id <settingManageDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *imgViewManageContactIndication;
@property (strong, nonatomic) IBOutlet UILabel *lblAddContact;
@property (strong, nonatomic) IBOutlet UIView *viewEnableSettings;


@property (strong, nonatomic) IBOutlet UIButton *btnEnableForText;
@property (strong, nonatomic) IBOutlet UIButton *btnEnableForCall;


@property (nonatomic) BOOL isCallEnabled;
@property (nonatomic) BOOL isTextEnabled;

- (IBAction)didActionEnableMakeCall:(id)sender;
- (IBAction)didActionEnableSendText:(id)sender;
@end
