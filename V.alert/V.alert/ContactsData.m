#import "ContactsData.h"
#import "Constants.h"
#import "SharedData.h"
#import  "AlertInProgress.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "TCPresenceEvent.h"
#import "commonnotifyalert.h"
#import "AppDelegate.h"
#import "NSString+URLEncoding.h"
#import "logfile.h"


#import <AudioUnit/AudioUnit.h>


@implementation ContactsData

@synthesize firstNames,lastNames,contactNames,contactNumbers,systemSounds,dictMessageResponse,_device;
@synthesize arrSendTextMessage,arrCallNumbers,arrNumberindices,arrTextIndices,ringToneTimer,locationManager,bestEffortAtLocation,backgroundTask,ringtoneSound;

@synthesize isIncomingVOIPEnabled, shouldSendThirdSMS;
@synthesize serverResponseObject;
@synthesize didReceiveConnectCallback, didReceiveStartConnectingCallback;
@synthesize twilioConnectCallbackTimer;
@synthesize twilioStartConnectingCallbackTimer;

+ (ContactsData *) sharedConstants{
    // the instance of this class is stored here
    static ContactsData *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        
        
        myInstance.contactNames = [[NSMutableArray alloc]init];
        
        myInstance.contactNumbers = [[NSMutableArray alloc]init];
        
        myInstance.arrSendTextMessage=[[NSMutableArray alloc]init];
        
        myInstance.arrCallNumbers=[[NSMutableArray alloc]init];
        
    }
    // return the instance of this class
    return myInstance;
    
    
}

-(id)init
{
    NSLog(@"ContactsData::init -- ");
    if ( self = [super init] )
    {
        _speakerEnabled = YES; // enable the speaker by default
        
        // _connection = [[TCConnection alloc] init];
        
        // _device = [[TCDevice alloc] init];
        
        //@elg
        //added this for the notification of when the Twilio client connects
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(disconnect) name:@"TCConnectionShouldDisconnect" object:nil];
        
        _currentCallIndex = 0;
        
        //@Ed
        //added this for timer to check the call is not connected after 5ms
        didReceiveConnectCallback = NO;
        didReceiveStartConnectingCallback = NO;
        
        twilioConnectCallbackTimer = [[NSTimer alloc] init];
        twilioStartConnectingCallbackTimer = [[NSTimer alloc] init];
        
    }
    return self;
}



//Load System Sounds for Ringtones

- (void)loadSystemSoundsss{
    // The following information was extracted from http://iphonedevwiki.net/index.php/AudioServices
    // Copied, parsed and transformed into NSDictionary init sentences.
    
    
    NSMutableArray *systemSoundsArray=[NSMutableArray array];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                        @"1000",  @"new-mail.caf",  @"new-mail.caf",  @"MailReceived", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1001",  @"mail-sent.caf",  @"mail-sent.caf",  @"MailSent", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1002",  @"Voicemail.caf",  @"Voicemail.caf",  @"VoicemailReceived", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1003",  @"ReceivedMessage.caf",  @"ReceivedMessage.caf",  @"SMSReceived", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1004",  @"SentMessage.caf",  @"SentMessage.caf",  @"SMSSent", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1005",  @"alarm.caf",  @"sq_alarm.caf",  @"CalendarAlert (Default)", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1006",  @"low_power.caf",  @"low_power.caf",  @"LowPower", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1007",  @"sms-received1.caf",  @"sms-received1.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1008",  @"sms-received2.caf",  @"sms-received2.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1009",  @"sms-received3.caf",  @"sms-received3.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1010",  @"sms-received4.caf",  @"sms-received4.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1011",  @"-",  @"-",  @"SMSReceived_Vibrate", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1012",  @"sms-received1.caf",  @"sms-received1.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1013",  @"sms-received5.caf",  @"sms-received5.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1014",  @"sms-received6.caf",  @"sms-received6.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1015",  @"Voicemail.caf",  @"Voicemail.caf",  @"Voicemail", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1016",  @"tweet_sent.caf",  @"tweet_sent.caf",  @"SMSSent", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1020",  @"Anticipate.caf",  @"Anticipate.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1021",  @"Bloom.caf",  @"Bloom.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1022",  @"Calypso.caf",  @"Calypso.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1023",  @"Choo_Choo.caf",  @"Choo_Choo.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1024",  @"Descent.caf",  @"Descent.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1025",  @"Fanfare.caf",  @"Fanfare.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1026",  @"Ladder.caf",  @"Ladder.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1027",  @"Minuet.caf",  @"Minuet.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1028",  @"News_Flash.caf",  @"News_Flash.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1029",  @"Noir.caf",  @"Noir.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1030",  @"Sherwood_Forest.caf",  @"Sherwood_Forest.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1031",  @"Spell.caf",  @"Spell.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1032",  @"Suspense.caf",  @"Suspense.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1033",  @"Telegraph.caf",  @"Telegraph.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1034",  @"Tiptoes.caf",  @"Tiptoes.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1035",  @"Typewriters.caf",  @"Typewriters.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1036",  @"Update.caf",  @"Update.caf",  @"SMSReceived_Alert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1050",  @"ussd.caf",  @"ussd.caf",  @"USSDAlert", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1051",  @"SIMToolkitCallDropped.caf",  @"SIMToolkitCallDropped.caf",  @"SIMToolkitTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1052",  @"SIMToolkitGeneralBeep.caf",  @"SIMToolkitGeneralBeep.caf",  @"SIMToolkitTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1053",  @"SIMToolkitNegativeACK.caf",  @"SIMToolkitNegativeACK.caf",  @"SIMToolkitTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1054",  @"SIMToolkitPositiveACK.caf",  @"SIMToolkitPositiveACK.caf",  @"SIMToolkitTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1055",  @"SIMToolkitSMS.caf",  @"SIMToolkitSMS.caf",  @"SIMToolkitTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1057",  @"Tink.caf",  @"Tink.caf",  @"PINKeyPressed", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1070",  @"ct-busy.caf",  @"ct-busy.caf",  @"AudioToneBusy", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1071",  @"ct-congestion.caf",  @"ct-congestion.caf",  @"AudioToneCongestion", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1072",  @"ct-path-ack.caf",  @"ct-path-ack.caf",  @"AudioTonePathAcknowledge", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1073",  @"ct-error.caf",  @"ct-error.caf",  @"AudioToneError", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1074",  @"ct-call-waiting.caf",  @"ct-call-waiting.caf",  @"AudioToneCallWaiting", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1075",  @"ct-keytone2.caf",  @"ct-keytone2.caf",  @"AudioToneKey2", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    //  [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1100",  @"lock.caf",  @"sq_lock.caf",  @"ScreenLocked", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    // [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1101",  @"unlock.caf",  @"sq_lock.caf",  @"ScreenUnlocked", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    // [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1102",  @"-",  @"-",  @"FailedUnlock", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1103",  @"Tink.caf",  @"sq_tock.caf",  @"KeyPressed", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    // [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1104",  @"Tock.caf",  @"sq_tock.caf",  @"KeyPressed", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    //[systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1105",  @"Tock.caf",  @"sq_tock.caf",  @"KeyPressed", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    // [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1106",  @"beep-beep.caf",  @"sq_beep-beep.caf",  @"ConnectedToPower", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1107",  @"RingerChanged.caf",  @"RingerChanged.caf",  @"RingerSwitchIndication", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1108",  @"photoShutter.caf",  @"photoShutter.caf",  @"CameraShutter", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1109",  @"shake.caf",  @"shake.caf",  @"ShakeToShuffle", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1110",  @"jbl_begin.caf",  @"jbl_begin.caf",  @"JBL_Begin", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1111",  @"jbl_confirm.caf",  @"jbl_confirm.caf",  @"JBL_Confirm", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1112",  @"jbl_cancel.caf",  @"jbl_cancel.caf",  @"JBL_Cancel", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1113",  @"begin_record.caf",  @"begin_record.caf",  @"BeginRecording", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1114",  @"end_record.caf",  @"end_record.caf",  @"EndRecording", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1115",  @"jbl_ambiguous.caf",  @"jbl_ambiguous.caf",  @"JBL_Ambiguous", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1116",  @"jbl_no_match.caf",  @"jbl_no_match.caf",  @"JBL_NoMatch", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1117",  @"begin_video_record.caf",  @"begin_video_record.caf",  @"BeginVideoRecording", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1118",  @"end_video_record.caf",  @"end_video_record.caf",  @"EndVideoRecording", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1150",  @"vc~invitation-accepted.caf",  @"vc~invitation-accepted.caf",  @"VCInvitationAccepted", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1151",  @"vc~ringing.caf",  @"vc~ringing.caf",  @"VCRinging", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1152",  @"vc~ended.caf",  @"vc~ended.caf",  @"VCEnded", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1153",  @"ct-call-waiting.caf",  @"ct-call-waiting.caf",  @"VCCallWaiting", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1154",  @"vc~ringing.caf",  @"vc~ringing.caf",  @"VCCallUpgrade", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1200",  @"dtmf-0.caf",  @"dtmf-0.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1201",  @"dtmf-1.caf",  @"dtmf-1.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1202",  @"dtmf-2.caf",  @"dtmf-2.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1203",  @"dtmf-3.caf",  @"dtmf-3.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1204",  @"dtmf-4.caf",  @"dtmf-4.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1205",  @"dtmf-5.caf",  @"dtmf-5.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1206",  @"dtmf-6.caf",  @"dtmf-6.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1207",  @"dtmf-7.caf",  @"dtmf-7.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1208",  @"dtmf-8.caf",  @"dtmf-8.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1209",  @"dtmf-9.caf",  @"dtmf-9.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1210",  @"dtmf-star.caf",  @"dtmf-star.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1211",  @"dtmf-pound.caf",  @"dtmf-pound.caf",  @"TouchTone", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1254",  @"long_low_short_high.caf",  @"long_low_short_high.caf",  @"Headset_StartCall", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1255",  @"short_double_high.caf",  @"short_double_high.caf",  @"Headset_Redial", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1256",  @"short_low_high.caf",  @"short_low_high.caf",  @"Headset_AnswerCall", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1257",  @"short_double_low.caf",  @"short_double_low.caf",  @"Headset_EndCall", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1258",  @"short_double_low.caf",  @"short_double_low.caf",  @"Headset_CallWaitingActions", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1259",  @"middle_9_short_double_low.caf",  @"middle_9_short_double_low.caf",  @"Headset_TransitionEnd", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1300",  @"Voicemail.caf",  @"Voicemail.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1301",  @"ReceivedMessage.caf",  @"ReceivedMessage.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1302",  @"new-mail.caf",  @"new-mail.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1303",  @"mail-sent.caf",  @"mail-sent.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1304",  @"alarm.caf",  @"sq_alarm.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1305",  @"lock.caf",  @"sq_lock.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1306",  @"Tock.caf",  @"sq_tock.caf",  @"KeyPressClickPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1307",  @"sms-received1.caf",  @"sms-received1.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1308",  @"sms-received2.caf",  @"sms-received2.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1309",  @"sms-received3.caf",  @"sms-received3.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1310",  @"sms-received4.caf",  @"sms-received4.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1311",  @"-",  @"-",  @"SMSReceived_Vibrate", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1312",  @"sms-received1.caf",  @"sms-received1.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1313",  @"sms-received5.caf",  @"sms-received5.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1314",  @"sms-received6.caf",  @"sms-received6.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1315",  @"Voicemail.caf",  @"Voicemail.caf",  @"SystemSoundPreview", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1320",  @"Anticipate.caf",  @"Anticipate.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1321",  @"Bloom.caf",  @"Bloom.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1322",  @"Calypso.caf",  @"Calypso.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1323",  @"Choo_Choo.caf",  @"Choo_Choo.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1324",  @"Descent.caf",  @"Descent.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1325",  @"Fanfare.caf",  @"Fanfare.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1326",  @"Ladder.caf",  @"Ladder.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1327",  @"Minuet.caf",  @"Minuet.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1328",  @"News_Flash.caf",  @"News_Flash.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1329",  @"Noir.caf",  @"Noir.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1330",  @"Sherwood_Forest.caf",  @"Sherwood_Forest.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1331",  @"Spell.caf",  @"Spell.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1332",  @"Suspense.caf",  @"Suspense.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1333",  @"Telegraph.caf",  @"Telegraph.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1334",  @"Tiptoes.caf",  @"Tiptoes.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1335",  @"Typewriters.caf",  @"Typewriters.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1336",  @"Update.caf",  @"Update.caf",  @"SMSReceived_Selection", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1350",  @"-",  @"-",  @"RingerVibeChanged", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"1351",  @"-",  @"-",  @"SilentVibeChanged", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    [systemSoundsArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:                                                                       @"4095",  @"-",  @"-",  @"Vibrate", nil] forKeys:[NSArray arrayWithObjects:@"soundId", @"iphoneFileName", @"ipodFileName", @"category",nil]]];
    self.systemSounds=[systemSoundsArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [[obj1 valueForKey:@"category"] compare:[obj2 valueForKey:@"category"] options:NSCaseInsensitiveSearch];
    }];
}

