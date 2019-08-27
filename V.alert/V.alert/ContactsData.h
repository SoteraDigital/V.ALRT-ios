#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TCDevice.h"
#import "TCConnection.h"
#import "ServerResponseObject.h"
#import "dbConnect.h"
@import AVFoundation;


@interface ContactsData : NSObject <CLLocationManagerDelegate, TCConnectionDelegate, TCDeviceDelegate>
{
    BOOL _speakerEnabled;
    
	TCDevice* _device;
    TCConnection * _connection;
    
    int _currentCallIndex;
    int _smsSentFlag;
    NSURLConnection*connection;
    int disConnectCall;
    int failedCallRetryCount;
    int failedFirstSmsRetryCount;
    int failedSecondSmsRetryCount;
    double latitude;
    double longitude;
    int callIntiate;
    CLLocationManager *locationManager;
    CLLocation *bestEffortAtLocation;
    
    BOOL isIncomingVOIPEnabled;
    BOOL shouldSendThirdSMS;
    
    ServerResponseObject *serverResponseObject;
    
    SystemSoundID ringtoneSound;
    dbConnect* dConnect;
    BOOL didReceiveConnectCallback;
    BOOL didReceiveStartConnectingCallback;
    
    
    NSTimer *twilioConnectCallbackTimer;
    NSTimer *twilioStartConnectingCallbackTimer;
}
typedef void (^responseBlock)(NSString *token);
-(void)getCapabilityToken:(responseBlock) completionBlock;
@property (assign) SystemSoundID ringtoneSound;
@property (nonatomic, retain) TCDevice* _device;
@property (nonatomic, retain) NSTimer *twilioStartConnectingCallbackTimer;
@property (nonatomic, retain) NSTimer *twilioConnectCallbackTimer;

@property (assign) BOOL didReceiveConnectCallback;
@property (assign) BOOL didReceiveStartConnectingCallback;
@property (nonatomic, assign) BOOL shouldSendThirdSMS;
@property (nonatomic, retain) ServerResponseObject *serverResponseObject;

@property (nonatomic, assign) BOOL isIncomingVOIPEnabled;

@property (nonatomic, retain) CLLocation *bestEffortAtLocation;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *firstNames;
@property (nonatomic, strong) NSString *lastNames;

@property (nonatomic, strong) NSMutableArray *contactNames;
@property (nonatomic, strong) NSMutableArray *contactNumbers;

@property (retain,nonatomic) NSArray *systemSounds;
@property (retain,nonatomic) NSDictionary *dictMessageResponse;


@property (retain,nonatomic)  NSMutableArray *arrTextIndices;
@property (retain,nonatomic)  NSMutableArray *arrNumberindices;

@property (retain,nonatomic)  NSMutableArray *arrSendTextMessage;
@property (retain,nonatomic)  NSMutableArray *arrCallNumbers;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, retain) NSTimer *ringToneTimer;
-(void) noInternet;
-(void)initiateCall;
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
//VOIP Related
-(void)setSpeakerEnabled:(BOOL)enabled;

//Twilio
-(void)connect:(NSString*)phoneNumber;
-(void)disconnect;
-(id)initTwilioCall;
//-------------------------------------
-(void)verifyAndInitTwilioIncomingCall;

+ (ContactsData *) sharedConstants;
- (void)loadSystemSoundsss;
-(void)sendSMS;
-(void)retrySms;
-(void)sendcelltoweSms;
-(void)setNumbers:(NSMutableArray *)phoneNumbers;
-(void)setEmails:(NSMutableArray *)emailIDs;
-(void)manageTextsandCalls;
-(void)didReceiveConnectedCallbackTimerExpired:(NSTimer *)timer;
-(void)didReceiveStartConnectingCallbackTimerExpired:(NSTimer *)timer;
@end
