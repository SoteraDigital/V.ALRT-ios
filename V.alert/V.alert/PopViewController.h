#import <UIKit/UIKit.h>

@interface PopViewController : UIViewController {

    UIImageView *findImage;
    NSString *deviceName;
    IBOutlet UILabel*bottomTxtLbl;
}
@property(strong,nonatomic)IBOutlet UILabel *findVALRTDeviceLabel;
- (IBAction)didActionBackViewController:(id)sender;
@property(strong,nonatomic) NSString *deviceName;
@property (strong, nonatomic) IBOutlet UIButton *btnDoneaction;

@end