/**
Start GPS and call retry smsm to send sms
*/
-(void)sendcelltoweSms
{
    isIncomingVOIPEnabled = NO;
    callIntiate =0;
    NSLog(@"ContactsData::sendcelltoweSms -- ");
    if([CLLocationManager locationServicesEnabled]
       || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // dispatch_sync(dispatch_get_main_queue(),^ {
            self.bestEffortAtLocation = nil;
            self.locationManager = [[CLLocationManager alloc] init];
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                //[self.locationManager requestWhenInUseAuthorization];
                [self.locationManager requestAlwaysAuthorization];
            }
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.locationManager.distanceFilter = kCLDistanceFilterNone;
            self.locationManager.pausesLocationUpdatesAutomatically = NO;
            [self.locationManager startUpdatingLocation];
            
        }];
    }
    else
    {
        latitude =0;
        longitude = 0;
    }
    disConnectCall =0;
    failedFirstSmsRetryCount =0;
    _smsSentFlag = 0;
    [self retrySms];
    
    //Initate the call after 3 seconds
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self selector:@selector(initiateCall) userInfo:nil
                                        repeats:NO];
        
    });
}
///Retry logic for the 1st sms
-(void)retrySms
{
    NSLog(@"ContactsData::retrySms -- ");
    NSString* Msg;
    if([SharedData sharedConstants].fallDetection ==1)
    {
        Msg = NSLocalizedString(@"V.ALRT Fall From:", nil);
        [SharedData sharedConstants].fallDetection =0;
    }
    else
    {
        Msg = NSLocalizedString(@"V.ALRT Emergency From:", nil);
    }
    
    NSString*sepertatedString = [arrSendTextMessage componentsJoinedByString:@","];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        
        NSString *urlString =  [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/message",VOIP_SMS_CALL_URL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        [DEFAULTS objectForKey:@"userName"];
        [DEFAULTS objectForKey:@"phonenumber"];
        
        NSString *bodyString = [NSString stringWithFormat:@"serial_no=%@&numberOfSmsReceverOrEmergencyNumberList=%@&messageBodyContent=%@ %@ %@ %@,%@ &macId=%@",[SharedData sharedConstants].activeSerialno,[sepertatedString urlEncodeUsingEncoding:NSUTF8StringEncoding], [Msg urlEncodeUsingEncoding:NSUTF8StringEncoding],[DEFAULTS objectForKey:@"userName"],[DEFAULTS objectForKey:@"phonenumber"],[ [DEFAULTS objectForKey:ALERT_MESSAGE] urlEncodeUsingEncoding:NSUTF8StringEncoding],NSLocalizedString(@"my location to follow", nil),[SharedData sharedConstants].activeIdentifier];
        
        //Log the request url and parameter
        NSString*reqStr =[NSString  stringWithFormat:@"\n My 1st Sms request:%@",urlString];
        NSString*bodyStr =[NSString  stringWithFormat:@"\n My 1st Sms parameters:%@",bodyString];
        [[logfile logfileObj]  writeLog:reqStr];
        [[logfile logfileObj]  writeLog:bodyStr];
        
        
        NSLog(@"sent http data body %@",bodyString);
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
            if (!error)
            {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                int code = (int)[httpResponse statusCode];
                if(code !=200)
                {
                    ++self->failedFirstSmsRetryCount;
                    if(self->failedFirstSmsRetryCount <3)
                    {
                        [self retrySms];
                    }
                }
                NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"received data:%@", newStr);
                NSString*respStr = [NSString stringWithFormat:@"\n My 1st Sms response:%@",newStr];
                [[logfile logfileObj]  writeLog:respStr];
            }
            else
            {
                ++self->failedFirstSmsRetryCount;
                if(self->failedFirstSmsRetryCount <3)
                {
                    [self retrySms];
                    
                }
                NSLog(@"error in retry sms-%@",[error localizedDescription]);
                NSString*respStr = [NSString stringWithFormat:@"\n My 1st Sms response:%@",[error localizedDescription]];
                [[logfile logfileObj]  writeLog:respStr];
            }
        }];
        
    });
    
}


