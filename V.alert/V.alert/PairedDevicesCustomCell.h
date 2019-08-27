#import <UIKit/UIKit.h>

@interface PairedDevicesCustomCell : UITableViewCell
{


}
//created by Arun
@property (strong, nonatomic) IBOutlet UIButton *btnDeleteDevices;
@property(nonatomic,retain)IBOutlet UILabel*lblPaireddevice;
@property(nonatomic,retain)IBOutlet UILabel*lblnoPaireddevice;
@property(nonatomic,retain)IBOutlet UILabel*lblDetectdevice;
@property (strong, nonatomic) IBOutlet UILabel *lblPairedDeviceId;

@end
