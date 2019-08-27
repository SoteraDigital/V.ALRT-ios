//  Created by Stijn Spijker (http://stijnspijker.nl/) on 2009-07-03.
//  Based on gifdecode written april 2009 by Martin van Spanje, P-Edge media.
//
//  Released under MIT license, see https://github.com/scspijker/iOS_AnimatedGif

#ifdef TARGET_OS_IPHONE			
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif 	

@interface AnimatedGifQueueObject : NSObject
{
    UIImageView *uiv;
    NSURL *url;
}

@property (nonatomic, strong) UIImageView *uiv;
@property (nonatomic, strong) NSURL *url;

@end


@interface AnimatedGif : NSObject
{
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableData *GIF_frameHeader;
	
	NSMutableArray *GIF_delays;
	NSMutableArray *GIF_framesData;
    
    NSMutableArray *imageQueue;
	bool busyDecoding;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
    
    UIImageView *imageView;
}

@property (nonatomic, strong) UIImageView* imageView;
@property bool busyDecoding;

- (void) addToQueue: (AnimatedGifQueueObject *) agqo;
+ (UIImageView*) getAnimationForGifAtUrl: (NSURL *) animationUrl;
- (void) decodeGIF:(NSData *)GIF_Data;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(long)length;
- (bool) GIFSkipBytes: (long) length;
- (NSMutableData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;
- (UIImageView*) getAnimation;

@end