//Send sms function
-(void)sendSMS
{
    NSLog(@"ContactsData::sendSMS -- ");
    [self retrySms2];
}
-(void)verifyAndInitTwilioIncomingCall
{
    NSLog(@"ContactsData::verifyAndInitTwilioIncomingCall -- ");
    //Changes by ashok
    //@discussion-If call and sms has sent then intiate the incoming call
    //TODO: Anner only if we really sent SMS (ie. we had in the array text messages prepared and sent and users with text messaging enabled
    if(_smsSentFlag ==1
       && [[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"]
       && [arrSendTextMessage count] > 0)
    {
        [self initTwilioIncomingCall];
    }
}

//retry the second sms
-(void)retrySms2
{
    
    NSLog(@"ContactsData::retrySms2 -- ");
    NSString*Msg;
    NSString *stringURL;
    if(latitude==0 && longitude==0)
    {
        
        stringURL = NSLocalizedString(@"Location Unavailable", nil);
        Msg = NSLocalizedString(@"", nil);
    }
    else
    {
        stringURL = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%f,%f", latitude, longitude];
        Msg = NSLocalizedString(@"My estimated location is", nil);
    }
    //Stop the location manager
    [self.locationManager stopUpdatingLocation];
    
    
    NSLog(@"ContactsData::retrySms2 -- stringURL %@",stringURL);
    NSLog(@"ContactsData::retrySms2 -- arrSendTextMessage %d",(int)[arrSendTextMessage count]);
    
    NSString*sepertatedString = [arrSendTextMessage componentsJoinedByString:@","];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^
    {
        NSDate *now = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSString* str = [formatter stringFromDate:now];
        
        NSString *urlString = [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/message",VOIP_SMS_CALL_URL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString *bodyString = [NSString stringWithFormat:@"serial_no=%@&numberOfSmsReceverOrEmergencyNumberList=%@&messageBodyContent=%@ %@ %@&macId=%@",[SharedData sharedConstants].activeSerialno,[sepertatedString urlEncodeUsingEncoding:NSUTF8StringEncoding], [Msg urlEncodeUsingEncoding:NSUTF8StringEncoding],stringURL,str,[SharedData sharedConstants].activeIdentifier];
        
        NSString*reqStr =[NSString  stringWithFormat:@"\n My 2nd Sms request:%@",urlString];
        NSString*bodyStr =[NSString  stringWithFormat:@"\n My 2nd Sms parameters:%@",bodyString];
        [[logfile logfileObj]  writeLog:reqStr];
        [[logfile logfileObj]  writeLog:bodyStr];
        
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        //@Discussion - Ed 5.16.2014 -
        //Changed the queue to be NSOperationQueue main Queue instead of a
        //generic operation queue.  Twilio doesn't like to run on anything but the main thread.
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if (!error)
            {
                
                //Check response code from the server
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                int code = (int)[httpResponse statusCode];
                if(code !=200)
                {
                    self->failedSecondSmsRetryCount++;
                    if(self->failedSecondSmsRetryCount <3)
                    {
                        [self retrySms2];
                        
                    }
                    else
                    {
                        //Changes by ashok
                        //@discussion-If call and sms has sent then intiate the incoming call
                        self->_smsSentFlag =1;
                        if(self->_currentCallIndex ==4 && [[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"])
                        {
                            [self initTwilioIncomingCall];
                        }
                        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"response",[NSNumber numberWithBool:self->isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kSmsSent object:nil userInfo:options];
                        
                        //Expire the background task
                        if (self.backgroundTask != UIBackgroundTaskInvalid)
                        {
                            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                            self.backgroundTask = UIBackgroundTaskInvalid;
                        }
                    }
                }
                else
                {
                    //Changes by ashok
                    //@discussion-If call and sms has sent then intiate the incoming call
                    self->_smsSentFlag =1;
                    if(self->_currentCallIndex ==4 && [[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"])
                    {
                        [self initTwilioIncomingCall];
                    }
                    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"response",
                                             [NSNumber numberWithBool:self->isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSmsSent object:nil userInfo:options];
                    
                    //Expire the background task
                    if (self.backgroundTask != UIBackgroundTaskInvalid)
                    {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    }
                }
                NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@", newStr);
                NSString*respStr = [NSString stringWithFormat:@"\n My 2nd Sms response:%@",newStr];
                [[logfile logfileObj]  writeLog:respStr];
            }
            else
            {
                self->failedSecondSmsRetryCount++;
                if(self->failedSecondSmsRetryCount <3)
                {
                    [self retrySms2];
                    
                }
                else
                {
                    //Changes by ashok
                    //@discussion-If call and sms has sent then intiate the incoming call
                    self->_smsSentFlag =1;
                    if(self->_currentCallIndex ==4 && [[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"])
                    {
                        [self initTwilioIncomingCall];
                    }
                    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"response",
                                             [NSNumber numberWithBool:self->isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kSmsSent object:nil userInfo:options];
                    //Expire the background task
                    if (self.backgroundTask != UIBackgroundTaskInvalid)
                    {
                        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                        self.backgroundTask = UIBackgroundTaskInvalid;
                    }
                }
                NSLog(@"retrysms2 notification/message/error- code-%ld",(long)[error code]);
                NSLog(@"retrysms2 notification/message/error-%@",[error localizedDescription]);
                NSString*respStr = [NSString stringWithFormat:@"\n My 2nd Sms response:%@",[error localizedDescription]];
                [[logfile logfileObj]  writeLog:respStr];
            }
        }];
    });
    
    
}


///Send sms function
-(void)sendSMSForIncomingVOIPCallMode
{
    NSLog(@"ContactsData::sendSMSForIncomingVOIPCallMode -- ");
    NSString *messageBodyContentString;
    
    
    NSString *twilioNumber = serverResponseObject.twilioPhoneNumber;
    NSString *terminatingCharacter = serverResponseObject.terminatingCharacter;
    NSString *pauseCharacter = @",";
    NSString *userPhoneNumber = [DEFAULTS objectForKey:@"phonenumber"];
    
    NSString *finalNumberToDial = twilioNumber;
    
    int numberOfPauses = [serverResponseObject.numberOfPauseCharacters intValue];
    
    for(int i=0; i<numberOfPauses; i++)
    {
        finalNumberToDial = [finalNumberToDial stringByAppendingString:pauseCharacter];
    }
    
    finalNumberToDial = [finalNumberToDial stringByAppendingString:userPhoneNumber];
    finalNumberToDial = [finalNumberToDial stringByAppendingString:terminatingCharacter];
    messageBodyContentString = [NSString stringWithFormat:@"V.ALRT: %@ %@  %@",
                                NSLocalizedString(@"Please call", nil),[DEFAULTS objectForKey:@"userName"],
                                finalNumberToDial];
    
    //seperate the message by comma
    NSString *numbersToSendSMSToString = [arrSendTextMessage componentsJoinedByString:@","];
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    dispatch_async(queue, ^{
        
        NSString *urlString =  [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/message",VOIP_SMS_CALL_URL];
        NSURL *url = [NSURL URLWithString:urlString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        // Set up the body
        NSString *bodyString = [NSString stringWithFormat:@"serial_no=%@&numberOfSmsReceverOrEmergencyNumberList=%@&messageBodyContent=%@ %@ %@&macId=%@",
                                [SharedData sharedConstants].activeSerialno,
                                [numbersToSendSMSToString urlEncodeUsingEncoding:NSUTF8StringEncoding],
                                messageBodyContentString,
                                @"",
                                @"",
                                [SharedData sharedConstants].activeIdentifier];
        
        //Log the request url and parameter
        NSString*reqStr =[NSString  stringWithFormat:@"\n My 3rd Sms request:%@",urlString];
        NSString*bodyStr =[NSString  stringWithFormat:@"\n My 3rd Sms parameters:%@",bodyString];
        [[logfile logfileObj]  writeLog:reqStr];
        [[logfile logfileObj]  writeLog:bodyStr];
        
        
        NSLog(@"3rd SMS messages string: %@", bodyString);
        NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
        [NSURLConnection sendAsynchronousRequest:request queue: [NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if (!error)
            {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                int code = (int)[httpResponse statusCode];
                if(code !=200)
                {
                    
                    [self sendSMSForIncomingVOIPCallMode];
                }
                
                NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"incoming voip:%@", newStr);
                NSString*respStr = [NSString stringWithFormat:@"\n My 3rd Sms response:%@",newStr];
                [[logfile logfileObj]  writeLog:respStr];
                
            }
            else
            {
                NSLog(@"Error sending 3rd SMS: %@",[error localizedDescription]);
                NSString*respStr = [NSString stringWithFormat:@"\n My 3rd Sms response:%@",[error localizedDescription]];
                [[logfile logfileObj]  writeLog:respStr];
            }
        }];
        
    });
    
    shouldSendThirdSMS = NO;
    
}

///Intiate the call
-(void)initiateCall
{
    NSLog(@"ContactsData::initiateCall -- ");
    //Check cancelprocessclicked
    if(disConnectCall != 1)
    {
        disConnectCall = 0;
        if (arrCallNumbers.count >0)
        {
            [self callTwilioWithNumber:arrCallNumbers[0]];
        }
        else
        {
            //If we don't have any outgoing calls to make
            //then we want to initialize ourselves for incoming calls
            //right away.
            [self verifyAndInitTwilioIncomingCall];
            
            //reset our call index
            _currentCallIndex = 4;
            //We also need to post an event so that Alert In Progress Screen
            //knows to update the table view to show that we are doing
            //incoming calls
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentCallIndex], @"userinfo",
                                  [NSNumber numberWithBool:isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",
                                  nil];
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidDisconnect
                                                                object:self
                                                              userInfo:dict];
        }
        
    }
    
    
}

-(void)callnumbers
{
    
    NSLog(@"ContactsData::callnumbers -- ");
    //turn on the speakerphone
    [self setSpeakerEnabled:YES];
    
    [self performSelectorOnMainThread:@selector(callNumbersonmainthread) withObject:nil waitUntilDone:YES];
    
}

-(void)callNumbersonmainthread
{
    
    NSLog(@"ContactsData::callNumbersonmainThread -- ");
    
    // @elg - Added the VOIP way of calling, removed the native dialer
    //route the audio to the speaker
    [self setSpeakerEnabled:YES];
    
    //initialize our Twilio Call params
    [self initTwilioCall];
    
    for (int call =0; call< arrCallNumbers.count; call++)
    {
        NSString *phoneNumber = [arrCallNumbers objectAtIndex:call];
        [self connect:phoneNumber];
    }
}

-(void)manageTextsandCalls
{
    NSLog(@"ContactsData::ManageTextsAndCalls called");
    NSData *dataRepresentingSavedNumberArray = [DEFAULTS objectForKey:CONTACT_NUMBERS];
    NSArray *defaultContacts = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedNumberArray];
    
    
    NSData *dataRepresentingSavedEnabledNumberArray = [DEFAULTS objectForKey:ENABLED_CALLS];
    NSArray *arrCallEnabledIndices = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedEnabledNumberArray];
    
    NSData *dataRepresentingSavedEnabledTextArray = [DEFAULTS objectForKey:ENABLED_TEXTS];
    NSArray *arrTextEnabledIndices = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedEnabledTextArray];
    
    
    //Reset you voip call
    _currentCallIndex =0;
    
    //This BOOL value tells us whether we should send the third SMS or not
    //This is to fix the problem of sending multiple 3rd SMS's
    shouldSendThirdSMS = YES;
    
    //Text
    arrTextIndices = [NSMutableArray array];
    for (int i =0; i<3; i++)
    {
        if ([[arrTextEnabledIndices objectAtIndex:i] isEqualToString:@"1"])
        {
            NSString *strin =[NSString stringWithFormat:@"%d",i];
            [arrTextIndices addObject:strin];
        }
    }

    NSLog(@"ContactsData::manageTextsandCalls -- Text Enabled :%@",arrTextIndices);
    [arrSendTextMessage removeAllObjects];
    
    for (int i=0; i<[arrTextIndices count];++i )
    {
        NSUInteger indexValue = [[arrTextIndices objectAtIndex:i]integerValue];
        [arrSendTextMessage addObject:[defaultContacts objectAtIndex:indexValue]];
    }
    NSLog(@"ContactsData::manageTextsandCalls -- Numbers to Text:%@",arrSendTextMessage);
    //Call
    arrNumberindices =[NSMutableArray array];
    
    for (int i=0; i<3; ++i)
    {
        if ([[arrCallEnabledIndices objectAtIndex:i]isEqualToString:@"1"])
        {
            NSString *strCall=[NSString stringWithFormat:@"%d",i];
            [arrNumberindices addObject:strCall];
        }
    }
    
    NSLog(@"ContactsData::manageTextsandCalls -- Index of Contacts to Call :%@",arrNumberindices);
    [arrCallNumbers removeAllObjects];
    
    for (int i=0; i<[arrNumberindices count]; ++i)
    {
        NSUInteger indexvalues=[[arrNumberindices objectAtIndex:i]integerValue];
        [arrCallNumbers addObject:[defaultContacts objectAtIndex:indexvalues]];
        
    }
    NSLog(@"ContactsData::manageTextsandCalls -- Numbers to Text:%@",arrCallNumbers);
    if([arrSendTextMessage count] >0)
    {
        if ([SharedData sharedConstants].isReachable)
        {
            self.backgroundTask = UIBackgroundTaskInvalid;
            self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"ContactsData::manageTextsandCalls -- Background handler called. Not running background tasks anymore.");
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
            }];
            [self sendcelltoweSms];
            
            //@TODO - change this back to 30 seconds.
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               if ([SharedData sharedConstants].isReachable)
                               {
                                   if(![CLLocationManager locationServicesEnabled]
                                      || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
                                   {
                                       self->latitude =0;
                                       self->longitude = 0;
                                       
                                   }
                                   self->failedSecondSmsRetryCount =0;
                                   [self sendSMS];
                               }
                               else
                               {
                                   [self noInternet];
                                   //Stop updading location
                                   [self.locationManager stopUpdatingLocation];
                               }
                               
                           });
        }
        else
        {
            [self noInternet];
        }
    }
    else if([arrCallNumbers count] >0)
    {
        if ([SharedData sharedConstants].isReachable)
        {
            _smsSentFlag =1;
            disConnectCall =0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSTimer scheduledTimerWithTimeInterval:2.0
                                                 target:self selector:@selector(initiateCall)
                                                userInfo:nil
                                                repeats:NO];
            });
        }
        else
        {
            [self noInternet];
        }
    }
}


