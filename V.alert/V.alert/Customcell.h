#import <UIKit/UIKit.h>

@interface Customcell : UITableViewCell
{
    UILabel *primaryLabel;
	UILabel *secondaryLabel;
	UILabel *thirdLabel;
    
    
}

@property(nonatomic,retain)UILabel *primaryLabel;
@property(nonatomic,retain)UILabel *secondaryLabel;
@property(nonatomic,retain)UILabel *thirdLabel;
@property(nonatomic,retain)UILabel *devicetxtLabel;
@property(nonatomic,retain)UILabel *serialtxtLabel;
@property(nonatomic,retain)UILabel *sofverLabel;
@end
