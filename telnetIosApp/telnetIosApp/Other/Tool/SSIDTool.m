//
//  SSIDTool.m
//  十六进制算法
//
//  Created by 姜易成 on 2017/8/22.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "SSIDTool.h"

static NSString* const base = @"g x v 6 z w p 9 a n 4 c d 3 e m q 5 t u y 2 b r 7 f s j 8 h k";
static NSString* const baseMac = @"001A69000000";
static NSString* const base_WiFi = @"q 5 t u y 8 g 6 p 7 f n 3 e m h 4 c d x v k w r s 9 a j 2 b z";

@implementation SSIDTool

+ (NSString *)createSSIDStrWithMacStr:(NSString*)macStr
{
    unsigned long num1 = strtoul([macStr UTF8String],0,16);
    unsigned long num2 = strtoul([baseMac UTF8String],0,16);
    num1 += 1;
    num1 = labs(num1-num2);
    
    //16进制转10进制
    NSString * temp10 = [NSString stringWithFormat:@"%lu",num1];
    //转成数字
    long cycleNumber = [temp10 longLongValue];
    NSArray* baseArray = [base componentsSeparatedByString:@" "];
    NSMutableArray* ssidArray = [[NSMutableArray alloc]init];
    NSInteger count = baseArray.count;
    
    for (int i = 0 ; i < 5; i++) {
        if (i == 0) {
            NSInteger ssid1 = cycleNumber%count;
            [ssidArray addObject:baseArray[ssid1]];
        }else{
            cycleNumber = cycleNumber/count;
            NSInteger ssid = cycleNumber%count;
            [ssidArray addObject:baseArray[ssid]];
        }
    }
    ssidArray = (NSMutableArray *)[[ssidArray reverseObjectEnumerator] allObjects];
    
    NSString* ssidStr = [ssidArray componentsJoinedByString:@""];
    NSString* result = [NSString stringWithFormat:@"jxtvnet-%@",ssidStr];
    return result;
}

+ (NSString*)creatPassWordStrWithMacStr:(NSString*)macStr
{
    unsigned long num1 = strtoul([macStr UTF8String],0,16);
    NSArray* base_wifi = [base_WiFi componentsSeparatedByString:@" "];
    NSString* passWd = @"";
    num1 += 1;
    // 转成十六进制
    NSString *macstring = [NSString stringWithFormat:@"%0lX",num1];
    if (macstring.length < 12) {
        macstring = [NSString stringWithFormat:@"00%@",macstring];
    }
    
    //2.判断输入的参数是否满足 MAC 地址正则表达式
    NSString *regex = @"[0-9|a-f|A-F]{12}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValid = [predicate evaluateWithObject:macstring];
    if (isValid) {
        NSMutableArray* charArr = [[NSMutableArray alloc]init];
        for (int i = 0; i < macstring.length; i++) {
            [charArr addObject:[macstring substringWithRange:NSMakeRange(i, 1)]];
        }
        for (int i = 0; i < charArr.count/2; i++) {
            unsigned long num1 = strtoul([charArr[i] UTF8String],0,16);
            unsigned long num2 = strtoul([charArr[charArr.count - i - 1] UTF8String],0,16);
            NSString *num1string = [NSString stringWithFormat:@"%lu",num1];
            NSString *num2string = [NSString stringWithFormat:@"%lu",num2];
            NSInteger temp = [num1string integerValue] + [num2string integerValue];
            passWd = [NSString stringWithFormat:@"%@%@",passWd,base_wifi[temp]];
        }
        unsigned long idx1 = strtoul([charArr[8] UTF8String],0,16);
        unsigned long idx2 = strtoul([charArr[10] UTF8String],0,16);
        NSInteger idx1Value = [[NSString stringWithFormat:@"%lu",idx1] integerValue];
        NSInteger idx2Value = [[NSString stringWithFormat:@"%lu",idx2] integerValue];
        passWd = [NSString stringWithFormat:@"%@%@%@%@",[passWd substringWithRange:NSMakeRange(0, 3)],base_wifi[idx1Value],[passWd substringWithRange:NSMakeRange(3, 3)],base_wifi[idx2Value]];
    }
    return passWd;
}

@end