//Low Accuracy level
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations

{
    
    CLLocation *currentLocation = [locations lastObject];
    NSTimeInterval age = [currentLocation.timestamp timeIntervalSinceNow];
    if(age < 5.0)
        
    {
        latitude = currentLocation.coordinate.latitude;
        longitude = currentLocation.coordinate.longitude;
    }
    
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // ...
}

-(void) noInternet
{
    
    NSLog(@"ContactsData::noInternet -- ");
    
    if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
    {
        [self localnotify:NSLocalizedString(@"No Internet Connection", nil) deviceStatus:NSLocalizedString(@"Avialable", nil)];
    }
    if([arrCallNumbers count] >0)
    {
        //Add status to the database to tell call failure due to no internet
        NSString *status = [NSString stringWithFormat:@"%@",@"No internet connection"];
        dConnect = [[dbConnect alloc]init];
        [dConnect addStatus:@"V.ALRT" bleName:[[SharedData sharedConstants] currentDate] bleAddress:@"Call Failed" bleStatus:status];
    }
}

//Send local notification when the device is disconnected/conneted/otherstatus
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus
{
    
    NSLog(@"ContactsData::localnotify -- ");
    
    if(![DEFAULTS boolForKey:VALRT_DEVICE_OFF])
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        
        localNotification.alertBody = [NSString stringWithFormat:@"%@ %@ %@",deviceName,NSLocalizedString(@"is", nil),deviceStatus];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
        {
            
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

-(void)setNumbers:(NSMutableArray *)phoneNumbers
{
//    NSLog(@" phoneNumbers %@",phoneNumbers);
}

-(void)setEmails:(NSMutableArray *)emailIDs
{
//    NSLog(@" emailIDs %@",emailIDs);
}

#pragma mark -
#pragma mark Audio Functions


-(void)setSpeakerEnabled:(BOOL)enabled
{
    _speakerEnabled = enabled;

    [self updateAudioRoute];
}
//
// To enable the speaker
//
-(void)updateAudioRoute
{
    
    //NSLog(@"ContactsData:: updating audio route: %@", _speakerEnabled);
    
    if(_speakerEnabled == YES)
    {
        NSLog(@"ContactsData::updateAudioRoute -- _speakerEnabled is YES!");
    }
    else
    {
        NSLog(@"ContactsData::updateAudioRoute -- _speakerEnabled is No!");
    }
    if (_speakerEnabled)
    {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride
                                 );
    }
    else
    {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),
                                 &audioRouteOverride
                                 );
    }
}

