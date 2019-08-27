#import <Foundation/Foundation.h>

//check and print nslog value only in debug mode

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif

#define SYSTEM_VERSION [[UIDevice currentDevice] systemVersion]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

//Language Check
#define VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]
#define LANGUAGE  [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0]

//StoryBoard
#define IPHONE_STORYBOARD [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];

//AppDelegate
#define APP_DELEGATE  (AppDelegate *)[[UIApplication sharedApplication] delegate];

//Objects
#define TEXT_COLOR	 [UIColor colorWithRed:80.0/255.0 green:74.0/255.0 blue:103.0/255.0 alpha:1.0]

#ifdef HNALERT
    #define BRANDING_COLOR	 [UIColor colorWithRed:235.0/255.0 green:28.0/255.0 blue:45.0/255.0 alpha:1.0]
#else
    #define BRANDING_COLOR	 [UIColor colorWithRed:220.0/255.0 green:170.0/255.0 blue:0.0/255.0 alpha:1.0]
#endif

#define TEXT_FONT_18	[UIFont fontWithName:@"HelveticaNeue" size:18.0]
#define TEXT_FONT_15	[UIFont fontWithName:@"HelveticaNeue" size:15.0]
#define TEXT_FONT_16	[UIFont fontWithName:@"HelveticaNeue" size:16.0]


//Alerts and Popups
#define LABEL_CUSTOMALERT_NOCONTACTS NSLocalizedString(@"There are no contact number available for selected contact", nil)

#define LABEL_CONFIRMATIONALERT_DELETE NSLocalizedString(@"Are you sure Do you want to remove the selected contact?", nil)
#define LABEL_CUSTOMALERT_PLEASE_SELECT_CONTACT NSLocalizedString(@"Add Contact to Enable Texts and Calls", nil)

// Tracker Constatnts
#define Valert_Immediate_Triggered @"Valert_Immediate_Triggered"
#define CURRENTPERIFERALID @"Current_periferal_id"
#define SHOWINGDISCONNECTEDDEVICEPOPUP @"SHOWINGDISCONNECTEDDEVICEPOPUP"
#define DEVICE_TRAKING_SOUND @"is_device_traking_sound_on"
#define DEVICE_TRAKING_VIBRATION @"is_device_traking_vibration_on"
#define DEVICE_TRAKING_LIGHT @"is_device_traking_light_on"
#define IS_DEVICE_TRAKING_FEATURE_ON @"IS_DEVICE_FEATURE_ON"
#define IS_DEVICE_REMOVED @"DeviceRemoved"
#define FLOW_STEP @"flow_step"
#define REMOVE_BACK @"remove_back"

//Defaults
#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define CONNECTED_PERIPERAL @"connected_periperal"
#define TEMPORARY_ALERT_MESSAGE  NSLocalizedString(@"Help, I need now" , nil)
#define TEMPORARY_RINGTONE_NAME NSLocalizedString(@"CalendarAlert (Default)", nil)
#define TEMPORARY_RINGTONE_ID NSLocalizedString(@"1005", nil)
#define TEMPORARY_SOUND_NAME @"alarm.caf"
#define ALERT_SOUND_NAME @"alert_sound_name"

//BOOL Values
#define DISABLE_SETTINGS NSLocalizedString(@"settings_disable", nil)
#define ENABLED_CALLS @"call_enable"
#define ENABLED_TEXTS @"text_enable"
#define INITIAL_SETUP @"initial_settings_setup"
#define DISABLE_VALERTDEVICE_SILENT @"valert_device_silentmode"
#define DISABLE_PHONEAPPLICATION_SILENT @"phone_application_silentmode"
#define IS_PANIC_SOUND_ENABLE @"is_panic_enable"


//Contacts
#define TEXT_ADD_CONTACT @"Add contact"
#define ALERT_MESSAGE    @"alert_message"
#define ALERT_RINGTONE_NAME NSLocalizedString(@"alert_ringtone_name", nil)
#define ALERT_RINGTONE_ID @"alert_ringtone_ID"
#define CONTACT_NUMBERS  NSLocalizedString(@"contacts_array", nil)
#define CONTACT_NAMES    NSLocalizedString(@"contacts_name", nil)

//BLE Connection
#define BLE_PERIPHERALS_FOUND  NSLocalizedString(@"found_peripherals", nil)
#define BLE_PERIPHERALS_PAIRED  NSLocalizedString(@"paired_peripherals", nil)
#define BLE_PERIPHERALS_ACTIVE  NSLocalizedString(@"active_peripheral", nil)
#define IS_CONNECTED  NSLocalizedString(@"is_connected", nil)

#define BLE_DISCOVERED_UUIDS  NSLocalizedString(@"discover_uuid", nil)

//Device Silent Mode

#define DEVICE_ON  NSLocalizedString(@"ON", nil)
#define DEVICE_OFF  NSLocalizedString(@"OFF", nil)
#define DEVICE_ENABLED  NSLocalizedString(@"Enabled", nil)
#define DEVICE_DISABLED  NSLocalizedString(@"Disabled", nil)

#define BTN_NEXT NSLocalizedString(@"next", nil);
#define BTN_BACK NSLocalizedString(@"back", nil);
#define BTN_CANCEL NSLocalizedString(@"cancel", nil);


//Twilio VOIP connection notifications
#define kTCConnectionIsConnecting @"TCConnectionIsConnecting"
#define kTCConnectionDidConnect @"TCConnectionDidConnect"
#define kTCConnectionDidDisconnect @"TCConnectionDidDisconnect"
#define kTCConnectionDidFailWithError @"TCConnectionDidFailWithError"
#define kTCConnectionDidReceiveIncomingConnection @"TCConnectionDidReceiveIncomingConnection"
#define kSmsSent @"smssent"

#define keyFallNotification @"keyfall"

#define kAlertViewInCallTag 100

#define VOIP_SMS_CALL_URL @"https://example.com/"

#define VSN_INSTRN_VIDEO_ENG_URL @"http://www.vsnmobil.com/valrt/box/insvideo/insvideo.mp4"

#define VSN_INSTRN_VIDEO_SPN_URL @"http://www.vsnmobil.com/valrt/box/insvideo/spanish/insvideospanish.mp4"

#define ENG_TERMS_URL @""


#define VSN_EMAIL_TC_ENG_URL @"http://www.vsnmobil.com/valrt/manuals/tandc/"
#define VSN_EMAIL_TC_SPN_URL @"http://www.vsnmobil.com/valrt/manuals/tandc/spanish/"

#ifdef HNALERT
    #define VSN_FAQ_SPN_URL @"http://www.vsnmobil.com/support/v-alrt/faq/span"
    #define VSN_FAQ_ENG_URL @"http://www.vsnmobil.com/support/v-alrt/faq/"
#else
    #define VSN_FAQ_SPN_URL @"http://www.vsnmobil.com/support/v-alrt/faq/span"
    #define VSN_FAQ_ENG_URL @"http://www.vsnmobil.com/support/v-alrt/faq/"
#endif

//Device Off Feature
#define VALRT_DEVICE_OFF @"device_off"

@interface Constants : NSObject

@end
