//
//  WTTableView.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/18.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "WTTableView.h"
#import "WTTableViewCell.h"

@interface WTTableView () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation WTTableView

- (id)initWithFrame:(CGRect)frame{
    
    if (self == [super initWithFrame:frame]) {
        
        self.dataSource = self;
        self.delegate = self;
        
        self.tableFooterView = [UIView new];
    }
    return self;
}

#pragma mark    -   tableView delegate and datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        if (self.cell) return self.cell;
        else{
            
            cell = [[WTTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    switch (self.headerPosition) {
            
        case WTTableViewHeaderPosition_left:{
            
            
        }
            break;
         
        case WTTableViewHeaderPosition_center:{
            
            
        }
            break;
            
        case WTTableViewHeaderPosition_right:{
            
            
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    switch (self.footerStyle) {
            
        case WTTableViewFooterStyle_aButton:{
            
            
        }
            break;
            
        case WTTableViewFooterStyle_twoButton:{
            
            
        }
            break;
            
        case WTTableViewFooterStyle_threeButton:{
            
            
        }
            break;
            
        default:
            break;
    }
    return nil;
}

@end
