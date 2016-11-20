//
//  IDYPlayerView.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/16.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYPlayerView.h"

@interface IDYPlayerView ()

@end

@implementation IDYPlayerView

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self == [super initWithCoder:aDecoder]) {
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame contentUrl:(NSURL *)url{
    
    if (self == [super initWithFrame:frame]) {
        
        self.url = url;
        // 日志相关
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:YES];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
        // 版本检测
        [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
        [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
        
        // 播放器创建
        self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:[self optionsByDefault]];
        // 播放视图参数
        self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.player.view.frame = self.bounds;
        // 播放页面显示模式
        self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
        self.autoresizesSubviews = YES;
        [self addSubview:self.player.view];
        // 准备播放
        self.player.shouldAutoplay = YES;
        [self.player prepareToPlay];
        
        [self installMovieNotificationObservers];
    }
    return self;
}


#pragma mark    - 

- (IJKFFOptions *)optionsByDefault
{
    IJKFFOptions *options = [[IJKFFOptions alloc] init];
    [options setPlayerOptionIntValue:30                 forKey:@"max-fps"];             // 最大fps
    [options setPlayerOptionIntValue:0                  forKey:@"framedrop"];           // 跳帧开关
    [options setPlayerOptionIntValue:3                  forKey:@"video-pictq-size"];    //
    [options setPlayerOptionIntValue:0                  forKey:@"videotoolbox"];        // videotoolbox开关
    [options setPlayerOptionIntValue:960                forKey:@"videotoolbox-max-frame-width"]; // 指定最大宽度
    [options setFormatOptionIntValue:0                  forKey:@"auto_convert"];        // 自动转屏开关
    [options setFormatOptionIntValue:1                  forKey:@"reconnect"];           // 重连次数
    [options setFormatOptionIntValue:30 * 1000 * 1000   forKey:@"timeout"];             // 超时时间
    [options setFormatOptionValue:@"ijkplayer"          forKey:@"user-agent"];          // ua
    options.showHudView   = NO;
    return options;
}

- (void)installMovieNotificationObservers
{
    // 视频加载过程状态回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    // 播放结束原因回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    // 缓冲结束回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    // 播放操作操作回调
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}


- (void)loadStateDidChange:(NSNotification *)not{
    
    NSLog(@"网络发生变化");
}

- (void)moviePlayBackDidFinish:(NSNotification *)not{
    
    NSLog(@"播放完成");
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification *)not{
    
    NSLog(@"缓冲完成");
}

- (void)moviePlayBackStateDidChange:(NSNotification *)not{
    
    NSLog(@"改变播放状态");
}


- (void)dealloc{
    
    // 销毁播放器
    [self.player shutdown];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
