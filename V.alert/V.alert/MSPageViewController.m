//
//  MSPageViewController.m
//  MSPageViewController
//
//  Created by Nacho Soto on 2/16/14.
//  Copyright (c) 2014 MindSnacks. All rights reserved.
//

#import "MSPageViewController.h"
#import "MSPageViewController+Protected.h"
#import "Constants.h"

@implementation MSPageViewController

- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options {
    if ((self = [super initWithTransitionStyle:style
                         navigationOrientation:navigationOrientation
                                       options:options])) {
        [self ms_setUp];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self ms_setUp];
    }
    
    return self;
}

#pragma mark - Protected

- (void)ms_setUp {
    self.dataSource = self;
}

- (NSArray *)pageIdentifiers {
    [self doesNotRecognizeSelector:_cmd];
    
    return nil;
}

- (NSInteger)pageCount {
#ifdef HNALERT
    return 5;
#else
    return (NSInteger)self.pageIdentifiers.count;
#endif
}

- (void)setUpViewController:(UIViewController<MSPageViewControllerChild> *)viewController
                    atIndex:(NSInteger)index {
    
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationController.navigationBarHidden = NO;
    NSAssert(self.pageCount > 0, @"%@ has no pages", self);
    
    
   // self.view bringSubviewToFront:self.p
    
    
    
    [self setViewControllers:@[[self viewControllerAtIndex:0]]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO
                  completion:nil];
    
    if (self.pageCount == 1) {
        self.view.userInteractionEnabled = NO;
    }
    NSLog(@"self.pageCount -%d",(int)self.pageCount );
   // [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                             //     forBarMetrics:UIBarMetricsDefault];
   // self.navigationController.navigationBar.shadowImage = [UIImage new];
    
   // [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    //self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.opaque = YES;
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    UIButton *lftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
   // [lftBtn setBackgroundImage:[UIImage imageNamed:@"img_btn_back.png"]
                   //   forState:UIControlStateNormal];
    lftBtn.frame = CGRectMake(0, 0,70, 26);
    [lftBtn addTarget:self action:@selector(back)
     forControlEvents:UIControlEventTouchUpInside];
    [lftBtn setTitle:NSLocalizedString(@"<back", nil) forState:UIControlStateNormal];
  //  [lftBtn setTitleColor:[UIColor colorWithRed:63/255.0 green:56/255.0 blue:84/255.0 alpha:1] forState:UIControlStateNormal];
    [lftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *leftbarButton = [[UIBarButtonItem alloc] initWithCustomView:lftBtn];
    self.navigationItem.leftBarButtonItem = leftbarButton;
    
    UIImageView*navimg = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,128,33)];
    navimg.image =[UIImage imageNamed:@"vsn-header-logo.png"];
    UIView*navView = [[UIView alloc]initWithFrame:CGRectMake(0,0,128,33)];
    [navView addSubview:navimg];
    self.navigationItem.titleView = navView;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    //self.navigationBar.translucent = YES;
    // [self.navigationBar setHidden:YES];
    //left bar button

}
#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController<MSPageViewControllerChild> *)viewController {
    const NSInteger index = viewController.pageIndex;
    
    if(index ==5)
    {
        viewController.navigationController.navigationBarHidden = YES;
    }
    else
    {
        viewController.navigationController.navigationBarHidden = NO;
    }
    
#ifdef HNALERT
    if(index==5)
        return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index - 2];
    else
        return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index - 1];
#else
    return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index - 1];
#endif
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController<MSPageViewControllerChild> *)viewController {
    const NSInteger index = viewController.pageIndex;
    
    if(index == 5)
    {
        viewController.navigationController.navigationBarHidden = YES;
    }
    else
    {
        viewController.navigationController.navigationBarHidden = NO;
    }
    
#ifdef HNALERT
    if(index == 3)
        return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index + 2];
    else
        return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index + 1];
#else
    return (index == NSNotFound) ? nil : [self viewControllerAtIndex:index + 1];
#endif
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index {
    UIViewController<MSPageViewControllerChild> *result = nil;
    
#ifdef HNALERT
    if (index >= 0 && index <= self.pageCount)
#else
    if (index >= 0 && index < self.pageCount)
#endif
    {
        NSAssert(self.storyboard,
                 @"This controller is only meant to be used inside of a UIStoryboard");
        
        result = [self.storyboard instantiateViewControllerWithIdentifier:self.pageIdentifiers[(NSUInteger)index]];
        
        NSParameterAssert(result);
        NSAssert([result conformsToProtocol:@protocol(MSPageViewControllerChild)],
                 @"Child view controller (%@) must conform to %@",
                 result,
                 NSStringFromProtocol(@protocol(MSPageViewControllerChild)));
        
        result.pageIndex = index;
        
        [self setUpViewController:result
                          atIndex:index];
    }
    
    return result;
}

- (NSInteger)presentationCountForPageViewController:(MSPageViewController *)pageViewController {
    const BOOL shouldShowPageControl = (pageViewController.pageCount > 1);
    
    //return (shouldShowPageControl) ? pageViewController.pageCount : 0;
    
     return (shouldShowPageControl) ? pageViewController.pageCount : 0;
   // return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [pageViewController.viewControllers.lastObject pageIndex];
}
- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return NO;
}
@end