- (void) configureAVAudioSession
{
    NSLog(@"ContactsData::configureAVAudioSession --");
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:AVAudioSessionCategoryPlayAndRecord
                             error:&error];
    
    if (!success)  NSLog(@"ContactsData::configureAVAudioSession --AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  NSLog(@"ContactsData::configureAVAudioSession --AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"ContactsData::configureAVAudioSession --AVAudioSession error activating: %@",error);
    else NSLog(@"ContactsData::configureAVAudioSession --audioSession active");
}


#pragma mark -
#pragma mark Twilio VOIP Functions
//
// @elg - New phone call function
//
-(void)callTwilioWithNumber:(NSString *)phoneNumber
{
    NSLog(@"ContactsData::callTwilioWithNumber --");
    //route the audio to the speaker
    [self setSpeakerEnabled:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    //initialize our Twilio Call params
    [self initTwilioCall];
    
    //make the Twilio connection
    didReceiveConnectCallback = NO;
    didReceiveStartConnectingCallback = NO;
    twilioStartConnectingCallbackTimer = [NSTimer scheduledTimerWithTimeInterval: 9.9
                                                                          target: self
                                                                        selector:@selector(didReceiveStartConnectingCallbackTimerExpired:)
                                                                        userInfo: nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:twilioStartConnectingCallbackTimer forMode: NSDefaultRunLoopMode];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //make the Twilio connection
        [self connect:phoneNumber];
    });
    
}


#pragma mark-Time Function for callback Expired
-(void)didReceiveStartConnectingCallbackTimerExpired:(NSTimer *)timer
{
    NSLog(@"ContactsData::didReceiveStartConnectingCallbackTimerExpired - Is a StartConnectingCallback %d",didReceiveStartConnectingCallback);
    //handle the timer
    if(didReceiveStartConnectingCallback == NO)
    {
        if(_currentCallIndex < 4)  //check if we are less then max calls
        {
            [_device disconnectAll];
            
            //For testing
            // dConnect = [[dbConnect alloc]init];
            // [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"didReceiveStartConnectingCallbackTimerExpired:TIMER EXPIRED BEFORE CALLBACK" bleStatus:arrCallNumbers[_currentCallIndex]];
            [self initiateCall];
        }
    }
    else
    {
        if(_currentCallIndex < 4)  //check if we are less then max calls
        {
            //For testing
            //dConnect = [[dbConnect alloc]init];
            //[dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"didReceiveStartConnectingCallbackTimerExpired:RECEIVED CALLBACK" bleStatus:arrCallNumbers[_currentCallIndex]];
        }
        
    }
    
    
}

-(void)didReceiveConnectedCallbackTimerExpired:(NSTimer *)timer
{
    NSLog(@"ContactsData::didReceiveConnectedCallbackTimerExpired --");
    //handle the timer
    
    if(didReceiveConnectCallback == NO)
    {
        if(_currentCallIndex < 4)  //check if we are less then max calls
        {
            [_device disconnectAll];
            
            //For testing
            //dConnect = [[dbConnect alloc]init];
            // [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"didReceiveConnectedCallbackTimerExpired:TIMER EXPIRED BEFORE CALLBACK" bleStatus:arrCallNumbers[_currentCallIndex]];
            
            [self initiateCall];
        }
    }
    else{
        NSLog(@"------ did receive didReceiveConnectedCallbackTimerExpired ---------");
        if(_currentCallIndex < 4)  //check if we are less then max calls
        {
            //For testing
            //  dConnect = [[dbConnect alloc]init];
            // [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"didReceiveConnectedCallbackTimerExpired:RECEIVED CALLBACK" bleStatus:arrCallNumbers[_currentCallIndex]];
            
        }
    }
    
    
}
///
- (id)initTwilioCall
{
    NSLog(@"ContactsData::initTwilioCall");
    if (self = [super init])
    {
        if (![self capabilityTokenValid])
        {
            [self getCapabilityToken:^(NSString *token) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if(self->_device ==nil)
                    {
                        NSLog(@"ContactsData::initTwilioCall -- _device ==nil create new device and assign capability token");
                        self->_device = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
                    } else
                    {
                        NSLog(@"ContactsData::initTwilioCall -- _device valid just pass updated token");
                        [self->_device updateCapabilityToken:token];
                    }
                }];
            }];
        } else
        {
            NSLog(@"ContactsData::initTwilioCall -- ALREADY HAVE TOKEN");
        }
    }
    
    // Check the capabilities and warn if features aren't available.
    // You might handle this in other ways such as disabling buttons, or having
    // LED-style images in a red or green state.
    NSNumber* hasOutgoing = [_device.capabilities objectForKey:TCDeviceCapabilityOutgoingKey];
    NSNumber* hasIncoming = [_device.capabilities objectForKey:TCDeviceCapabilityIncomingKey];
    
    
    if ( [hasOutgoing boolValue] == NO )
    {
        NSLog(@"ContactsData::initTwilioCall -- Unable to make outgoing calls with current capability token");
    }
    if ( [hasIncoming boolValue] == NO )
    {
        NSLog(@"ContactsData::initTwilioCall -- Unable to receive incoming calls with current capability token");
    }
    
    return self;
}

