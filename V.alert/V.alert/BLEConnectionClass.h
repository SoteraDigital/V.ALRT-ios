#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "ConstantBLEkeys.h"
#import "dbConnect.h"

@protocol BLEConnectionDelegate
@optional
-(void) keyfobReady;
-(void)getCurrentBatteryStatus:(CBPeripheral *)peripheral ;
-(void) keyValuesUpdated:(CBPeripheral *)peripheral ;
-(void) fallDetected:(CBPeripheral *)peripheral;
-(void) deviceDisconnected; // Tracker: When Periferal Device get disconnected
-(void) deviceConnectedAgain; // Tracker : Periferal Device get Connected Again
@required
@end



@interface BLEConnectionClass : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    
    dbConnect *dConnect;
     BOOL isFullyConnected;
    NSDate*connectedEarlierTime;
    NSDate*disconnectedEarlierTime;
    NSTimer *disconnectedTimer;
    BOOL  isFullyDisconnected;
    NSString *peripheralID;
}

@property (nonatomic)   float batteryLevel;

@property (nonatomic)   BOOL key1;
@property (nonatomic)   BOOL key2;

@property (nonatomic)   char x;
@property (nonatomic)   char y;
@property (nonatomic)   char z;
@property (nonatomic)   char TXPwrLevel;

@property (assign)      BOOL isFullyConnected;
@property (assign)      BOOL isFullyDisconnected;
@property (nonatomic,assign) id <BLEConnectionDelegate> delegate;

@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *CM;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (strong, nonatomic) UIButton *BLEDeviceConnectbtn;

-(void) unsubscribeAllNotifications:(CBPeripheral *)p;
-(void) initConnectButtonPointer:(UIButton *)b;
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p;
-(void) readRssi:(CBPeripheral *)p;
-(void) readBattery:(CBPeripheral *)p;
-(void) readSerialNumber:(CBPeripheral *)p;
-(void) readSoftwareRev:(CBPeripheral *)p;
-(void) readMacAddress:(CBPeripheral *)p;
-(void) setFallDetection:(CBPeripheral *)p;
-(void) enableButtons:(CBPeripheral *)p;
-(void) disableAlert:(CBPeripheral *)p;
-(void) cancelMode:(CBPeripheral *)p;
-(void) verifyPairing:(CBPeripheral *)p;
//Fall Detection
-(void)localnotify:(NSString *)deviceName deviceStatus:(NSString *)deviceStatus;
-(void) silentNormalmode:(Byte)byteVal periperal:(CBPeripheral *)periperal;
-(void) adjustInterval:(CBPeripheral *)p;
-(void) getDeviceInfo:(NSString *)deviceId;

-(void) writeValue:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p;
-(void) setBleNotification:(NSString *)serviceUUID characteristicUUID:(NSString *)characteristicUUID  p:(CBPeripheral *)p on:(BOOL)on;

-(UInt16) swap:(UInt16) s;
-(int) controlSetup:(int) s;
-(int) findBLEPeripherals:(int) timeout;
-(const char *) centralManagerStateToString:(int)state;
-(void) scanTimer:(NSTimer *)timer;
-(void) printKnownPeripherals;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p;
-(CBService *) findServiceFromUUIDAndVerifyData:(CBUUID *)UUID p:(CBPeripheral *)p data:(NSData *)data;
-(CBService *) notifyfindServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service data:(NSData *)data;
-(CBCharacteristic *) notifyfindCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;

@end
