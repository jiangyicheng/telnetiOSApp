//
//  TelDataBase.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/29.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "TelDataBase.h"
#import "ipModel.h"
#define IPLISTNAME @"ipdatalist"

@implementation TelDataBase

+(TelDataBase*)shareTelDataBase
{
    static TelDataBase* telDatabase = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        telDatabase = [[TelDataBase alloc]init];
    });
    return telDatabase;
}

- (FMDatabase *)db{
    if (!_db) {
        _db = [FMDatabase databaseWithPath:[self getPathOfFmdb]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:[self getPathOfFmdb]]) {
            NSLog(@"还未创建数据库，现在正在创建数据库");
            if ([_db open]) {
                
//                NSString *creatIpListStr = [NSString stringWithFormat:@"CREATE TABLE %@ (host text, port text, wifiName text ,wifiPass text ,userName text ,password text ,Service1Enable integer , Service1VlanId integer , Service1VlanPri integer , Service1Mode integer , Service1Portmap text)", IPLISTNAME];
                NSString *creatIpListStr = [NSString stringWithFormat:@"CREATE TABLE %@ (host text, port text, wifiName text ,wifiPass text )", IPLISTNAME];
                [_db executeUpdate:creatIpListStr];
                
                BOOL res = [_db executeUpdate:creatIpListStr];
                
                if (!res) {
                    NSLog(@"error when insert db table");
                } else {
                    NSLog(@"success to insert db table");
                }
                
            }else{
                NSLog(@"database open error");
            }
        }
    }
    return _db;
}

//是否保存当前wifi
- (BOOL)isSaveWifiName:(NSString *)wifiName{
    
    NSMutableArray *ipArr = [[TelDataBase shareTelDataBase]queryIpListData];
    NSMutableArray *idArr = [[NSMutableArray alloc]initWithCapacity:0];
    
    if ([ipArr count] > 0) {
        for (int i = 0; i< [ipArr count]; i ++) {
            ipModel* ip = [ipArr objectAtIndex:i];
            NSString *wifiStr = ip.wifiName;
            [idArr addObject:wifiStr];
        }
        if ([idArr containsObject:wifiName]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    
}

//查询ip数据
- (NSMutableArray *)queryIpListData
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self.db open];
    NSString *querySql =[NSString stringWithFormat:@"select * from '%@' ",IPLISTNAME];
    FMResultSet *resultSet = [self.db executeQuery:querySql];
    
    // 2.遍历结果
    while ([resultSet next]) {
        
        NSString *host = [resultSet stringForColumn:@"host"];
        NSString *port = [resultSet stringForColumn:@"port"];
        NSString* wifiName = [resultSet stringForColumn:@"wifiName"];
        NSString* wifiPass = [resultSet stringForColumn:@"wifiPass"];
//        NSString* userName = [resultSet stringForColumn:@"userName"];
//        NSString* password = [resultSet stringForColumn:@"password"];
//        NSString* Service1Enable = [resultSet stringForColumn:@"Service1Enable"];
//        NSString* Service1VlanId = [resultSet stringForColumn:@"Service1VlanId"];
//        NSString* Service1Mode = [resultSet stringForColumn:@"Service1Mode"];
//        NSString* Service1Portmap = [resultSet stringForColumn:@"Service1Portmap"];
        
        ipModel* ip = [[ipModel alloc]init];
        ip.host = host;
        ip.port = port;
        ip.wifiName = wifiName;
        ip.wifiPass = wifiPass;
        [array addObject:ip];
        
    }
    
    [self.db close];
    return array;
    
}

//插入ip数据
- (BOOL)savehort:(NSString *)hort port:(NSString *)port wifiName:(NSString *)wifiName wifiPass:(NSString*)wifiPass{
    if ([self.db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                              @"INSERT INTO '%@' (host, port, wifiName, wifiPass) VALUES ('%@', '%@', '%@', '%@')",
                              IPLISTNAME, hort, port, wifiName, wifiPass];
        BOOL res = [self.db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
        [self.db close];
        return res;
    }
    return NO;
}

//删除数据
- (BOOL)deleteDataWithWifiName:(NSString*)wifiName
{
    [self.db open];
    NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where wifiName = '%@' ",IPLISTNAME,wifiName];

    BOOL result = [self.db executeUpdate:deleteSql];

    if(result){
        NSLog(@"删除数据成功");
    }else{
        NSLog(@"删除数据失败");
    }
    [self.db close];
    return result;
}

-(NSString*)getPathOfFmdb{
    //获取路径数组
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documents = [paths objectAtIndex:0];
    //进行路径的拼接
        NSLog(@"%@",paths[0]);
    return [documents stringByAppendingPathComponent:@"ipdataList.db"];
    
}

@end
