//
//  ZSYPopoverListView.h
//  MyCustomTableViewForSelected
//
//  Created by Zhu Shouyu on 6/2/13.
//  Copyright (c) 2013 zhu shouyu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZSYPopoverListViewButtonBlock)(void);

@class ZSYPopoverListView;
@protocol ZSYPopoverListDatasource <NSObject>

- (NSInteger)popoverListView:(ZSYPopoverListView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)popoverListView:(ZSYPopoverListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol ZSYPopoverListDelegate <NSObject>
- (void)popoverListView:(ZSYPopoverListView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)popoverListView:(ZSYPopoverListView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0);
@end

@interface ZSYPopoverListView : UIView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id <ZSYPopoverListDelegate>delegate;
@property (nonatomic, retain) id <ZSYPopoverListDatasource>datasource;

@property (nonatomic, retain) UILabel *titleName;
@property (nonatomic, retain) UIButton *cancelBtn;


- (void)show;


- (void)dismiss;


- (id)dequeueReusablePopoverCellWithIdentifier:(NSString *)identifier;

- (UITableViewCell *)popoverCellForRowAtIndexPath:(NSIndexPath *)indexPath;            // returns nil if cell is not visible or index path is out of


- (void)setDoneButtonWithTitle:(NSString *)aTitle block:(ZSYPopoverListViewButtonBlock)block;


- (void)setCancelButtonTitle:(NSString *)aTitle block:(ZSYPopoverListViewButtonBlock)block;

- (NSIndexPath *)indexPathForSelectedRow;
@end

