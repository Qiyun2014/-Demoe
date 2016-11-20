//
//  IDYPlayerView.h
//  GoPro_Demo
//
//  Created by qiyun on 16/11/16.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface IDYPlayerView : UIView

- (id)initWithFrame:(CGRect)frame contentUrl:(NSURL *)url;

@property (nonatomic, strong)   IJKFFMoviePlayerController *player;
@property (nonatomic, copy) NSURL *url;

@end
