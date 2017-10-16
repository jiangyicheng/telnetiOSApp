//
//  SSIDTool.h
//  十六进制算法
//
//  Created by 姜易成 on 2017/8/22.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSIDTool : NSObject

+ (NSString *)createSSIDStrWithMacStr:(NSString*)macStr;

+ (NSString*)creatPassWordStrWithMacStr:(NSString*)macStr;

@end
