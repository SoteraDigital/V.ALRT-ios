//
//  MSPageViewControllerExample.m
//  MSPageViewController
//
//  Created by Nacho Soto on 2/16/14.
//  Copyright (c) 2014 MindSnacks. All rights reserved.
//

#import "MSPageViewControllerExample.h"

@implementation MSPageViewControllerExample

+ (void)initialize {
    if (self == MSPageViewControllerExample.class) {
        UIPageControl *pageControl = UIPageControl.appearance;
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor;
        pageControl.currentPageIndicatorTintColor =  UIColor.whiteColor;
        [pageControl setBackgroundColor:[UIColor blackColor]];
        
       
    }
}

- (NSArray *)pageIdentifiers {
    return @[@"page1", @"page2", @"page3", @"page4", @"page5", @"page6"];
    //return @[@"page1", @"page3"];
}

@end
