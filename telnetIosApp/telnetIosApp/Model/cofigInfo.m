//
//  cofigInfo.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/30.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "cofigInfo.h"

@implementation cofigInfo

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static cofigInfo *shareInstance = nil;
    dispatch_once(&token, ^{
        shareInstance = [[cofigInfo alloc] init];
    });
    return shareInstance;
}

@end
