#import <Foundation/Foundation.h>

@interface ServerResponseObject : NSObject
{
    NSString *isIncomingEnabled;
    NSNumber *numberOfPauseCharacters;
    NSString *terminatingCharacter;
    NSString *capabilityToken;
    NSString *tokenDuration;
    NSString *twilioPhoneNumber;
}

@property (nonatomic, retain) NSString *isIncomingEnabled;
@property (nonatomic, retain) NSNumber *numberOfPauseCharacters;
@property (nonatomic, retain) NSString *terminatingCharacter;
@property (nonatomic, retain) NSString *capabilityToken;
@property (nonatomic, retain) NSString *tokenDuration;
@property (nonatomic, retain) NSString *twilioPhoneNumber;



@end
