//
//  TelDataBase.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/29.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface TelDataBase : NSObject

@property (strong, nonatomic) FMDatabase *db;

+(TelDataBase*)shareTelDataBase;

//是否保存当前wifi
- (BOOL)isSaveWifiName:(NSString *)wifiName;

//查询ip数据
- (NSMutableArray *)queryIpListData;

//插入ip数据
- (BOOL)savehort:(NSString *)hort port:(NSString *)port wifiName:(NSString *)wifiName wifiPass:(NSString*)wifiPass;

//删除数据
- (BOOL)deleteDataWithWifiName:(NSString*)wifiName;

@end
