//
//  WTTableView.h
//  GoPro_Demo
//
//  Created by qiyun on 16/11/18.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, WTTableViewHeaderPosition) {
    
    WTTableViewHeaderPosition_left = 0,       //标题居左
    WTTableViewHeaderPosition_center,         //标题居中
    WTTableViewHeaderPosition_right           //标题居右
};

typedef NS_ENUM(NSInteger, WTTableViewFooterStyle) {
    
    WTTableViewFooterStyle_aButton,
    WTTableViewFooterStyle_twoButton,
    WTTableViewFooterStyle_threeButton
};


/////////////////////////////////////////////////////////////////////////////////////////////////////

@interface
WTTableView : UITableView


@property (nonatomic, strong) UIView            *wt_headerView;
@property (nonatomic, strong) UIView            *wt_footView;
@property (nonatomic, strong) UITableViewCell   *cell;

@property (nonatomic) WTTableViewHeaderPosition headerPosition;
@property (nonatomic) WTTableViewFooterStyle footerStyle;
@property (nonatomic) NSInteger numberOfRows;


@end
