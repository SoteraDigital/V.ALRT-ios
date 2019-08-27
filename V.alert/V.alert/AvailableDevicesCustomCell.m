#import "AvailableDevicesCustomCell.h"

@implementation AvailableDevicesCustomCell
//Coded by Arun
@synthesize lblAvailableDeviceId,lblAvailableDeviceName,btnAddDevices,lblnoAvailableDeviceName;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (IBAction)didActionAddDevices:(id)sender {
    
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
