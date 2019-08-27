#import <Foundation/Foundation.h>

#define __LOG_FILE__
@interface logfile : NSObject
{}
+ (logfile *) logfileObj;
-(void)writeLog:(NSString *)cnt1;
-(NSString *)openLog;
@end
