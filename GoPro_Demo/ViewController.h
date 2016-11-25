//
//  ViewController.h
//  GoPro_Demo
//
//  Created by qiyun on 16/11/9.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GoProCommandSetting) {
    
    GoProCommandSettingRestart = 0,
    GoProCommandSettingVersion,
    GoProCommandSettingMediaList,           /* sd卡媒体列表 */
    GoProCommandSettingMainDirectory,       /* sd卡主目录 */
    GoProCommandSettingDeviceName,          /* 设置设备名称 */
    GoProCommandSettingWifiAndPassword,     /* wifi和密码设置 */
    
    GoProCommandSettingFormat               /* 格式化sd卡 */
};



//Transport
//Stream header
typedef struct TS_header
{
    unsigned sync_byte                       :8;      //同步字节，固定为0x47 ，表示后面的是一个TS分组，当然，后面包中的数据是不会出现0x47的
    unsigned transport_error_indicator       :1;      //传输错误标志位，一般传输错误的话就不会处理这个包了
    unsigned payload_unit_start_indicator    :1;      //有效负载的开始标志，根据后面有效负载的内容不同功能也不同 payload_unit_start_indicator为1时，在前4个字节之后会有一个调整字节，它的数值决定了负载内容的具体开始位置。
    unsigned transport_priority              :1;      //传输优先级位，1表示高优先级
    unsigned PID                             :13;     //有效负载数据的类型
    unsigned transport_scrambling_control    :2;      //加密标志位,00表示未加密
    unsigned adaption_field_control          :2;      //调整字段控制,。01仅含有效负载，10仅含调整字段，11含有调整字段和有效负载。为00的话解码器不进行处理。
    unsigned continuity_counter              :4;      //一个4bit的计数器，范围0-15
}
TS_header;

//特殊参数说明：
//sync_byte：0x47
//payload_unit_start_indicator：0x01表示含有PSI或者PES头
//PID：0x0表示后面负载内容为PAT，不同的PID表示不同的负载
//adaption_field_control：
//
//0x0: // reserved for future use by ISO/IEC
//0x1: // 无调整字段，仅含有效负载
//0x2: // 仅含调整字段，无有效负载
//0x3: // 调整字段后含有效负载

//Parse TS header
int Parse_TS_header(unsigned char *pTSBuf,  TS_header *pheader){
    
    pheader->sync_byte = pTSBuf[0];
    if (pheader->sync_byte != 0x47) return -1;
    
    pheader->transport_error_indicator = pTSBuf[1] >> 7;
    pheader->payload_unit_start_indicator = pTSBuf[1] >> 6 & 0x01;
    pheader->transport_priority = pTSBuf[1] >> 5 & 0x01;
    pheader->PID = (pTSBuf[1] & 0x1F) << 8 | pTSBuf[2];
    pheader->transport_scrambling_control = pTSBuf[3] >> 6;
    pheader->adaption_field_control = pTSBuf[3] >> 4 & 0x03;
    pheader->continuity_counter = pTSBuf[3] & 0x0F;
    
    return 0;
}

@interface ViewController : UIViewController


@end

