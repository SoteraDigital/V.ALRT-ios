#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SharedData.h"
#import "Constants.h"
#import "ContactsData.h"
#import "SharedData.h"
@protocol alertinDelegate
@optional
-(void) keyfall ;
@end
typedef void (^OnAnnouncementSelect)(int);
@interface AlertInProgress : UIView<UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
{
    UIView *loadingView;
    UILabel*timerLbl;
    UILabel*falldetectLbl;
    UIButton *cancelbutton;
    IBOutlet UILabel*noContactsLbl;
    int hours, minutes, seconds;
    int secondsLeft;
    
    UIImage *checkmark;
    
    int _currentCallIndex; //For VOIP - helps keep track of which call we are dialing
    BOOL _isIncomingVOIPEnabled;
    BOOL _isCallInProgress;
    
    NSTimer*vibrateTimer;
    int _smssentFlag;
    int _smsFailure;
    
    // Tracker : Declaration for Tracker in progress view and some Boolien Values
    UIView *deviceConnectionView;
    BOOL _isKeepFlashOn;
    BOOL isFirstTimeMusicPlaying;
    NSMutableArray*contactNames;
    NSMutableArray*callcontactNames;
}

@property(nonatomic, strong)AVAudioPlayer *player; // Tracker : To Play Music
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskForAudio; // TO Play Music File in background state
@property (assign) SystemSoundID pewPewSound;
@property (nonatomic, assign) BOOL _isCallInProgress;
@property (nonatomic, assign) BOOL _isIncomingVOIPEnabled;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic,assign) id <alertinDelegate> delegate;
@property (retain, nonatomic) NSTimer *falldetectTimer;
@property (strong, nonatomic) IBOutlet UITableView *tableViewAnnouncement;
@property (strong, nonatomic) IBOutlet UILabel *labelAnnouncementTitle;
@property (strong, nonatomic) UIImage *checkmark;
@property (strong, nonatomic) NSTimer*vibrateTimer;

@property (weak, nonatomic) IBOutlet UIImageView *imgViewBackground;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *rootView;
@property (copy, nonatomic) OnAnnouncementSelect onAnnouncementSelect;
@property(strong,nonatomic)IBOutlet UIButton *cancelAllBtn;
@property (weak, nonatomic) IBOutlet UIView *titleBar;

- (void)didAnnouncementDeviceConnect:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect; // Tracker : Setup Progress View
-(void)cancelAlertView; // Tracker : Cancel Progress View
-(void)cancelAllActions;//


+(AlertInProgress *)sharedInstance;
-(id)initWithView;
- (void)didAnnouncementViewLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect;
- (void)didAnnouncementfallLoad:(UIView *)parentView andAnnouncementSelect:(OnAnnouncementSelect)announcementSelect;
-(void)didAnnouncemntViewUnload;
-(void)didAnnouncemntViewfallUnload;
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
- (IBAction)actionDidHideAnnoucementList:(id)sender;

-(void)smsSent:(NSNotification *)notification;
//VOIP related
-(void)isConnecting;
-(void)didConnect:(NSNotification *)notification;
-(void)didDisconnect:(NSNotification *)notification;
-(void)didReceiveIncomingCall:(NSNotification *)notification;
@end
