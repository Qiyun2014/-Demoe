//
//  IYNBlueBoothManager.m
//  GoPro_Demo
//
//  Created by qiyun on 16/11/20.
//  Copyright © 2016年 qiyun. All rights reserved.
//
//  example https://github.com/timburks/CBSample


#define kRestoreIdentifierKey @"8AC3A4F5-B202-4469-ABEF-FA4C8B57879A"
#define SAMPLE_SERVICE        @"00000000-0000-0000-0000-000000000001"
#define NOTIFY_CHARACTERISTIC @"00000000-0000-0000-0000-000000000002"
#define WRITE_CHARACTERISTIC  @"00000000-0000-0000-0000-000000000003"

#import "IYNBlueToothManager.h"

@interface IYNBlueToothManager ()<CBPeripheralManagerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

// 附近的设备管理器
@property (nonatomic, strong) CBPeripheralManager   *peripheralManager;

// 对接设备管理器
@property (nonatomic, strong) CBCentralManager      *centralManager;

// 外围设备列表
@property (nonatomic, strong) NSMutableArray        *peripherals;

@end


@implementation IYNBlueToothManager{
    
    /* 在peripheralManager初始化中，需要给定当前线程，如果为空，则默认为主线程队列 */
    dispatch_queue_t    _serialQueue;
}

- (id)init{
    
    if (self == [super init]) {
        
        _serialQueue = dispatch_queue_create("com.douyu.blueToothManager", nil);
        
        self.peripherals = [NSMutableArray array];
        
        switch ([CBPeripheralManager authorizationStatus]) {
                
            case CBPeripheralManagerAuthorizationStatusNotDetermined:       /* 用户未操作授权 */
                NSLog(@"等待用户授权");
                break;
                
            case CBPeripheralManagerAuthorizationStatusRestricted:
                NSLog(@"服务受限，需要开启权限");
                break;
                
            case CBPeripheralManagerAuthorizationStatusDenied:
                NSLog(@"用户拒绝使用蓝牙服务");
                break;
                
            case CBPeripheralManagerAuthorizationStatusAuthorized:
                NSLog(@"用户同意使用蓝牙");
            {
                /* 中央设备初始化  可选参数optionsios7之后支持使用 */
                self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                           queue:_serialQueue
                                                                         options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES,     /* 电量警告 */
                                                                                   CBPeripheralManagerRestoredStateServicesKey : @YES}];  /* 蓝牙重连状态恢复 */
                
                /* 可选参数optionsios7之后支持使用 */
                self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self
                                                                                 queue:_serialQueue
                                                                               options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES,     /* 电量警告 */
                                                                                         CBPeripheralManagerRestoredStateServicesKey : @YES}];  /* 蓝牙重连状态恢复 */
                /* latency 设置通信状态和电池使用平衡使用 */
                //[self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyMedium forCentral:nil];
                
            }
                break;
                
            default:
                break;
        }
        
        
    }
    return self;
}




#pragma mark    -   CBCentralManagerDelegate