- (id)initTwilioIncomingCall
{
    NSLog(@"ContactsData:: initTwilioIncomingCall");
    
    if (self = [super init])
    {
        //Initalize the TCDevice
        NSString*incomincallCapabilityTokenStr = [self getIncomingCapabilityToken];
        NSLog(@"ContactsData:: initTwilioIncomingCall --incomincallCapabilityTokenStr-%@",incomincallCapabilityTokenStr);
        if(incomincallCapabilityTokenStr !=nil)
        {
            @try {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if(self->_device==nil)
                    {
                        self->_device = [[TCDevice alloc] initWithCapabilityToken:incomincallCapabilityTokenStr delegate:self];
                    }
                    else
                    {
                        [self->_device updateCapabilityToken:incomincallCapabilityTokenStr];
                    }
                }];
            }
            @catch (NSException * e) {
                NSLog(@"ContactsData:: initTwilioIncomingCall -- Exception: %@", e);
            }
        }
        else
        {
            shouldSendThirdSMS = NO;
        }
    }
    //@todo remove the code
    // Check the capabilities and warn if features aren't available.
    // You might handle this in other ways such as disabling buttons, or having
    // LED-style images in a red or green state.
    @try
    {
        NSNumber* hasIncoming = [_device.capabilities objectForKey:TCDeviceCapabilityIncomingKey];
        if(hasIncoming == 0)
        {
            NSLog(@"ContactsData::initTwilioIncomingCall -- incomingcapabilitytoken: %ld", (long) hasIncoming);
        }
    }
    @catch (NSException * e)
    {
        NSLog(@"ContactsData::initTwilioIncomingCall -- Reading Twilio token capabilities incoming Exception: %@", e);
    }
    
    return self;
}


-(NSString*)getIncomingCapabilityToken
{
    NSLog(@"ContactsData:: getIncomingCapabilityToken");
    NSString *capabilityToken = nil;
    NSString *jsonResponseString = nil;
    NSString *urlString;
    urlString = [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/gettokenincommingcall",VOIP_SMS_CALL_URL];
    serverResponseObject = [[ServerResponseObject alloc] init];
    
    //formulate the json
    NSString * emergencyNumbers = @"8022221111";
    NSString * tokenDuration = @"480";
    NSString * serialNumber = [SharedData sharedConstants].activeSerialno;
    NSString * macID = [SharedData sharedConstants].activeIdentifier;
    NSString * username = [DEFAULTS objectForKey:@"userName"];
    NSString * countryCode = [DEFAULTS objectForKey:@"countrycode"];
    NSString * phoneNumber = [DEFAULTS objectForKey:@"phonenumber"];
    
    
    if(serialNumber == nil)
    {
        serialNumber = @"FFFFFFFF";
    }
    if(macID == nil)
    {
        macID = @"12345";
    }
    if(username == nil)
    {
        username = @"default user";
    }
    if(phoneNumber == nil)
    {
        phoneNumber = @"9545551212";
    }
    
    NSArray *objects = [NSArray arrayWithObjects:
                        emergencyNumbers,
                        tokenDuration,
                        serialNumber,
                        macID,
                        username,
                        countryCode,
                        phoneNumber,
                        nil];
    
    NSArray *keys = [NSArray arrayWithObjects:
                     @"emergencyNumbers",
                     @"tokenDuration",
                     @"serialNumber",
                     @"macID",
                     @"username",
                     @"countryCode",
                     @"phoneNumber",
                     nil];
    
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
   // NSLog(@"ContactsData::getIncomingCapabilityToken --  jsonArgumentsDict: %@",jsonDict);

    // create a JSON string from your NSDictionary
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&jsonError];
    
    NSString *jsonString = [[NSString alloc] init];
    if (!jsonData)
    {
        NSLog(@"ContactsData::getIncomingCapabilityToken --  Got an error building json: %@", jsonError);
    }
    else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    

    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];

    NSLog(@"ContactsData::getIncomingCapabilityToken -- jsonString: %@", jsonString);
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:&error];
    
    
    if (data)
    {
        NSHTTPURLResponse*  httpResponse = (NSHTTPURLResponse*)response;
        
        if (httpResponse.statusCode == 200)
        {
            jsonResponseString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
            
        }
        else
        {
            jsonResponseString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
            NSLog(@"ContactsData::getIncomingCapabilityToken -- http status code: %d",  (int)httpResponse.statusCode);
            NSLog(@"ContactsData::getIncomingCapabilityToken -- http response-%@",httpResponse);

            return nil;
        }
    }
    else
    {
        isIncomingVOIPEnabled = NO;
        NSLog(@"ContactsData::getIncomingCapabilityToken -- error response: %@", [error localizedDescription]);
        //@disussion -If data is nil then return nil
        return nil;
    }
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil)
    {
        //*error = localError;
        NSLog(@"ContactsData::getIncomingCapabilityToken -- error serializing response: %@", localError);
        return nil;
    }
    
    NSLog(@"ContactsData::getIncomingCapabilityToken --  Response is: %@", [parsedObject description]);
    
    serverResponseObject.isIncomingEnabled = [parsedObject objectForKey:@"isIncomingEnabled"];
    
    if([serverResponseObject.isIncomingEnabled isEqualToString:@"enable"])
    {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        serverResponseObject.numberOfPauseCharacters = [f numberFromString:[parsedObject objectForKey:@"numberOfPauseCharacters"]];
        serverResponseObject.terminatingCharacter = [parsedObject objectForKey:@"terminatingCharacter"];
        serverResponseObject.capabilityToken = [parsedObject objectForKey:@"token"];
        serverResponseObject.tokenDuration = [parsedObject objectForKey:@"tokenDuration"];
        serverResponseObject.twilioPhoneNumber = [parsedObject objectForKey:@"twilioPhoneNumber"];
        
        capabilityToken = serverResponseObject.capabilityToken;
        isIncomingVOIPEnabled = YES;
        
        //If incoming capability token is enabled then send sms
        //let's send out the third SMS
        if([arrSendTextMessage count]>0)
        {
            [self sendSMSForIncomingVOIPCallMode];
        }
        
    }
    
    else
    {
        isIncomingVOIPEnabled = NO;
        capabilityToken = nil;
    }
    
    
    return capabilityToken;
    
}

