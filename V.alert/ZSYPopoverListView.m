//
//  ZSYPopoverListView.m
//  MyCustomTableViewForSelected
//
//  Created by Zhu Shouyu on 6/2/13.
//  Copyright (c) 2013 zhu shouyu. All rights reserved.
//

#import "ZSYPopoverListView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "Constants.h"

static const CGFloat ZSYCustomButtonHeight = 40;

static const char * const kZSYPopoverListButtonClickForCancel = "kZSYPopoverListButtonClickForCancel";

static const char * const kZSYPopoverListButtonClickForDone = "kZSYPopoverListButtonClickForDone";

@interface ZSYPopoverListView ()
@property (nonatomic, retain) UITableView *mainPopoverListView;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIControl *controlForDismiss;

- (void)initTheInterface;


- (void)animatedIn;


- (void)animatedOut;


- (void)show;


- (void)dismiss;
@end

@implementation ZSYPopoverListView
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;
@synthesize mainPopoverListView = _mainPopoverListView;
@synthesize doneButton = _doneButton;
@synthesize cancelButton = _cancelButton;
@synthesize titleName = _titleName;
@synthesize controlForDismiss = _controlForDismiss;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTheInterface];
    }
    return self;
}

- (void)initTheInterface
{
    self.layer.borderColor = [ [UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f] CGColor];
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = TRUE;
    
    _titleName = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleName.font = [UIFont systemFontOfSize:17.0f];
   /* self.titleName.backgroundColor = [UIColor colorWithRed:59./255.
                                                 green:89./255.
                                                  blue:152./255.
                                                 alpha:1.0f];
    */
    self.titleName.backgroundColor = [UIColor whiteColor];
    self.titleName.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleName.textAlignment = NSTextAlignmentCenter;
    self.titleName.textColor = [UIColor colorWithRed:(80/255.f) green:(74/255.f) blue:(103/255.f) alpha:1.0f];
    CGFloat xWidth = self.bounds.size.width;
    self.titleName.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleName.frame = CGRectMake(0, 0, xWidth, 32.0f);
    CALayer* layer = [self.titleName layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderWidth = 1;
    bottomBorder.frame = CGRectMake(-1, layer.frame.size.height-1, layer.frame.size.width, 1);
    [bottomBorder setBorderColor:BRANDING_COLOR.CGColor];
    [layer addSublayer:bottomBorder];
    [self addSubview:self.titleName];
    
    CGRect tableFrame = CGRectMake(0, 32.0f, xWidth, self.bounds.size.height-32.0f);
    _mainPopoverListView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [_mainPopoverListView setSeparatorInset:UIEdgeInsetsZero];
    self.mainPopoverListView.dataSource = self;
    self.mainPopoverListView.delegate = self;
    [self addSubview:self.mainPopoverListView];
}

- (void)refreshTheUserInterface
{
    if (self.cancelButton || self.doneButton)
    {
        self.mainPopoverListView.frame = CGRectMake(0, 32.0f, self.mainPopoverListView.frame.size.width, self.mainPopoverListView.frame.size.height - ZSYCustomButtonHeight);
      //   [self.cancelBtn setTitleColor:[UIColor colorWithRed:(63/255.f) green:(56/255.f) blue:(84/255.f) alpha:1.0f] forState:UIControlStateNormal];
          [self.cancelButton addTarget:self action:@selector(touchForDismissSelf:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.doneButton && nil == self.cancelButton)
    {
        self.doneButton.frame = CGRectMake(0, self.bounds.size.height - ZSYCustomButtonHeight, self.bounds.size.width, ZSYCustomButtonHeight);
    }
    else if (nil == self.doneButton && self.cancelButton)
    {
        self.cancelButton.frame = CGRectMake(0, self.bounds.size.height - ZSYCustomButtonHeight, self.bounds.size.width, ZSYCustomButtonHeight);
    }
    else if (self.doneButton && self.cancelButton)
    {
        self.doneButton.frame = CGRectMake(0, self.bounds.size.height - ZSYCustomButtonHeight, self.bounds.size.width / 2.0f, ZSYCustomButtonHeight);
        self.cancelButton.frame = CGRectMake(self.bounds.size.width / 2.0f, self.bounds.size.height - ZSYCustomButtonHeight, self.bounds.size.width / 2.0f, ZSYCustomButtonHeight);
    }
    if (nil == self.cancelButton && nil == self.doneButton)
    {
        if (nil == _controlForDismiss)
        {
            _controlForDismiss = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _controlForDismiss.backgroundColor = [UIColor colorWithRed:.16 green:.17 blue:.21 alpha:.5];
            [_controlForDismiss addTarget:self action:@selector(touchForDismissSelf:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (NSIndexPath *)indexPathForSelectedRow
{
    return [self.mainPopoverListView indexPathForSelectedRow];
}
#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(popoverListView:numberOfRowsInSection:)])
    {
        return [self.datasource popoverListView:self numberOfRowsInSection:section];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(popoverListView:cellForRowAtIndexPath:)])
    {
        return [self.datasource popoverListView:self cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popoverListView:didDeselectRowAtIndexPath:)])
    {
        [self.delegate popoverListView:self didDeselectRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(popoverListView:didSelectRowAtIndexPath:)])
    {
        [self.delegate popoverListView:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Animated Mthod
- (void)animatedIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)animatedOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            if (self.controlForDismiss)
            {
              //  [self.controlForDismiss removeFromSuperview];
            }
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - show or hide self
- (void)show
{
    [self refreshTheUserInterface];
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    if (self.controlForDismiss)
    {
        [keywindow addSubview:self.controlForDismiss];
    }
    [keywindow addSubview:self];
    
    self.center = CGPointMake(keywindow.bounds.size.width/2.0f,
                              keywindow.bounds.size.height/2.0f);
    [self animatedIn];
}

- (void)dismiss
{
    [self animatedOut];
}

#pragma mark - Reuse Cycle
- (id)dequeueReusablePopoverCellWithIdentifier:(NSString *)identifier
{
    return [self.mainPopoverListView dequeueReusableCellWithIdentifier:identifier];
}

- (UITableViewCell *)popoverCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.mainPopoverListView cellForRowAtIndexPath:indexPath];
}

+ (UIImage *)normalButtonBackgroundImage
{
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		179/255.0, 185/255.0, 199/255.0, opacity,
		121/255.0, 132/255.0, 156/255.0, opacity,
		87/255.0, 100/255.0, 130/255.0, opacity,
		108/255.0, 120/255.0, 146/255.0, opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)cancelButtonBackgroundImage
{
	const size_t locationCount = 4;
	CGFloat opacity = 1.0;
    CGFloat locations[locationCount] = { 0.0, 0.5, 0.5 + 0.0001, 1.0 };
    CGFloat components[locationCount * 4] = {
		255/255.0, 255/255.0, 255/255.0, opacity,
		255/255.0, 255/255.0, 255/255.0, opacity,
		255/255.0, 255/255.0, 255/255.0,  opacity,
		255/255.0, 255/255.0, 255/255.0,  opacity,
	};
	return [self glassButtonBackgroundImageWithGradientLocations:locations
													  components:components
												   locationCount:locationCount];
}

+ (UIImage *)glassButtonBackgroundImageWithGradientLocations:(CGFloat *)locations
												  components:(CGFloat *)components
											   locationCount:(NSInteger)locationCount
{
	const CGFloat lineWidth = 1;
	const CGFloat cornerRadius = 1;
	UIColor *strokeColor = [UIColor colorWithRed:80/255.0 green:74/255.0 blue:103/255.0 alpha:1.0];
	
	CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, ZSYCustomButtonHeight);
    
	BOOL opaque = NO;
    UIGraphicsBeginImageContextWithOptions(rect.size, opaque, [[UIScreen mainScreen] scale]);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, locationCount);
	
	CGRect strokeRect = CGRectInset(rect, lineWidth * 0.5, lineWidth * 0.5);
	UIBezierPath *strokePath = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:cornerRadius];
	strokePath.lineWidth = lineWidth;
	[strokeColor setStroke];
	[strokePath stroke];
	
	CGRect fillRect = CGRectInset(rect, lineWidth, lineWidth);
	UIBezierPath *fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius];
	[fillPath addClip];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat capHeight = floorf(rect.size.height * 0.5);
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(capHeight, cornerRadius, capHeight, cornerRadius)];
}

