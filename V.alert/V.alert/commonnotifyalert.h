#import <Foundation/Foundation.h>
@import AVFoundation;
@interface commonnotifyalert : NSObject<AVAudioPlayerDelegate>
{
    NSTimer*vibrateTimer;
    NSTimer*trackerTimer;
    SystemSoundID soundID;
}
+(commonnotifyalert*)alertConstant;
//Send local notification for the battery status
@property (nonatomic) UIBackgroundTaskIdentifier backgroundLocalNotify;
@property(nonatomic, strong)AVAudioPlayer *player; // Tracker : To Play Music
-(void)Notifybatterystatus:(NSString *)deviceName deviceId:(NSString *)deviceId device:(NSString *)Status;
-(void)stopNotify;
-(void)repeatRingtone;
-(void)repeatLocalNotify;
-(void)repeatTrackerNotify;
-(void)repeatTrackerLocalnotify;
-(void)repeatTrackertone;
-(void)repaeatTrackervibrateTone;
-(void)startBackgroundExpiration;
-(void)endBackgroundExpiration;
- (void)stopSound;
@end
