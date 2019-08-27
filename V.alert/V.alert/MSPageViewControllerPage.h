#import <UIKit/UIKit.h>

#import "MSPageViewController.h"
#import <MediaPlayer/MediaPlayer.h>
@interface MSPageViewControllerPage : UIViewController <MSPageViewControllerChild, UIAlertViewDelegate>
{
    IBOutlet UINavigationBar *navigationBar;
    IBOutlet UIImageView*puckImageView;
    IBOutlet UIButton*setupBtn;
    IBOutlet UIButton*buyonlineBtn;
     IBOutlet UIView *tourPageOverlayView;
    IBOutlet UILabel *headerLbl;
    IBOutlet UILabel *contentLbl;
    MPMoviePlayerViewController *movieController;
   IBOutlet UIImageView *puckAnimation;
}
-(IBAction)playVideo:(id)sender;
@property (nonatomic, retain) IBOutlet UIView *tourPageOverlayView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;

@end
