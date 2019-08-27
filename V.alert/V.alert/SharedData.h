#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Reachability.h"
@interface SharedData : NSObject
{
    UIAlertView* alert;
}


+ (SharedData *) sharedConstants;
- (BOOL)isReachable;
-(void)localnotify:(NSString *)Status;
-(void)checkDisconnectdevice;
-(void)disconnectNotification:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
-(void) alertMessage:(NSString*)alertTitle msg:(NSString*)alertMsg;
-(NSString *)currentDate;
-(NSArray *)getEnabledcalls;
-(NSArray *)getEnabledtexts;
- (BOOL) numericText: (NSString *) numeric;
- (BOOL)ContainValue:(NSString *)substring;
-(void)dismissalert;

//Selected View Id
@property (assign, nonatomic) int selectedLang;
@property (assign, nonatomic) int normalMode;
@property (assign, nonatomic) int fallMode;
@property (assign, nonatomic) int adjustMode;
@property (assign, nonatomic) int fallDetection;

@property (nonatomic, strong) NSString *activeSerialno;
@property (nonatomic, strong) NSString *activeIdentifier;

@property(strong, nonatomic) NSMutableArray *arrPeriperhalNames;

@property(strong, nonatomic) NSMutableArray *arrActivePeripherals;

@property(strong, nonatomic) NSMutableArray *arrActiveIdentifiers;
@property(strong, nonatomic) NSMutableArray *arrAvailableIdentifiers;
@property(strong, nonatomic) NSMutableArray *fallenableIdentifiers;

@property(strong, nonatomic) NSMutableDictionary *laststateIdentifiers;

@property(strong, nonatomic) NSMutableArray *arrConnectedPeripherals;

@property(strong, nonatomic) NSMutableArray *arrDisconnectedIdentifers;

@property(strong, nonatomic) NSMutableArray *arrDiscovereUUIDs;


@property (strong, nonatomic) CBPeripheral *activePeripheral;

@property (nonatomic, strong) NSString *strCurrentPeriPheralName;

@property (nonatomic, strong) NSString *strserialNumber;

@property (nonatomic, strong) NSString *strSofwareVer;

@property (nonatomic, strong) NSString *strBatteryLevelStatus;

@property (nonatomic, strong) NSString *strSignalStregnthstatus;

@property (nonatomic, strong) NSString *strEnteredAlertMessage;

@property (nonatomic, strong) NSMutableArray *arrSelectMultipleContacts;

@property (nonatomic, strong) NSMutableString *strDidSelectContacts;


//Enabled and Disabled Calls and Texts

@property(strong, nonatomic) NSMutableArray *arrEnabledCalls;

@property(strong, nonatomic) NSMutableArray *arrEnabledTexts;

@property (nonatomic, strong) NSString *strChangName;

@property (assign, nonatomic) int verifyMode;
@property (assign, nonatomic) int readMac;
@property (assign, nonatomic) int notifyserialSoft;
@property (assign, nonatomic) int readBtry;
@property (assign, nonatomic) int readSoftver;


@property BOOL isAnswered;
//Reachability
@property (nonatomic,retain) Reachability *internetReachability;
@end
