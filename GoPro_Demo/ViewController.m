//
//  ViewController.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/9.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "ViewController.h"
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
#import "IYNBlueToothManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

#define k_host_ip @"10.5.5.9"
#define k_port 8554

@interface ViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IYNBlueToothManager   *blueToothManager;

@property (strong, nonatomic) AVPlayerLayer             *playerLayer;
@property (strong, nonatomic) AVPlayer                  *avPlayer;

@end

@implementation ViewController{
    
    NSFileHandle *fileHandle;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //self.tableView.delegate = self;
    //self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
    NSLog(@"~~~~~  %lu",strlen([@"123 osjdosi" UTF8String]));
    
    //self.blueToothManager = [[IYNBlueToothManager alloc] init];
    
    [self gopro_commandSetting:GoProCommandSettingRestart];
    [self goProTest];
    //
    
    /*
     http://live.3gv.ifeng.com/live/hongkong.m3u8
     rtmp://live.hkstv.hk.lxdns.com/live/hks
     rtsp://rtsp.vdowowza.tvb.com/tvblive/mobileinews200.stream
     */
    self.avPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"aaaaa" ofType:@""]]];
    
    // create a player view controller
    
    AVPlayerViewController*controller = [[AVPlayerViewController alloc] init];
    controller.view.frame = self.view.frame;
    
    controller.player = self.avPlayer;
    [self.avPlayer play];
    
    // show the view controller
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    
}


#pragma mark    -   tableView 代理和数据源设置

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self viewControllers].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        NSString *viewControllerName = [self viewControllers][indexPath.row];
        cell.textLabel.text = [viewControllerName stringByAppendingString:@"--> example"];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Class class = NSClassFromString([self viewControllers][indexPath.row]);
    
    if (class) {
        
        UIViewController *viewController = [[class alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}


#pragma mark    -   get方法

- (NSArray *)viewControllers{
    
    return @[@"IDYRealTimePlayerViewController",@"IDYIJKPlayerViewController",@"WTMelodyBinViewController"];
}


#pragma mark    -   gopro 相机连接

- (void)goProTest{
    
    /*
     Delete file:
     http://10.5.5.9/gp/gpControl/command/storage/delete?p=file (eg. /100GOPRO/G0010124.JPG)
     */
    

    NSError *error;
    //[self connectToServer];
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.udpSocket enableBroadcast:YES error:&error]; // 开启广播
    if (error) {
        NSLog(@"udp socket error = %@",error);
    }
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("com.douyu.tv", NULL));
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        NSLog(@"哈哈😆。。");
        
    });
    dispatch_resume(timer);
    
    [self.udpSocket bindToPort:k_port error:&error]; // 绑定端口
    //[self.udpSocket joinMulticastGroup:k_host_ip error:&error];
    
    if (error) {
        NSLog(@"udp socket bindToPort error = %@",error);
    }else{
        
        [self.avPlayer play];
        [self createFile];

        [self.udpSocket beginReceiving:&error];
    }
}


#pragma mark    -   gopro 指令设置和连接

/* 重启gopro指令 */
- (void)gopro_commandSetting:(GoProCommandSetting)type{
    
    NSError *error;
    NSURL *url;
    NSString *urlString;
    
    switch (type) {
            
        case GoProCommandSettingRestart:
            urlString = @"http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart";
            break;
            
        case GoProCommandSettingVersion:
            urlString = @"";
            break;
            
        case GoProCommandSettingMediaList:
            urlString = @"http://10.5.5.9:8080/gp/gpMediaList";
            break;
            
        case GoProCommandSettingMainDirectory:
            urlString = @"http://10.5.5.9:8080/videos";
            break;
            
        case GoProCommandSettingDeviceName:
            urlString = @"http://10.5.5.9gp/gpControl/command/wireless/ap/ssid?ssid=GOPRONAME";
            break;
            
        case GoProCommandSettingWifiAndPassword:        //GOPRONAME = GoPro new WiFi name   GOPROPASS = GoPro new WiFi password
            urlString = @"http://10.5.5.9gp/gpControl/command/wireless/ap/ssid?ssid=GOPRONAME&pw=GOPROPASS";
            break;
            
        case GoProCommandSettingFormat:
            urlString = @"http://10.5.5.9/gp/gpControl/command/storage/delete/all";
            break;
            
        default:
            break;
    }
    
    url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"get"];
    
    __block NSURLResponse *response= nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"dict = %@",dict);
    }
    
}


/* 创建一个本地文件，用于存储视频数据 */
- (NSString *)createFile{
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    
    //构造字符串文件的存储路径
    NSString *strPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.ts",[[NSDate date] description]]];
    //构造字符串对象
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager createFileAtPath:strPath contents:nil attributes:nil];
    
    if (success) {
        
        NSLog(@"success");
    }
    
    //打开上面创建的那个文件
    fileHandle = [NSFileHandle fileHandleForWritingAtPath:strPath];
    
    return strPath;
}

- (void)connectToServer{
    
    // 1.与服务器通过三次握手建立连接
    NSString *host = k_host_ip;
    int port = k_port;
    
    //创建一个socket对象
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //连接
    NSError *error = nil;
    [_socket connectToHost:host onPort:port withTimeout:10 error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}


#pragma mark    -   udp delegate


/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    
    NSLog(@"连接成功   %@",address);
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{
    
    NSLog(@"没有连接  %@",error);
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    
    NSLog(@"数据发送成功");
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
    
    NSLog(@"数据发送失败 %@",error);
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
    
    if (data.length < 200) {
        
        NSLog(@"数据错误");
        return;
    }
    
    //void *fileData;
    //[data getBytes:fileData length:[data length]];
    NSData *newData = [data subdataWithRange:NSMakeRange(3, 188)];
    
    NSLog(@"接收到数据  %@   长度  %lu",data,(unsigned long)newData.length);
    
    NSString *msg = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    NSLog(@"message rec'd: %@:%hu %@\n", [_udpSocket localHost_IPv4], [_udpSocket localPort],msg);
    
    if (fileHandle) {
        
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:newData];
        NSLog(@"写入数据到文件");
    }
    
    [self.udpSocket sendData:[NSData dataWithBytes:"123" length:3] toHost:k_host_ip port:k_port withTimeout:10 tag:1];
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{
    
    NSLog(@"udp 关闭");
}



#pragma mark -socket的代理


-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    NSLog(@"%s  host = %@  port = %d",__func__,host, port);
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    if (err) {
        NSLog(@"连接失败  %@",err);
        
        [_socket connectToHost:k_host_ip onPort:k_port withTimeout:10 error:nil];
    }else{
        NSLog(@"正常断开");
    }
}


-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
}


-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@",__func__,receiverStr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
