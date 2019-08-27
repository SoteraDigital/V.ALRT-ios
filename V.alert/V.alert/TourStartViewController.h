#import <UIKit/UIKit.h>

@interface TourStartViewController : UIViewController
{
    IBOutlet UINavigationBar *navigationBar;
    
    IBOutlet UIImageView *puckImageView;
    IBOutlet UIButton*setupBtn;
    IBOutlet UIButton*buyonlineBtn;
    UIImageView *puckAnimation;
}

@property (nonatomic, retain) IBOutlet UIImageView *puckImageView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@end
