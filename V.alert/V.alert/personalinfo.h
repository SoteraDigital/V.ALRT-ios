#import <UIKit/UIKit.h>
#import "ZSYPopoverListView.h"
@interface personalinfo : UIViewController<ZSYPopoverListDatasource, ZSYPopoverListDelegate,UITextFieldDelegate>
{
    IBOutlet UILabel *nameLbl;
    IBOutlet UILabel *countrydftLbl;
    IBOutlet UILabel *phonenoLbl;
    IBOutlet UILabel *countryTxtLbl;
    IBOutlet UITextField *nameField;
    IBOutlet UITextField *phonenoField;
    NSArray*countryArr;
    NSArray*countrycodeArr;
    ZSYPopoverListView *listView;
    IBOutlet UIButton *nextBtn;
    IBOutlet UIView *personalinfoView;
}
@property (weak, nonatomic) IBOutlet UILabel *personalInfoTitle;
- (IBAction)nextAction:(id)sender;
-(void)clearallContacts;
- (IBAction)backAction:(id)sender;
-(IBAction)countryTap:(id)sender;
-(void)languagetranslate;
@end
