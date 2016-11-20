//
//  IDYRealTimePlayerViewController.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/15.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYRealTimePlayerViewController.h"
#import <LFLiveKit.h>

@interface IDYRealTimePlayerViewController ()<LFLiveSessionDelegate>

@property (nonatomic, copy) NSString *rtmpUrl;
@property (nonatomic, strong) LFLiveSession *session;
@property (nonatomic, weak) UIView *livingPreView;
@property(nonatomic, strong) CAEmitterLayer *emitterLayer;

- (IBAction)cancelAction:(id)sender;
- (IBAction)beautifulAction:(id)sender;
- (IBAction)cameraPositionAction:(id)sender;

@end

@implementation IDYRealTimePlayerViewController

#pragma mark    -   懒加载

- (UIView *)livingPreView
{
    if (!_livingPreView) {
        UIView *livingPreView = [[UIView alloc] initWithFrame:self.view.bounds];
        livingPreView.backgroundColor = [UIColor clearColor];
        livingPreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:livingPreView atIndex:0];
        
        [livingPreView.layer addSublayer:self.emitterLayer];
        _livingPreView = livingPreView;
    }
    return _livingPreView;
}

- (LFLiveSession *)session{
    
    if(!_session){
        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:[LFLiveVideoConfiguration defaultConfigurationForQuality:LFLiveVideoQuality_Medium2]];
        
        /**    自己定制高质量音频128K 分辨率设置为720*1280 方向竖屏 */
        /*
        LFLiveAudioConfiguration *audioConfiguration = [LFLiveAudioConfiguration new];
        audioConfiguration.numberOfChannels = 2;
        audioConfiguration.audioBitrate = LFLiveAudioBitRate_128Kbps;
        audioConfiguration.audioSampleRate = LFLiveAudioSampleRate_44100Hz;
        
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize = CGSizeMake(720, 1280);
        videoConfiguration.videoBitRate = 800*1024;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 500*1024;
        videoConfiguration.videoFrameRate = 15;
        videoConfiguration.videoMaxKeyframeInterval = 30;
        //videoConfiguration.orientation = UIInterfaceOrientationPortrait;
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        
        _session = [[LFLiveSession alloc] initWithAudioConfiguration:audioConfiguration videoConfiguration:videoConfiguration];
        */
        
        // 设置代理
        _session.delegate = self;
        _session.running = YES;
        _session.preView = self.livingPreView;
    }
    return _session;
}


- (CAEmitterLayer *)emitterLayer
{
    if (!_emitterLayer) {
        
#if 0
        //emitter
        _emitterLayer = [[CAEmitterLayer alloc] init];
        _emitterLayer.emitterPosition = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height-20);
        _emitterLayer.emitterSize = CGSizeMake(self.view.frame.size.width-100, 20);
        _emitterLayer.renderMode = kCAEmitterLayerUnordered;
        _emitterLayer.emitterShape = kCAEmitterLayerCuboid;
        
        _emitterLayer.emitterDepth = 10;
        _emitterLayer.preservesDepth = YES;

        NSMutableArray *butterflys = [NSMutableArray array];
        
        for (int i = 1; i <= 9; i ++) {
            
            //cells
            //blue butterfly
            CAEmitterCell *blueButterfly = [CAEmitterCell emitterCell];
            blueButterfly.birthRate = 8;
            blueButterfly.lifetime = 5.0;
            blueButterfly.lifetimeRange = 1.5;
            blueButterfly.color = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
            blueButterfly.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"love%d_.png", i]] CGImage];
            [blueButterfly setName:@"blueButterfly"];
            
            blueButterfly.velocity = 160;
            blueButterfly.velocityRange = 80;
            blueButterfly.emissionLongitude = M_PI+M_PI_2;
            blueButterfly.emissionLatitude = M_PI+M_PI_2;
            blueButterfly.emissionRange = M_PI_2;
            
            blueButterfly.scaleSpeed = 0.3;
            blueButterfly.spin = 0.2;
            blueButterfly.alphaSpeed = 0.2;
            
            //yellow butterfly
            CAEmitterCell *yellowButterfly = [CAEmitterCell emitterCell];
            yellowButterfly.birthRate = 12;
            yellowButterfly.lifetime = 5.0;
            yellowButterfly.lifetimeRange = 1.5;
            yellowButterfly.color = [[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05] CGColor];
            yellowButterfly.contents = (id)[[UIImage imageNamed:[NSString stringWithFormat:@"love%d_.png", i]] CGImage];
            [yellowButterfly setName:@"yellowButterfly"];
            
            yellowButterfly.velocity = 250;
            yellowButterfly.velocityRange = 100;
            yellowButterfly.emissionLongitude = M_PI+M_PI_2;
            yellowButterfly.emissionLatitude = M_PI+M_PI_2;
            yellowButterfly.emissionRange = M_PI_2;
            yellowButterfly.alphaSpeed = 0.2;
            yellowButterfly.scaleSpeed = 0.3;
            yellowButterfly.spin = 0.2;
            
            [butterflys addObject:yellowButterfly];
            [butterflys addObject:blueButterfly];
        }
        
        _emitterLayer.emitterCells = butterflys;
