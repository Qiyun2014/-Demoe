//
//  IDYExternalAccessoryManager.h
//  GoPro_Demo
//
//  Created by qiyun on 16/11/22.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDYExternalAccessoryManager : NSObject

- (void)getAccessoryInfo:(void (^) (NSMutableString *info))information;

@end