-(void)getCapabilityToken:(responseBlock) completionBlock;
{
    NSLog(@"ContactsData::getCapabilityToken --");
    __block NSString* capabilityToken = nil;
    NSString *urlString = [NSString stringWithFormat:@"%@VSNCloudApp/rest/vsn/notification/token?tokenDuration=480",VOIP_SMS_CALL_URL];
    NSURL* url = [NSURL URLWithString:urlString];
    
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:url] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (!error)
         {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             
             if (httpResponse.statusCode == 200)
             {
                 capabilityToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                 NSLog(@"ContactsData::getCapabilityToken -- CapabilityToken:%@",capabilityToken);
                 completionBlock(capabilityToken);
                 
             }
             else
             {
                 NSLog(@"ContactsData::getCapabilityToken -- http status code: %d", (int)httpResponse.statusCode);
                 NSLog(@"ContactsData::getCapabilityToken -- http resp: %@", httpResponse);

                 [self verifyAndInitTwilioIncomingCall];
             }
         }
         else
         {
             NSLog(@"ContactsData::getCapabilityToken -- request Error: %@", [error localizedDescription]);
              //Since there was an error, listen for incoming calls
             //Anner: Kinda dumb to prepare for incoming calls on a error since we weren't able to get the capability token to receive calls??
             [self verifyAndInitTwilioIncomingCall];
         }
     }];
    
    /*	NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url]
     returningResponse:&response error:&error];
     if (data)
     {
     NSHTTPURLResponse*  httpResponse = (NSHTTPURLResponse*)response;
     
     if (httpResponse.statusCode == 200)
     {
     capabilityToken = [[NSString alloc] initWithData:data
     encoding:NSUTF8StringEncoding];
     
     //_device = [[TCDevice alloc] initWithCapabilityToken:capabilityToken delegate:nil];
     }
     else
     {
     NSString*errorString = [NSString stringWithFormat:
     @"HTTP status code %d",
     httpResponse.statusCode];
     NSLog(@"Error logging in: %@", errorString);
     
     //Changes by ashok
     //@discussion-If call and sms has sent then intiate the incoming call
     if(_smsSentFlag ==1 && [[DEFAULTS valueForKey:@"KeyPressed"] isEqualToString:@"1"])
     {
     //Since there was an error, listen for incoming calls
     [self initTwilioIncomingCall];
     }
     }
     }
     else
     {
     NSLog(@"Error logging in: %@", [error localizedDescription]);
     
     [self verifyAndInitTwilioIncomingCall];
     
     }
     */
    //return capabilityToken;
}
///
-(BOOL)capabilityTokenValid
{
    NSLog(@"ContactsData::capabilityTokenValid --");
    //Check TCDevice's capability token to see if it is still valid
    BOOL isValid = NO;
    NSNumber *expirationTimeObject = [_device.capabilities objectForKey:@"expiration"];
    long long expirationTimeValue = [expirationTimeObject longLongValue];
    long long currentTimeValue = (long long)[[NSDate date] timeIntervalSince1970];
    
    NSLog(@"ContactsData::capabilityTokenValid -- Token expiration time is %d", [expirationTimeObject intValue]);
    
    if ((expirationTimeValue-currentTimeValue)>0)
        isValid = YES;
    
    return isValid;
}



-(void)connect:(NSString*)phoneNumber
{
    
    NSLog(@"ContactsData::connect --Trying to connect to:%@",phoneNumber);
    //For testing
    //dConnect = [[dbConnect alloc]init];
    //[dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"connect-method" bleStatus:phoneNumber];
    
    // first check to see if the token we have is valid, and if not, refresh it.
    // Your own client may ask the user to re-authenticate to obtain a new token depending on
    // your security requirements.
    if (![self capabilityTokenValid])
    {
        //Capability token is not valid, so create a new one and update device
        NSLog(@"ContactsData::connect -- invalid capability token");
        //Set the capability token of the device to be the newly created capability token
        [self getCapabilityToken:^(NSString *token) {
            if(self->_device ==nil)
            {

                NSLog(@"ContactsData::connect -- device null call initiwthcapabilitytoken");
                self->_device = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
            } else {
                NSLog(@"ContactsData::connect -- non nil _device DO NOT update token");
                //[_device updateCapabilityToken:token];
            }
        }];
        
    }
    
    NSDictionary* parameters = nil;
    if ( [phoneNumber length] > 0 )
    {
        //parameters = [NSDictionary dictionaryWithObject:phoneNumber forKey:@"PhoneNumber"];
        parameters = [[NSDictionary alloc] initWithObjectsAndKeys:phoneNumber, @"emergencyNo", @"10", @"expiration", nil];
    }
    //Write value to the database
    if(_currentCallIndex<3)
    {
        //For testing
        //dConnect = [[dbConnect alloc]init];
        // [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"_device connect:" bleStatus:arrCallNumbers[_currentCallIndex]];
    }
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if(self->_connection==nil)
        {
            NSLog(@"ContactsData::connect -- CONNECTION->nil");
            self->_connection = [[TCConnection alloc] init];
        }
        
        // If there's device with valid token & connection is disconnected then start connection
        if (self->_device)
        {
            if (self->_connection.state == TCConnectionStateDisconnected)
            {
                self->_connection = [self->_device connect:parameters delegate:self];
                self->_connection.delegate = self;
                NSLog(@"ContactsData::connect -- CONNECTION STATE: %ld", (long)self->_connection.state);
                
            // if connection is already pending, starting or connected then it must be old so try to disconnect it
            } else {
                NSLog(@"ContactsData::connect -- Connection State: %ld try to disconnect",(long) self->_connection.state);
                [self->_connection disconnect];
                [self._device unlisten];
                [self->_device disconnectAll];
            }
        }
    });

}

#pragma mark-TCconnection Delegates

- (void)connectionDidStartConnecting:(TCConnection *)connection
{
    NSLog(@"ContactsData::connectionDidStartConnecting --");
    [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionIsConnecting object:nil];
    
    
    //@Code by Ed
    didReceiveStartConnectingCallback = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->twilioConnectCallbackTimer = [NSTimer scheduledTimerWithTimeInterval: 9.9
                                                                      target: self
                                                                    selector:@selector(didReceiveConnectedCallbackTimerExpired:)
                                                                    userInfo: nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self->twilioConnectCallbackTimer forMode: NSDefaultRunLoopMode];
    });
    
    
    //Write value to the database
    if(_currentCallIndex<3)
    {
        //For testing
        //dConnect = [[dbConnect alloc]init];
        // [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"connectionDidStartConnecting" bleStatus:arrCallNumbers[_currentCallIndex]];
    }
}

-(void)connectionDidConnect:(TCConnection*)connection
{
    failedCallRetryCount = 0;
    // Enable the proximity sensor to make sure the call doesn't errantly get hung up.
    UIDevice* device = [UIDevice currentDevice];
    
    device.proximityMonitoringEnabled = YES;
    didReceiveConnectCallback = YES;
    
    //call method to stop notifications and stop sound
    [[commonnotifyalert alertConstant] stopNotify];
    AppDelegate*appDelegatObj =   APP_DELEGATE;
    appDelegatObj.repeatToneFlag =1;
    
    NSLog(@"ContactsData::connectionDidConnect --");
    
    // set up the route audio through the speaker, if enabled
    [self updateAudioRoute];
    
    //Write value to the database
    if(_currentCallIndex<3)
    {
        //For testing
        //  dConnect = [[dbConnect alloc]init];
        //   [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"connectionDidConnect" bleStatus:arrCallNumbers[_currentCallIndex]];
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_currentCallIndex]
                                                     forKey:@"userinfo"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidConnect
                                                        object:self
                                                      userInfo:dict];
    
    
    
    
}