#pragma mark - Button Method
- (void)setCancelButtonTitle:(NSString *)aTitle block:(ZSYPopoverListViewButtonBlock)block
{
    if (nil == _cancelButton)
    {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setBackgroundImage:[ZSYPopoverListView cancelButtonBackgroundImage] forState:UIControlStateNormal];
       // [self.cancelButton setBackgroundColor:[UIColor whiteColor]];
       //[self.cancelBtn setTitleColor:[UIColor colorWithRed:63.0/255.0 green:56.0/255.0 blue:84.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelButton];
    }
    [self.cancelButton setTitle:aTitle forState:UIControlStateNormal];
      //[self.cancelBtn setTitleColor:[UIColor colorWithRed:63.0/255.0 green:56.0/255.0 blue:84.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:74.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
  // [self.cancelBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    objc_setAssociatedObject(self.cancelButton, kZSYPopoverListButtonClickForCancel, [block copy], OBJC_ASSOCIATION_RETAIN);
}

- (void)setDoneButtonWithTitle:(NSString *)aTitle block:(ZSYPopoverListViewButtonBlock)block
{
    if (nil == _doneButton)
    {
        self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setBackgroundImage:[ZSYPopoverListView normalButtonBackgroundImage] forState:UIControlStateNormal];
        [self.doneButton addTarget:self action:@selector(buttonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.doneButton];
    }
    [self.doneButton setTitle:aTitle forState:UIControlStateNormal];
    objc_setAssociatedObject(self.doneButton, kZSYPopoverListButtonClickForDone, [block copy], OBJC_ASSOCIATION_RETAIN);
}
#pragma mark - UIButton Clicke Method
- (void)buttonWasPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    ZSYPopoverListViewButtonBlock __block block;
    
    if (button == self.cancelButton)
    {
        block = objc_getAssociatedObject(sender, kZSYPopoverListButtonClickForCancel);
    }
    else
    {
        block = objc_getAssociatedObject(sender, kZSYPopoverListButtonClickForDone);
    }
    if (block)
    {
        block();
    }
    [self animatedIn];
}

- (void)touchForDismissSelf:(id)sender
{
    [self animatedOut];
}
@end
