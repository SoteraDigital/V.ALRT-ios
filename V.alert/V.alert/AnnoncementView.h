#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SharedData.h"
#import "Constants.h"
#import "ContactsData.h"
#import "SharedData.h"

typedef void (^OnAnnouncementSelect)(int);
@interface AnnoncementView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableViewAnnouncement;
@property (strong, nonatomic) IBOutlet UILabel *labelAnnouncementTitle;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *rootView;
@property (copy, nonatomic) OnAnnouncementSelect onAnnouncementSelect;
@property (weak, nonatomic) IBOutlet UIView *titleBar;

+(AnnoncementView *)sharedInstance;
-(id)initWithView;
- (void)didAnnouncementViewLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect;
-(void)didAnnouncemntViewUnload;
- (IBAction)actionDidHideAnnoucementList:(id)sender;

@end