/*! @required
 *  @method centralManagerDidUpdateState:
 *
 *  @param central  The central manager whose state has changed.
 *
 *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
 *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
 *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
 *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
 *                  manager become invalid and must be retrieved or discovered again.
 *
 *  @see            state
 *
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
            
        case CBManagerStateUnknown:
            NSLog(@"默认状态");
            break;
            
        case CBManagerStateResetting:
            NSLog(@"重置蓝牙");
            break;
            
        case CBManagerStateUnsupported:
            NSLog(@"不支持蓝牙服务");
            break;
            
        case CBManagerStateUnauthorized:
            NSLog(@"没有授权");
            break;
            
        case CBManagerStatePoweredOff:
            NSLog(@"关闭附近搜索");
            break;
            
        case CBManagerStatePoweredOn:
            NSLog(@"开启附近搜索");
            [_centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
            
        default:
            break;
    }
}



/*!
 *  @method centralManager:willRestoreState:
 *
 *  @param central      The central manager providing this information.
 *  @param dict			A dictionary containing information about <i>central</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *						Bluetooth system.
 *
 *  @seealso            CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso            CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso            CBCentralManagerRestoredStateScanOptionsKey;
 *
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict{
    
    /* 本地附近连接设备存储信息 */
    NSString *localDeviceInfo = dict[CBPeripheralManagerRestoredStateServicesKey];
    NSLog(@"localDeviceInfo = %@",localDeviceInfo);
    
    /* 广告数据 */
    NSString *advertisementInfo = dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
    NSLog(@"advertisementInfo = %@",advertisementInfo);
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
 *								was not available.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
 *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    // RSSI 接收信号强度指示器  127表示信号不可用
    NSLog(@"周边设备名  %@   identifier = %@",peripheral.name,peripheral.identifier.UUIDString);
    
    switch (peripheral.state) {
            
        case CBPeripheralStateDisconnected:
            NSLog(@"断开连接");
            break;
            
        case CBPeripheralStateConnecting:
            NSLog(@"连接中");
            break;
            
        case CBPeripheralStateConnected:
            NSLog(@"连接成功");
            break;
            
        default:
            break;
    }
    
    NSLog(@"（广告）扫描设备信息数据  %@",advertisementData);
    NSLog(@"信号强度  %f", [RSSI floatValue]);
    
    //停止扫描
    [self.centralManager stopScan];
    
    //连接外围设备
    if (peripheral) {
        
        //添加保存外围设备，注意如果这里不保存外围设备（或者说peripheral没有一个强引用，无法到达连接成功（或失败）的代理方法，因为在此方法调用完就会被销毁
        if(![self.peripherals containsObject:peripheral]){
            [self.peripherals addObject:peripheral];
        }
        NSLog(@"开始连接外围设备...%@",peripheral.name);
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    /* 外围设备列表 */
    [peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSLog(@"所有的外围设备  %@",obj.peripheral.name);
    }];
    
    //设置外围设备的代理
    peripheral.delegate = self;
    
    //外围设备开始寻找服务
    [peripheral discoverServices:@[kRestoreIdentifierKey]];
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
    NSLog(@"连接外围设备失败!");
    
    [peripheral setDelegate:nil];
    peripheral = nil;
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
 *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
    /* 断开重连 */
    //[central connectPeripheral:peripheral options:@{}];
    
    NSLog(@"centralManager:didDisconnectPeripheral:%@ error:%@", peripheral, [error localizedDescription]);
    [peripheral setDelegate:nil];
    peripheral = nil;
}






#pragma mark    -   CBPeripheralManagerDelegate



/*! @required
 *  @method peripheralManagerDidUpdateState:
 *
 *  @param peripheral   The peripheral manager whose state has changed.
 *
 *  @discussion         Invoked whenever the peripheral manager's state has been updated. Commands should only be issued when the state is
 *                      <code>CBPeripheralManagerStatePoweredOn</code>. A state below <code>CBPeripheralManagerStatePoweredOn</code>
 *                      implies that advertisement has paused and any connected centrals have been disconnected. If the state moves below
 *                      <code>CBPeripheralManagerStatePoweredOff</code>, advertisement is stopped and must be explicitly restarted, and the
 *                      local database is cleared and all services must be re-added.
 *
 *  @see                state
 *
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    switch (peripheral.state) {
            
        case CBManagerStateUnknown:
            NSLog(@"默认状态");
            break;
            
        case CBManagerStateResetting:
            NSLog(@"重置蓝牙");
            break;
            
        case CBManagerStateUnsupported:
            NSLog(@"不支持蓝牙服务");
            break;
            
        case CBManagerStateUnauthorized:
            NSLog(@"没有授权");
            break;
            
        case CBManagerStatePoweredOff:
            NSLog(@"关闭附近搜索");
            break;
            
        case CBManagerStatePoweredOn:
            NSLog(@"开启附近搜索");
            break;
            
        default:
            break;
    }
}



/*!
 *  @method peripheralManager:willRestoreState:
 *
 *  @param peripheral	The peripheral manager providing this information.
 *  @param dict			A dictionary containing information about <i>peripheral</i> that was preserved by the system at the time the app was terminated.
 *
 *  @discussion			For apps that opt-in to state preservation and restoration, this is the first method invoked when your app is relaunched into
 *						the background to complete some Bluetooth-related task. Use this method to synchronize your app's state with the state of the
 *						Bluetooth system.
 *
 *  @seealso            CBPeripheralManagerRestoredStateServicesKey;
 *  @seealso            CBPeripheralManagerRestoredStateAdvertisementDataKey;
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary<NSString *, id> *)dict{
    
    /* 本地附近连接设备存储信息 */
    NSString *localDeviceInfo = dict[CBPeripheralManagerRestoredStateServicesKey];
    NSLog(@"localDeviceInfo = %@",localDeviceInfo);
    
    /* 广告数据 */
    NSString *advertisementInfo = dict[CBPeripheralManagerRestoredStateAdvertisementDataKey];
    NSLog(@"advertisementInfo = %@",advertisementInfo);
}



/*!
 *  @method peripheralManagerDidStartAdvertising:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
 *                      not be started, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(nullable NSError *)error{
    
    // peripheral.isAdvertising  is yes
    
    /* 开始和停止
     - (void)startAdvertising:(nullable NSDictionary<NSString *, id> *)advertisementData;
     - (void)stopAdvertising;
     */
    NSLog(@"使用广告连接");
}

