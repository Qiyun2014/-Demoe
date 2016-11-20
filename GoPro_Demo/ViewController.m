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

#define k_host_ip @"10.5.5.9"
#define k_port 8080

@interface ViewController ()<GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IYNBlueToothManager   *blueToothManager;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    NSLog(@"~~~~~  %lu",strlen([@"123 osjdosi" UTF8String]));
    
    self.blueToothManager = [[IYNBlueToothManager alloc] init];
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
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_queue_create("com.douyu.tv", 0));
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), 1 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        
        NSLog(@"哈哈😆。。");
    });
    dispatch_resume(timer);
    
    
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"data" ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:dataPath];
    
    NSLog(@"fileData = %@",fileData);
    
    // 1 创建URL对象
    NSString *restart = @"http://10.5.5.9/gp/gpControl/execute?p1=gpStream&a1=proto_v2&c1=restart";
    NSString *mode = @"http://10.5.5.9/gp/gpControl/command/sub_mode?mode=0&sub_mode=0";
    
    NSString *mediaList = @"http://10.5.5.9:8080/gp/gpMediaList";
    NSString *mediaMainDirectory = @"http://10.5.5.9:8080/videos";
    
    
    //Set GoPro WiFi name/password:
    
    //GoPro Name: http://10.5.5.9gp/gpControl/command/wireless/ap/ssid?ssid=GOPRONAME
    //GoPro Name and Password: http://10.5.5.9gp/gpControl/command/wireless/ap/ssid?ssid=GOPRONAME&pw=GOPROPASS
    
    //GOPRONAME = GoPro new WiFi name
    //GOPROPASS = GoPro new WiFi password
    
    /*
     
     NSString *format_SD_Card = @"http://10.5.5.9/gp/gpControl/command/storage/delete/all";
     
     Delete file:
     http://10.5.5.9/gp/gpControl/command/storage/delete?p=file (eg. /100GOPRO/G0010124.JPG)
     */
    
    
    NSURL *url = [NSURL URLWithString:mediaList];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"get"];
    
    NSURLResponse *response= nil;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (data) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"dict = %@",dict);
    }
    
    //[self socketToCamera];
    [self connectToServer];
    
    
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.udpSocket enableBroadcast:YES error:&error]; // 开启广播
    if (error) {
        NSLog(@"udp socket error = %@",error);
    }
    
    [self.udpSocket bindToPort:k_port error:&error]; // 绑定端口
    if (error) {
        NSLog(@"udp socket bindToPort error = %@",error);
    }
    
    // 2.开启定时器，每个一秒发送一次
    NSTimer *sendTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(p_sendUdp) userInfo:nil repeats:YES];
}

- (void)p_sendUdp
{
    NSString *sendStr = [NSString stringWithFormat:@"{\"ip\":\"\%@\"}",k_host_ip]; // 发送本机IP地址
    NSData *sendData = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:sendData toHost:k_host_ip port:k_port withTimeout:-1 tag:0];
}

// 当收到udp数据包时就会调用，但是你经常会收到不是自己想要的数据包，这些数据包可能来着其他主机，你需要忽略掉这些，这个代理方法返回bool类型，如果返回NO,当收到其他数据包，就会继续调用这个代理方法。
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"data = %@",data);
    return YES;
}



- (void)socketToCamera{
    
    NSString * host = @"10.5.5.9";
    NSNumber * port = @8080;
    
    // 创建 socket
    int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
    if (-1 == socketFileDescriptor) {
        NSLog(@"创建失败");
        return;
    }
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        close(socketFileDescriptor);
        NSLog(@"%@",@"无法解析服务器的主机名");
        return;
    }
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    
    // 设置 socket 参数
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([port intValue]);
    
    // 连接 socket
    int ret = connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(socketFileDescriptor);
        NSLog(@"连接失败");
        return;
    }
    NSLog(@"连接成功");
    
    /*
     1、EBADF 参数sockfd 非合法socket 处理代码.
     2、EACCESS 权限不足
     3、ENOTSOCK 参数sockfd 为一文件描述词, 非socket.
     */
    bind(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    
//    while(1)
//    {
//        ssize_t data = recvmsg(socketFileDescriptor, buffer, 0);
//        printf("data = %zd",data);
//    }
}


- (void)connectToServer{
    
    // 1.与服务器通过三次握手建立连接
    NSString *host = @"10.5.5.9";
    int port = 8554;
    
    //创建一个socket对象
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //连接
    NSError *error = nil;
    [_socket connectToHost:host onPort:port withTimeout:10 error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

#pragma mark -socket的代理

#pragma mark 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    
    NSLog(@"%s  host = %@  port = %d",__func__,host, port);
}

#pragma mark 断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    
    if (err) {
        NSLog(@"连接失败  %@",err);
        
        [_socket connectToHost:@"10.5.5.9" onPort:80 withTimeout:10 error:nil];
    }else{
        NSLog(@"正常断开");
    }
}

#pragma mark 数据发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:-1 tag:tag];
}
#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@",__func__,receiverStr);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
