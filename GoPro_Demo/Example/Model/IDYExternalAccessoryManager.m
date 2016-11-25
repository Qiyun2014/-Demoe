
//
//  IDYExternalAccessoryManager.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/22.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "IDYExternalAccessoryManager.h"
#import <ExternalAccessory/ExternalAccessory.h>

@interface IDYExternalAccessoryManager () <NSStreamDelegate>

@property (nonatomic, copy) NSInputStream   *inputStream;
@property (nonatomic, copy) NSOutputStream  *outputStream;

@end

@implementation IDYExternalAccessoryManager

- (id)init{
    
    if (self == [super init]) {
        
        EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
        NSArray<EAAccessory *> *accessArr = [manager connectedAccessories];
        if (accessArr.firstObject) {
            EASession *session = [[EASession alloc] initWithAccessory:accessArr.firstObject forProtocol:@"com.douyu.one.protocol"];
            if (!session) return nil;
            
            _inputStream = [session inputStream];
            if (!_inputStream) {
                // LOG inputStream = null
            }
            _inputStream.delegate = self;
            [_inputStream open];
        }
    }
    return self;
}


#pragma mark    -   lazy loading

- (NSInputStream *)inputStream{
    
    if (![_inputStream hasBytesAvailable]) {
        
        _inputStream = [[NSInputStream alloc] initWithFileAtPath:@""];
        [_inputStream setDelegate:self];
        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [_inputStream open];
    }
    return _inputStream;
}


#pragma mark    -   NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    // LOG stream & event code
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            // 开始读取
            break;
        case NSStreamEventHasBytesAvailable:
            // 获取可读数据大小，读取流才有效。
        {
            uint8_t buf[1024];
            unsigned int len = 0;
            len = (unsigned int)[(NSInputStream *)aStream read:buf maxLength:1024];
            if(len) {
                //[_data appendBytes:(const void *)buf length:len];
                // bytesRead is an instance variable of type NSNumber.
                //[bytesRead setIntValue:[bytesRead intValue]+len];
            } else {
                NSLog(@"no buffer!");
            }
            break;
        }
            break;
        case NSStreamEventHasSpaceAvailable:
            // 获取可写空间大小，写入流才有效。
            break;
        case NSStreamEventErrorOccurred:
            // 出错处理
            break;
        case NSStreamEventEndEncountered:
            // 读取结束
        {
            [_inputStream close];
            [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            _inputStream = nil; // stream is ivar, so reinit it
            break;
        }
            break;
    }
}


- (void)getAccessoryInfo:(void (^) (NSMutableString *info))information{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableString *info = [[NSMutableString alloc] initWithCapacity:1024];
        EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];
        NSArray<EAAccessory *> *accessArr = [manager connectedAccessories];
        for (EAAccessory *access in accessArr) {
            for (NSString *proStr in access.protocolStrings) {
                [info appendFormat:@"protocolString = %@\n", proStr];
            }
            [info appendFormat:@"\n"];
            [info appendFormat:@"manufacturer = %@\n", access.manufacturer];
            [info appendFormat:@"name = %@\n", access.name];
            [info appendFormat:@"modelNumber = %@\n", access.modelNumber];
            [info appendFormat:@"serialNumber = %@\n", access.serialNumber];
            [info appendFormat:@"firmwareRevision = %@\n", access.firmwareRevision];
            [info appendFormat:@"hardwareRevision = %@\n", access.hardwareRevision];
            [info appendFormat:@"dockType = %@\n", access.dockType];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (information) information(info);
        });
    });
}

@end