/*!
 *  @method peripheralManager:didAddService:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param service      The service that was added to the local database.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
 *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheralManager:central:didSubscribeToCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were enabled.
 *
 *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
 *                          It should be used as a cue to start sending updates as the characteristic value changes.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    
    
}

/*!
 *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were disabled.
 *
 *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    
    
}

/*!
 *  @method peripheralManager:didReceiveReadRequest:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param request      A <code>CBATTRequest</code> object.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    
    
}

/*!
 *  @method peripheralManager:didReceiveWriteRequests:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
 *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
 *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray<CBATTRequest *> *)requests{
    
    
}

/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    
    
}


#pragma mark    -   CBPeripheralDelegate

/*!
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0){
    
    
}

/*!
 *  @method peripheral:didModifyServices:
 *
 *  @param peripheral			The peripheral providing this update.
 *  @param invalidatedServices	The services that have been invalidated
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
 *						At this point, the designated <code>CBService</code> objects have been invalidated.
 *						Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices NS_AVAILABLE(NA, 7_0){
    
    
}

/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 *
 *  @deprecated			Use {@link peripheral:didReadRSSI:error:} instead.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error NS_DEPRECATED(NA, NA, 5_0, 8_0){
    
    
}

/*!
 *  @method peripheral:didReadRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *  @param RSSI			The current RSSI of the link.
 *  @param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error NS_AVAILABLE(NA, 8_0){
    
    
}

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    
    NSLog(@"peripheral:%@ didDiscoverServices:%@", peripheral, [error localizedDescription]);
    
    for (CBService *service in peripheral.services) {
        
        NSLog(@"Service found with UUID: %@", service.UUID);
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:SAMPLE_SERVICE]]) {
            
            NSLog(@"SAMPLE SERVICE FOUND");
        }
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    
    NSLog(@"peripheral:%@ didDiscoverCharacteristicsForService:%@ error:%@",
          peripheral, service, [error localizedDescription]);
    
    if (error) {
        //设备特征
        NSLog(@"Discovered characteristics for %@ with error: %@",
              service.UUID, [error localizedDescription]);
        return;
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:SAMPLE_SERVICE]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"discovered characteristic %@", characteristic.UUID);
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC]]) {
                NSLog(@"Found Notify Characteristic %@", characteristic);
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
            
            else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:WRITE_CHARACTERISTIC]]) {
                NSLog(@"Found Writable Characteristic %@", characteristic);
                [peripheral writeValue:[@"hello" dataUsingEncoding:NSUTF8StringEncoding]
                          forCharacteristic:characteristic
                                       type:CBCharacteristicWriteWithResponse];
            }
        }
    }
#ifdef HUH
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:CBUUIDGenericAccessProfileString]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"discovered generic characteristic %@", characteristic.UUID);
            
            /* Read device name */
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:CBUUIDDeviceNameString]]) {
                [self.peripheral readValueForCharacteristic:characteristic];
                NSLog(@"Found a Device Name Characteristic - Read device name");
            }
        }
    }
#endif
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:@"A696CB2B-F3A4-4240-B74D-C457C253857B"]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"discovered characteristic %@", characteristic.UUID);
            
            
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AEDA780E-1CCF-4B85-BCA0-3484F295D031"]]) {
                NSLog(@"Found Writable Characteristic %@", characteristic);
                
                unsigned char byte = 0x0F;
                NSData *data = [NSData dataWithBytes:&byte length:1];
                NSLog(@"Writing %@", data);
                [peripheral writeValue:data
                          forCharacteristic:characteristic
                                       type:CBCharacteristicWriteWithResponse];
                
                [peripheral writeValue:[[NSData alloc] initWithBase64EncodedString:@"O(∩_∩)O哈哈哈~" options:NSDataBase64DecodingIgnoreUnknownCharacters]
                     forCharacteristic:characteristic
                                  type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    
    else {
        NSLog(@"unknown service discovery %@", service.UUID);
    }

}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    NSLog(@"peripheral:%@ didUpdateValueForCharacteristic:%@ error:%@",
          peripheral, characteristic, error);
    
    if (error) {
        NSLog(@"Error updating value for characteristic %@ error: %@",
              characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC]]) {
        
        NSString *chunk = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"chunk = %@", chunk);
        
        if ([chunk isEqualToString:@"ENDVAL"]) {
            // let's disconnect
            NSLog(@"disconnecting");
        }
    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    
    
}

/*!
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error{
    
    
}

@end