- (void)connectionDidDisconnect:(TCConnection *)connection
{
    //connection.state == TCConnectionStateDisconnected;

    NSLog(@"ContactsData::connectionDidDisconnect -- on phone number: %@",arrCallNumbers[_currentCallIndex]);
    //Write value to the database to know call is disconnected
    //insert the device connection status
    //intialize the dbconnect
    if(_currentCallIndex<3)
    {
        //For testing
        //  dConnect = [[dbConnect alloc]init];
        //  [dConnect addStatus:@"V.ALRT" bleName:@"VOIP-CHECK" bleAddress:@"connectionDidDisconnect" bleStatus:arrCallNumbers[_currentCallIndex]];
    }
    //increment our call index, since we just completed a call
    ++_currentCallIndex;
    
    if ( connection == _connection )
    {
        UIDevice* device = [UIDevice currentDevice];
        device.proximityMonitoringEnabled = NO;
        
        if(_currentCallIndex < arrCallNumbers.count)
        {
            // Set timeout
            didReceiveConnectCallback = NO;
            didReceiveStartConnectingCallback = NO;
            twilioStartConnectingCallbackTimer = [NSTimer scheduledTimerWithTimeInterval: 9.9
                                                                                  target: self
                                                                                selector:@selector(didReceiveStartConnectingCallbackTimerExpired:)
                                                                                userInfo: nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:twilioStartConnectingCallbackTimer forMode: NSDefaultRunLoopMode];
            
            //make the Twilio connection
            [self connect:arrCallNumbers[_currentCallIndex]];
        }
        else
        {
            _connection = nil;
            //reset our call index
            _currentCallIndex = 4;
            [self verifyAndInitTwilioIncomingCall];
          
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentCallIndex], @"userinfo",
                                                                            [NSNumber numberWithBool:isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",
                                  nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidDisconnect
                                                                object:self
                                                              userInfo:dict];
        }
    }
    else
    {
        NSLog(@"ContactsData::connectionDidDisconnect -- diff or null connection, received TCConnectionShouldDisconnect: %d",disConnectCall);
        //TODO: should we tell the user?
        _connection = nil;
        
        //reset our call index
        _currentCallIndex = 4;
        
        //Invalidate the timer
        [twilioConnectCallbackTimer invalidate];
        [twilioStartConnectingCallbackTimer invalidate];

        [self verifyAndInitTwilioIncomingCall];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentCallIndex], @"userinfo",
                                                                      [NSNumber numberWithBool:isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",
                                                                      nil];
        
        
        //Tell the UI to dismiss our modal Alert View
        [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidDisconnect
                                                            object:self
                                                          userInfo:dict];
    }
    
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"ContactsData::didFailWithErrors: %@",error);
    
    didReceiveConnectCallback = YES;
    didReceiveStartConnectingCallback = YES;
    
    if(_currentCallIndex<3)
    {
        //For testing
        NSString *status = [NSString stringWithFormat:@"connectiondidFailWithError-%@",error.localizedDescription];
        dConnect = [[dbConnect alloc]init];
        
        NSString *_date=[[SharedData sharedConstants] currentDate];
        
/*        [dConnect addStatus:
                    bleName:@"V.ALRT"
                    bleAddress:@"Address"
                    bleStatus:NSLocalizedString(@"Application silent mode off", nil)];
  */
        [dConnect addStatus:[NSString stringWithFormat:@"%@",_date]
                    bleName:@"V.ALRT"
                    bleAddress:@"ContactsData"
                    bleStatus:status];
         
    }
    //disable the proximity sensor
    UIDevice* device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    failedCallRetryCount++;
    
    //reset our variables
    _connection = nil;
    
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = [NSString stringWithFormat:@"Call attempt failed! Retry #%d...", failedCallRetryCount];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    if (![DEFAULTS boolForKey:DISABLE_PHONEAPPLICATION_SILENT])
    {
        localNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
    //retry the voip call
    if(_currentCallIndex < arrCallNumbers.count && failedCallRetryCount<3)
    {
        [self callTwilioWithNumber:arrCallNumbers[_currentCallIndex]];
    }
    else
    {
        if(_currentCallIndex <3)
        {
            //Add called failed status to the history log.
            NSString *status = [NSString stringWithFormat:@"%@",error.localizedDescription];
            dConnect = [[dbConnect alloc]init];
            [dConnect addStatus:@"V.ALRT" bleName:@"Call failed" bleAddress:status bleStatus:arrCallNumbers[_currentCallIndex]];
        }
    }
    
    
}

//THIS function is called by a event selector for TCConnectionShouldDisconnect
//this is called from alert inprogress when the end call button is pressed.
//This will call disconnect on our call/connection
-(void)disconnect
{
    NSLog(@"ContactsData::disconnect -- called by TCConnectionShouldDisconnect event");
    
    //disable the proximity sensor
    UIDevice* device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;
    
    [_connection disconnect];
    [_device unlisten]; //stop listening for incoming calls
    
    _connection = nil;
    _device = nil;
    disConnectCall =1;
}


#pragma mark- TCDeviceDelegate Methods

-(void)deviceDidStartListeningForIncomingConnections:(TCDevice*)device
{
    NSLog(@"ContactsData::deviceDidStartListeningForIncomingConnections");
    
    
}

-(void)device:(TCDevice*)device didStopListeningForIncomingConnections:(NSError*)error
{
    NSLog(@"ContactsData::didStopListeningForIncomingConnections");
    // The TCDevice is no longer listening for incoming connections, possibly due to an error.
//    if(![_connection isIncoming]){
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentCallIndex], @"userinfo",
//                              [NSNumber numberWithBool:isIncomingVOIPEnabled], @"isIncomingVOIPEnabled",
//                              nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidDisconnect
//                                                            object:self
//                                                          userInfo:dict];
//    }
    if( [[DEFAULTS objectForKey:@"KeyPressed"] integerValue]  ==1)
    {
        if([[UIApplication sharedApplication] applicationState] ==UIApplicationStateBackground)
        {
            [[commonnotifyalert alertConstant] repeatLocalNotify];
            AppDelegate*appDelegatObj =   APP_DELEGATE;
            appDelegatObj.repeatToneFlag =0;
        }
        else
        {
            [[commonnotifyalert alertConstant] repeatRingtone];
            AppDelegate*appDelegatObj =   APP_DELEGATE;
            appDelegatObj.repeatToneFlag =0;
        }
    }
        
    if ( error )
    {
        NSLog(@"ContactsData::didStopListeningForIncomingConnections");
    }
    
}

-(void)device:(TCDevice*)device didReceiveIncomingConnection:(TCConnection*)tcConnection
{
    NSLog(@"ContactsData::didReceiveIncomingConnection");
    
    //Stop notify the alert sound
    [[commonnotifyalert alertConstant]stopSound];
    AppDelegate*appDelegatObj =   APP_DELEGATE;
    appDelegatObj.repeatToneFlag =1;
    

    
    //Local notify for incoming call.
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = NSLocalizedString(@"Incoming Call", nil);
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];

    
    //Tell the UI to dismiss our modal Alert View
    [[NSNotificationCenter defaultCenter] postNotificationName:kTCConnectionDidReceiveIncomingConnection
                                                        object:self
                                                      userInfo:nil];
    
    
    if ( _connection )
    {
        [self disconnect];
    }
    
    _connection = [[TCConnection alloc] init];
    _connection = tcConnection;
    _connection.delegate = self;
    
    
    //route the audio to the speaker  @discussion ELG - May 13
    [self setSpeakerEnabled:YES];
    
    //Mix the audio
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    //play incoming ringtone using audioservice api.
    //ELG -
    NSString *ringtonePath = [[NSBundle mainBundle]
                              pathForResource:@"valert_incoming_call_ringring" ofType:@"caf"];
    NSURL *ringtoneURL = [NSURL fileURLWithPath:ringtonePath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)ringtoneURL, &ringtoneSound);
    AudioServicesAddSystemSoundCompletion(ringtoneSound, nil, nil, completionCallback, (__bridge void*) self);
    
    AudioServicesPlaySystemSound(ringtoneSound);
    
    
}

//Call back after the incoming sound completed.
-(void) playSoundFinished
{
    
    AudioServicesRemoveSystemSoundCompletion(ringtoneSound);
    [_connection accept];
    [_device unlisten]; //stop listening for incoming calls
}

static void completionCallback (SystemSoundID  mySSID, void *myself)
{
    NSLog(@"Audio callback");
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    AudioServicesDisposeSystemSoundID(mySSID);
    [(__bridge ContactsData*)myself playSoundFinished];
}

- (void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent
{
    if(presenceEvent.available == NO)
    {
        if([presenceEvent.name isEqualToString:[DEFAULTS objectForKey:@"phonenumber"]])
        {
            
        }
        NSLog(@"ContactsData::didReceivePresenceUpdate -- %@ device presence status is: NO", presenceEvent.name);
    }
    
}
@end
