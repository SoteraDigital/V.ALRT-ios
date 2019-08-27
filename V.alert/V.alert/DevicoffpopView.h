#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

//User Defined Header

//Define blocks
typedef void (^OnConfirm)(BOOL);

// for three buttons
typedef void (^OnClickedCallback)(int);

@interface DevicoffpopView : UIView
@property (strong, nonatomic) UIWindow *window;



@property (strong, nonatomic) IBOutlet UILabel *lblContent;

@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;
@property(strong,nonatomic)IBOutlet UIButton *noBtn;
@property(strong,nonatomic)IBOutlet UIButton *yesBtn;
@property (assign, nonatomic) int noOfButtons;

@property (strong, nonatomic) id delegate;
@property (copy, nonatomic) OnConfirm onConfirm;
@property (strong, nonatomic) UIView *rootView;

@property (copy, nonatomic) OnClickedCallback onClicked;
@property (weak, nonatomic) IBOutlet UIView *confirmBar;
@property (weak, nonatomic) IBOutlet UIView *confirmBarVertical;

- (IBAction)actionOk:(id)sender;
- (IBAction)actionCancel:(id)sender;



+(DevicoffpopView *)sharedInstance;
-(id)initWithView;

-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andConfirmationViewCallback:(OnConfirm)callback;
 
-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andConfirmationViewCallback:(OnConfirm)callback andImagePath:(NSString *)imagePath;
-(void)didConfirmationViewUnload;

// Added by #Sneha
-(void)didConfirmationViewLoad:(UIView *)parentView andConfirmationViewTitle:(NSString *)strConfirmationViewTitle andConfirmationViewContent:(NSString *)strConfirmationViewContent andButtonTitle:(NSArray *)buttonNames andConfirmationViewCallback:(OnClickedCallback)callback;

//Implements the following method
/*
 
  -(void)didConfirmationOk;
  -(void)didConfirmationCancel;

 */

- (void)rotateView;

@end