#else
        
        _emitterLayer = [CAEmitterLayer layer];
        // 发射器在xy平面的中心位置
        _emitterLayer.emitterPosition = CGPointMake(CGRectGetWidth(self.view.bounds)/2 ,CGRectGetHeight(self.view.bounds)-25);
        // 发射器的尺寸大小
        _emitterLayer.emitterSize = CGSizeMake(20, 20);
        // 渲染模式
        _emitterLayer.renderMode = kCAEmitterLayerUnordered;
        // 开启三维效果
        _emitterLayer.preservesDepth = YES;
        NSMutableArray *array = [NSMutableArray array];
        // 创建粒子
        for (int i = 0; i<10; i++) {
            // 发射单元
            CAEmitterCell *stepCell = [CAEmitterCell emitterCell];
            // 粒子的创建速率，默认为1/s
            stepCell.birthRate = 2;
            // 粒子存活时间
            stepCell.lifetime = arc4random_uniform(4) + 1;
            // 粒子的生存时间容差
            stepCell.lifetimeRange = 3;
            // 颜色
            // fire.color=[[UIColor colorWithRed:0.8 green:0.4 blue:0.2 alpha:0.1]CGColor];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"love%d_.png", i]];
            // 粒子显示的内容
            stepCell.contents = (id)[image CGImage];
            // 粒子的名字
            //            [fire setName:@"step%d", i];
            // 粒子的运动速度
            stepCell.velocity = arc4random_uniform(100) + 100;
            // 粒子速度的容差
            stepCell.velocityRange = 80;
            // 粒子在xy平面的发射角度
            stepCell.emissionLongitude = M_PI+M_PI_2;;
            // 粒子发射角度的容差
            stepCell.emissionRange = M_PI_2/6;
            // 缩放比例
            stepCell.scale = 0.3;
            stepCell.alphaSpeed = 0.4;
            [array addObject:stepCell];
        }
        
        _emitterLayer.emitterCells = array;
#endif
        
    }
    return _emitterLayer;
}

#pragma mark    -   生命周期

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 默认开启后置摄像头
    self.session.captureDevicePosition = AVCaptureDevicePositionFront;
    
    LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
    // 设置推流地址
    stream.url = @"rtmp://192.168.91.37:1935/rtmplive/room";
    self.rtmpUrl = stream.url;
    [self.session startLive:stream];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark    -   点击事件

- (IBAction)cancelAction:(UIButton *)sender {
    
    [self.session stopLive];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)beautifulAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    // 默认是开启了美颜功能的
    self.session.beautyFace = !self.session.beautyFace;
}

- (IBAction)cameraPositionAction:(UIButton *)sender {
    
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    NSLog(@"切换前置/后置摄像头");
}


#pragma mark -- LFStreamingSessionDelegate

/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state{
    NSString *tempStatus;
    switch (state) {
        case LFLiveReady:
            tempStatus = @"准备中";
            break;
        case LFLivePending:
            tempStatus = @"连接中";
            break;
        case LFLiveStart:
            tempStatus = @"已连接";
            break;
        case LFLiveStop:
            tempStatus = @"已断开";
            break;
        case LFLiveError:
            tempStatus = @"连接出错";
            break;
        default:
            break;
    }
    NSLog(@"连接状态  %@",[NSString stringWithFormat:@"状态: %@\nRTMP: %@", tempStatus, self.rtmpUrl]);
}

/** live debug info callback */
- (void)liveSession:(nullable LFLiveSession *)session debugInfo:(nullable LFLiveDebug*)debugInfo{
    
}

/** callback socket errorcode */
- (void)liveSession:(nullable LFLiveSession*)session errorCode:(LFLiveSocketErrorCode)errorCode{
    
    NSLog(@"errorCode = %lu",(unsigned long)errorCode);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
