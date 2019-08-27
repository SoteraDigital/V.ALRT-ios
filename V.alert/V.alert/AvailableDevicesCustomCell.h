#import <UIKit/UIKit.h>

@interface AvailableDevicesCustomCell : UITableViewCell
//Arun
//Actions
- (IBAction)didActionAddDevices:(id)sender;
//Instances Properties
@property (strong, nonatomic) IBOutlet UIButton *btnAddDevices;
@property (strong, nonatomic) IBOutlet UILabel *lblAvailableDeviceName;
@property (strong, nonatomic) IBOutlet UILabel *lblnoAvailableDeviceName;
@property (strong, nonatomic) IBOutlet UILabel *lblAvailableDeviceId;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *actIvityIndicatorView;

@end
