//
//  SocketProtocol.m
//  YongShang
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 姜易成. All rights reserved.
//

#import "YSSocketProtocol.h"
#import<CommonCrypto/CommonDigest.h>
#import <SVProgressHUD.h>
#import "ConfigTableViewController.h"
#import "cofigInfo.h"
#import "FTPManager.h"
#import "XMFTPServer.h"
#import "appColor.h"

//#define HOST @"10.58.201.124"
//#define PORT 1234 yst.cjtc.net.cn   118.178.58.178   118.178.135.12

#define HOST @"123.206.125.221"
#define PORT 8062
#define FTPURL        @"192.168.1.70"
#define FTPUsername   @"abc123"
#define FTPPSW        @"abc123"

@interface YSSocketProtocol ()<FTPManagerDelegate>
{
    BOOL version;
    BOOL versionDate;
    BOOL Service1Enable;
    BOOL Service1name;
    BOOL Service1Servicelist;
    BOOL Service1VlanId;
    BOOL Service1VlanPri;
    BOOL Service1Mode;
    BOOL Service1Portmap;
    BOOL wan_dhcp_option60_enabled;
    BOOL wan_vendor;
    BOOL wanConnectionMode;
    BOOL wan_ipaddr;
    BOOL wan_netmask;
    BOOL wan_gateway;
    BOOL wan_primary_dns;
    BOOL wan_secondary_dns;
    BOOL wan_pppoe_user;
    BOOL wan_pppoe_pass;
    BOOL pppoeerrcode;
    BOOL getSSID;
    BOOL getWPAPSK1;
    FMServer* server;
    FTPManager* man;
    NSString* filePath;  // 上传文件的路径
    BOOL succeeded;  // 记录传输结果是否成功
    NSTimer* progTimer;
    
}
@property (nonatomic, strong) XMFTPServer *ftpServer;
@end

@implementation YSSocketProtocol


+ (YSSocketProtocol *)shareSocketProtocol{
    
    static YSSocketProtocol *socketPtl = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketPtl = [[YSSocketProtocol alloc]init];
    });
    return socketPtl;
}

- (GCDAsyncSocket *)asyncSocket{
    if (_asyncSocket == nil) {
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return _asyncSocket;
}

#pragma mark - 配置FTP



#pragma mark - end



- (void)socketConnectWithHost:(NSString *)host andPort:(uint16_t)port{
    NSError *err = nil;
    if (![self.asyncSocket isConnected])
    {
        [self.asyncSocket connectToHost:host onPort:PORT withTimeout:30 error:&err];
//        [self.asyncSocket connectToHost:host onPort:PORT error:&err];
        [SVProgressHUD showWithStatus:@"正在连接..."];
        _isPush = YES;
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    }
}

-(BOOL)isConnect{
    if ([self.asyncSocket isConnected]) {
        return YES;
    }
    return NO;
}

-(void)disConnectToHost
{
    if ([self.asyncSocket isConnected]){
//        [self.asyncSocket setDelegate:nil];
        [self.asyncSocket disconnect];
        self.asyncSocket = nil;
    }
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket*)sock didConnectToHost:(NSString*)host port:(UInt16)port{
    [SVProgressHUD dismiss];
//    [SVProgressHUD showSuccessWithStatus:@"连接成功"];
    [self initBool];
    [_asyncSocket readDataWithTimeout:-1 tag:0];
    [_asyncSocket writeData:[@"admin\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:11];
}


- (void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)err{
    NSLog(@"连接失败--%@",err);
    [SVProgressHUD dismiss];
//    if (self.disConectType != 1) {
        [SVProgressHUD showErrorWithStatus:@"连接失败"];
//    }
    [self performSelectorOnMainThread:@selector(popLastPage) withObject:nil waitUntilDone:YES];
    
}
-(void)popLastPage
{
    UINavigationController* nav = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
    NSLog(@"%@",[nav class]);
    if ([nav.topViewController isKindOfClass:[ConfigTableViewController class]]) {
        [SVProgressHUD dismiss];
        dispatch_async(dispatch_get_main_queue(), ^{
            [nav popViewControllerAnimated:YES];
        });
    }
}

#pragma mark -
#pragma mark - WriteDataDelegate
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送成功");
    
}

#pragma mark -
#pragma mark - ReadDataDelegate

//此方法的第一次调用是已经连接上的方法调用的时候。会读取data，然后调用代理的此方法。此时tag就事上面的TAG_FIXED_LENGTH_HEADER，所以第一次执行读取header
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"result-%@",result);
    [_asyncSocket readDataWithTimeout:-1 tag:tag];
    [self getData:result andTag:tag];
}


-(void)updateDonfigData
{
    [self initBool];
    [self getData:@"BusyBox" andTag:10000];
}

-(void)pppoeerrcode
{
//    [self initBool];
    [_asyncSocket writeData:[@"web 2860 sys pppoeerrcode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}

BOOL isSendSuccess = NO;
-(void)setData
{
    [SVProgressHUD showWithStatus:@"正在提交..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1Enable] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1name] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1Servicelist] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1VlanId] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1VlanPri] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_Service1Portmap] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wanConnectionMode] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].setSSID] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].setWPAPSK1] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];

    if ([[cofigInfo sharedInstance].set_wanConnectionMode containsString:@"PPPOE"]) {
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_pppoe_user] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_pppoe_pass] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }else if ([[cofigInfo sharedInstance].set_wanConnectionMode containsString:@"STATIC"]){
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_ipaddr] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_netmask] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_gateway] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_primary_dns] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_secondary_dns] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }else if ([[cofigInfo sharedInstance].set_wanConnectionMode containsString:@"DHCP"]){
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_dhcp_option60_enabled] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [_asyncSocket writeData:[[self configString:[cofigInfo sharedInstance].set_wan_vendor] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    }
    
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns2 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns3 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns4 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns5 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns6 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns7 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns8 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [_asyncSocket writeData:[[self configString:@"nvram_set dhcpSecDns9 10.72.255.131"] dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_asyncSocket writeData:[@"/sbin/wan.sh stop 1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_asyncSocket writeData:[@"/sbin/lan.sh stop 1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_asyncSocket writeData:[@"/sbin/config_mstar_vconfig.sh stop wan 1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_asyncSocket writeData:[@"/sbin/lan.sh start 1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
//    [_asyncSocket writeData:[@"/sbin/nat.sh 1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    isSendSuccess = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:@"上传中..."];
    });
}

/**
 比较两个版本号的大小
 
 @param v1 第一个版本号
 @param v2 第二个版本号
 @return 版本号相等,返回0; v1小于v2,返回-1; 否则返回1.
 */
- (NSInteger)compareVersion:(NSString *)v1 to:(NSString *)v2 {
    // 都为空，相等，返回0
    if (!v1 && !v2) {
        return 0;
    }
    
    // v1为空，v2不为空，返回-1
    if (!v1 && v2) {
        return -1;
    }
    
    // v2为空，v1不为空，返回1
    if (v1 && !v2) {
        return 1;
    }
    
    // 获取版本号字段
    NSArray *v1Array = [v1 componentsSeparatedByString:@"."];
    NSArray *v2Array = [v2 componentsSeparatedByString:@"."];
    // 取字段最少的，进行循环比较
    NSInteger smallCount = (v1Array.count > v2Array.count) ? v2Array.count : v1Array.count;
    
    for (int i = 0; i < smallCount; i++) {
        NSInteger value1 = [[v1Array objectAtIndex:i] integerValue];
        NSInteger value2 = [[v2Array objectAtIndex:i] integerValue];
        if (value1 > value2) {
            // v1版本字段大于v2版本字段，返回1
            return 1;
        } else if (value1 < value2) {
            // v2版本字段大于v1版本字段，返回-1
            return -1;
        }
        
        // 版本相等，继续循环。
    }
    
    // 版本可比较字段相等，则字段多的版本高于字段少的版本。
    if (v1Array.count > v2Array.count) {
        return 1;
    } else if (v1Array.count < v2Array.count) {
        return -1;
    } else {
        return 0;
    }
    
    return 0;
}
//是否需要升级
-(BOOL)isNeedUpdateVersion{
    NSInteger result = [self compareVersion:[cofigInfo sharedInstance].version to:@"1.10.2.1"];
    if (result == -1) {//1.10.2.1  版本大
        return YES;
    }else{
        return NO;
    }
}

BOOL isPPPOE = NO;
BOOL isDhcpSecDns9Return = NO;
BOOL isNeedUpdate = NO;
-(void)getData:(NSString*)result andTag:(long)tag
{
    if ([result containsString:@"dhcpSecDns9"]  && [result containsString:@"#"]) {
        isDhcpSecDns9Return = YES;
    }
    if ([result containsString:@"nvram_set"]) {
        return;
    }
    if ([result containsString:@"web 2860"]) {
        isPPPOE = YES;
        return;
    }
    if (isPPPOE) {
        [cofigInfo sharedInstance].pppoeerrcode = result;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshErrorCode" object:nil];
        isPPPOE = NO;
        NSLog(@"pppoeerrcode----%@",[cofigInfo sharedInstance].pppoeerrcode);
        return;
    }
    if ([result containsString:@"Reset"]) {
        [SVProgressHUD showSuccessWithStatus:@"更新完成"];
        dispatch_async(dispatch_get_main_queue(), ^{
            UINavigationController* nav = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
            [nav popToRootViewControllerAnimated:YES];
        });
        return;
    }
    if ([result containsString:@"^"]) {
        NSLog(@"升级中");
    }

    if ([result isEqualToString:@"# "] && isSendSuccess && isDhcpSecDns9Return) {
        isSendSuccess = NO;
        isDhcpSecDns9Return = NO;
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"配置成功！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateDonfigData];
        });
        return;
    }else if([result isEqualToString:@"# "] && !isNeedUpdate){
        [SVProgressHUD dismiss];
        return;
    }else if ([result isEqualToString:@"# "] && isNeedUpdate){//正在升级
        return;
    }
    
    if ([result containsString:@"Password"]) {
        [_asyncSocket writeData:[@"1qaz2wsx\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:10];
    }else if ([result containsString:@"login"]){
        if (tag == 10) {
            return;
        }
        [_asyncSocket writeData:[@"admin\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:11];
    }else if ([result containsString:@"BusyBox"]){
        [SVProgressHUD showWithStatus:@"正在检测当前版本..."];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [_asyncSocket writeData:[@"cat /bstar/version\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:11];
//        [_asyncSocket writeData:[@"nvram_get Service1Enable\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
    }
    else if ([result containsString:@"cat /bstar/version"] && ![result containsString:@"#"]){
        version = YES;
        return;
    }else if ([result containsString:@"cat /bstar/version"]){
        result = [self dealString:result andReplaceString:@"cat /bstar/version"];
        [cofigInfo sharedInstance].version = result;
        if ([self isNeedUpdateVersion]) {
            [SVProgressHUD showWithStatus:@"正在升级..."];
//            [_asyncSocket writeData:[@"cd /tmp/\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
            isNeedUpdate = YES;
            NSString *ip = [XMFTPHelper localIPAddress];
            NSString* updatestr = [NSString stringWithFormat:@"ftpget -u 123 -p 123 %@:23023 /tmp/upgrade %@.upf\n",ip,updateHigeFileName];
            NSLog(@"updatestr--%@",updatestr);
            //@"ftpget -u 123 -p 123 192.168.1.70:23023 /tmp/upgrade  WiFi_V1R10B2F1_20170922_bd_20171014_HighVer_8M.upf\n"
            [_asyncSocket writeData:[updatestr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_asyncSocket writeData:[@"ls /tmp/upgrade\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
                [_asyncSocket writeData:[@"upf_upgrade -k /tmp/upgrade\r" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
            });
            NSLog(@"开始升级");
        }else{
            NSLog(@"不需要升级");
            [_asyncSocket writeData:[@"nvram_get Service1Enable\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
        }
        return;
    }
//    else if ([result containsString:@"cat /tmp/bd"] && ![result containsString:@"#"]){
//        versionDate = YES;
//        return;
//    }else if ([result containsString:@"cat /tmp/bd"]){
//        result = [self dealString:result andReplaceString:@"cat /tmp/bd"];
//        [cofigInfo sharedInstance].versionDate = result;
////        [_asyncSocket writeData:[@"cat /tmp/bd\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:19];
//        NSLog(@"versiondate----%@",result);
//        if ([self isNeedUpdateVersion]) {
//            [SVProgressHUD showWithStatus:@"正在升级..."];
//            NSLog(@"开始升级");
//        }else{
//            NSLog(@"不需要升级");
//            [SVProgressHUD showWithStatus:@"正在刷新..."];
//            [_asyncSocket writeData:[@"nvram_get Service1Enable\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
//        }
//        return;
//    }
    else if ([result containsString:@"nvram_get Service1Enable"] && ![result containsString:@"#"]){
        Service1Enable = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1Enable"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1Enable"];
        [cofigInfo sharedInstance].Service1Enable = result;
        [_asyncSocket writeData:[@"nvram_get Service1name\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1name"] && ![result containsString:@"#"]){
        Service1name = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1name"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1name"];
        [cofigInfo sharedInstance].Service1name = result;
        [_asyncSocket writeData:[@"nvram_get Service1Servicelist\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1Servicelist"] && ![result containsString:@"#"]){
        Service1Servicelist = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1Servicelist"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1Servicelist"];
        [cofigInfo sharedInstance].Service1Servicelist = result;
        [_asyncSocket writeData:[@"nvram_get Service1VlanId\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1VlanId"] && ![result containsString:@"#"]){
        Service1VlanId = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1VlanId"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1VlanId"];
        [cofigInfo sharedInstance].Service1VlanId = result;
        [_asyncSocket writeData:[@"nvram_get Service1VlanPri\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1VlanPri"] && ![result containsString:@"#"]){
        Service1VlanPri = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1VlanPri"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1VlanPri"];
        [cofigInfo sharedInstance].Service1VlanPri = result;
        [_asyncSocket writeData:[@"nvram_get Service1Mode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1Mode"] && ![result containsString:@"#"]){
        Service1Mode = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1Mode"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1Mode"];
        [cofigInfo sharedInstance].Service1Mode = result;
        [_asyncSocket writeData:[@"nvram_get Service1Portmap\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get Service1Portmap"] && ![result containsString:@"#"]){
        Service1Portmap = YES;
        return;
    }
    else if ([result containsString:@"nvram_get Service1Portmap"]){
        result = [self dealString:result andReplaceString:@"nvram_get Service1Portmap"];
        [cofigInfo sharedInstance].Service1Portmap = result;
        [_asyncSocket writeData:[@"nvram_get wan_dhcp_option60_enabled\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_dhcp_option60_enabled"] && ![result containsString:@"#"]){
        wan_dhcp_option60_enabled = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_dhcp_option60_enabled"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_dhcp_option60_enabled"];
        [cofigInfo sharedInstance].wan_dhcp_option60_enabled = result;
        [_asyncSocket writeData:[@"nvram_get wan_vendor\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_vendor"] && ![result containsString:@"#"]){
        wan_vendor = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_vendor"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_vendor"];
        [cofigInfo sharedInstance].wan_vendor = result;
        [_asyncSocket writeData:[@"nvram_get wanConnectionMode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wanConnectionMode"] && ![result containsString:@"#"]){
        wanConnectionMode = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wanConnectionMode"]){
        result = [self dealString:result andReplaceString:@"nvram_get wanConnectionMode"];
        [cofigInfo sharedInstance].wanConnectionMode = result;
        if (![result containsString:@"PPPOE"] || ![result containsString:@"DHCP"] || ![result containsString:@"STATIC"] ) {
//            [_asyncSocket writeData:[@"nvram_get wanConnectionMode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
            [self updateDonfigData];
        }else{
            [_asyncSocket writeData:[@"nvram_get wan_ipaddr\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        }
        
        return;
    }
    else if ([result containsString:@"nvram_get wan_ipaddr"] && ![result containsString:@"#"]){
        wan_ipaddr = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_ipaddr"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_ipaddr"];
        [cofigInfo sharedInstance].wan_ipaddr = result;
        [_asyncSocket writeData:[@"nvram_get wan_netmask\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_netmask"] && ![result containsString:@"#"]){
        wan_netmask = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_netmask"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_netmask"];
        [cofigInfo sharedInstance].wan_netmask = result;
        [_asyncSocket writeData:[@"nvram_get wan_gateway\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_gateway"] && ![result containsString:@"#"]){
        wan_gateway = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_gateway"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_gateway"];
        [cofigInfo sharedInstance].wan_gateway = result;
        [_asyncSocket writeData:[@"nvram_get wan_primary_dns\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_primary_dns"] && ![result containsString:@"#"]){
        wan_primary_dns = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_primary_dns"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_primary_dns"];
        [cofigInfo sharedInstance].wan_primary_dns = result;
        [_asyncSocket writeData:[@"nvram_get wan_secondary_dns\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_secondary_dns"] && ![result containsString:@"#"]){
        wan_secondary_dns = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_secondary_dns"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_secondary_dns"];
        [cofigInfo sharedInstance].wan_secondary_dns = result;
        [_asyncSocket writeData:[@"nvram_get wan_pppoe_user\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_pppoe_user"] && ![result containsString:@"#"]){
        wan_pppoe_user = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_pppoe_user"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_pppoe_user"];
        [cofigInfo sharedInstance].wan_pppoe_user = result;
//        [_asyncSocket writeData:[@"nvram_get wan_pppoe_pass\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        [_asyncSocket writeData:[@"nvram_get SSID1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        
        return;
    }
    //新增SSID WPAP
    else if ([result containsString:@"nvram_get SSID1"] && ![result containsString:@"#"]){
        getSSID = YES;
        return;
    }
    else if ([result containsString:@"nvram_get SSID1"]){
        result = [self dealString:result andReplaceString:@"nvram_get SSID1"];
        [cofigInfo sharedInstance].getSSID = result;
        [_asyncSocket writeData:[@"nvram_get WPAPSK1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get WPAPSK1"] && ![result containsString:@"#"]){
        getWPAPSK1 = YES;
        return;
    }
    else if ([result containsString:@"nvram_get WPAPSK1"]){
        result = [self dealString:result andReplaceString:@"nvram_get WPAPSK1"];
        [cofigInfo sharedInstance].getWPAPSK1 = result;
        [_asyncSocket writeData:[@"nvram_get wan_pppoe_pass\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
        return;
    }
    else if ([result containsString:@"nvram_get wan_pppoe_pass"] && ![result containsString:@"#"]){
        wan_pppoe_pass = YES;
        return;
    }
    else if ([result containsString:@"nvram_get wan_pppoe_pass"]){
        result = [self dealString:result andReplaceString:@"nvram_get wan_pppoe_pass"];
        [cofigInfo sharedInstance].wan_pppoe_pass = result;
        [self dealFinish];
        return;
    }
    
    result = [self dealString:result];
    if (version && !Service1Enable) {
        [cofigInfo sharedInstance].version = result;
        if ([self isNeedUpdateVersion]) {
            [SVProgressHUD showWithStatus:@"正在升级..."];
            NSLog(@"开始升级");
        }else{
            NSLog(@"不需要升级");
            [SVProgressHUD showWithStatus:@"正在刷新..."];
            [_asyncSocket writeData:[@"nvram_get Service1Enable\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:12];
        }
    }
    if (Service1Enable && !Service1name) {
        [cofigInfo sharedInstance].Service1Enable = result;
        NSLog(@"Service1Enable----%@",[cofigInfo sharedInstance].Service1Enable);
        [_asyncSocket writeData:[@"nvram_get Service1name\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:13];
    }else if (Service1name && !Service1Servicelist){
        [cofigInfo sharedInstance].Service1name = result;
        NSLog(@"Service1name----%@",[cofigInfo sharedInstance].Service1name);
        [_asyncSocket writeData:[@"nvram_get Service1Servicelist\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:14];
    }else if (Service1Servicelist && !Service1VlanId){
        [cofigInfo sharedInstance].Service1Servicelist = result;
        NSLog(@"Service1Servicelist----%@",[cofigInfo sharedInstance].Service1Servicelist);
        [_asyncSocket writeData:[@"nvram_get Service1VlanId\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:15];
    }else if (Service1VlanId && !Service1VlanPri){
        [cofigInfo sharedInstance].Service1VlanId = result;
        NSLog(@"Service1VlanId----%@",[cofigInfo sharedInstance].Service1VlanId);
        [_asyncSocket writeData:[@"nvram_get Service1VlanPri\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:16];
    }else if (Service1VlanPri && !Service1Mode){
        [cofigInfo sharedInstance].Service1VlanPri = result;
        NSLog(@"Service1VlanPri----%@",[cofigInfo sharedInstance].Service1VlanPri);
        [_asyncSocket writeData:[@"nvram_get Service1Mode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:17];
    }else if (Service1Mode && !Service1Portmap){
        [cofigInfo sharedInstance].Service1Mode = result;
        NSLog(@"Service1Mode----%@",[cofigInfo sharedInstance].Service1Mode);
        [_asyncSocket writeData:[@"nvram_get Service1Portmap\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:18];
    }else if (Service1Portmap && !wan_dhcp_option60_enabled){
        [cofigInfo sharedInstance].Service1Portmap = result;
        NSLog(@"Service1Portmap----%@",[cofigInfo sharedInstance].Service1Portmap);
        [_asyncSocket writeData:[@"nvram_get wan_dhcp_option60_enabled\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:19];
    }else if (wan_dhcp_option60_enabled && ! wan_vendor){
        [cofigInfo sharedInstance].wan_dhcp_option60_enabled = result;
        NSLog(@"wan_dhcp_option60_enabled----%@",[cofigInfo sharedInstance].wan_dhcp_option60_enabled);
        [_asyncSocket writeData:[@"nvram_get wan_vendor\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:20];
    }else if ( wan_vendor && ! wanConnectionMode){
        [cofigInfo sharedInstance].wan_vendor = result;
        NSLog(@"wan_vendor----%@",[cofigInfo sharedInstance].wan_vendor);
        [_asyncSocket writeData:[@"nvram_get wanConnectionMode\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:21];
    }else if (wanConnectionMode && !wan_ipaddr){
        [cofigInfo sharedInstance].wanConnectionMode = result;
        NSLog(@"wanConnectionMode----%@",[cofigInfo sharedInstance].wanConnectionMode);
        [_asyncSocket writeData:[@"nvram_get wan_ipaddr\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:22];
    }else if (wan_ipaddr && !wan_netmask){
        [cofigInfo sharedInstance].wan_ipaddr = result;
        NSLog(@"wan_ipaddr----%@",[cofigInfo sharedInstance].wan_ipaddr);
        [_asyncSocket writeData:[@"nvram_get wan_netmask\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:23];
    }else if (wan_netmask && !wan_gateway){
        [cofigInfo sharedInstance].wan_netmask = result;
        NSLog(@"wan_netmask----%@",[cofigInfo sharedInstance].wan_netmask);
        [_asyncSocket writeData:[@"nvram_get wan_gateway\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:24];
    }else if (wan_gateway && !wan_primary_dns){
        [cofigInfo sharedInstance].wan_gateway = result;
        NSLog(@"wan_gateway----%@",[cofigInfo sharedInstance].wan_gateway);
        [_asyncSocket writeData:[@"nvram_get wan_primary_dns\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:25];
    }else if (wan_primary_dns && !wan_secondary_dns){
        [cofigInfo sharedInstance].wan_primary_dns = result;
        NSLog(@"wan_primary_dns----%@",[cofigInfo sharedInstance].wan_primary_dns);
        [_asyncSocket writeData:[@"nvram_get wan_secondary_dns\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:26];
    }else if (wan_secondary_dns && !wan_pppoe_user){
        [cofigInfo sharedInstance].wan_secondary_dns = result;
        NSLog(@"wan_secondary_dns----%@",[cofigInfo sharedInstance].wan_secondary_dns);
        [_asyncSocket writeData:[@"nvram_get wan_pppoe_user\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:27];
    }else if (wan_pppoe_user && !getSSID){
        [cofigInfo sharedInstance].wan_pppoe_user = result;
        NSLog(@"wan_pppoe_user----%@",[cofigInfo sharedInstance].wan_pppoe_user);
        [_asyncSocket writeData:[@"nvram_get SSID1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:28];
    }
    //新增SSID WPAP
    else if (getSSID && !getWPAPSK1){
        [cofigInfo sharedInstance].getSSID = result;
        NSLog(@"wan_pppoe_user----%@",[cofigInfo sharedInstance].getSSID);
        [_asyncSocket writeData:[@"nvram_get WPAPSK1\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:28];
    }
    else if (getWPAPSK1 && !wan_pppoe_pass){
        [cofigInfo sharedInstance].getWPAPSK1 = result;
        NSLog(@"wan_pppoe_user----%@",[cofigInfo sharedInstance].getWPAPSK1);
        [_asyncSocket writeData:[@"nvram_get wan_pppoe_pass\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:28];
    }
    else if (wan_pppoe_pass && !isSendSuccess){
        [cofigInfo sharedInstance].wan_pppoe_pass = result;
        NSLog(@"wan_pppoe_pass----%@",[cofigInfo sharedInstance].wan_pppoe_pass);
        [self dealFinish];
    }
}

-(void)dealFinish{
    [SVProgressHUD dismiss];
    [SVProgressHUD showSuccessWithStatus:@"刷新成功"];
    [SVProgressHUD setMaximumDismissTimeInterval:2];
    if ([[cofigInfo sharedInstance].wanConnectionMode isEqualToString:@"PPPOE"]) {
        [self pppoeerrcode];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshConfig" object:nil];
    [self performSelectorOnMainThread:@selector(push) withObject:nil waitUntilDone:NO];
}

-(void)push
{
    if (_isPush) {
        UINavigationController* nav = (id)[UIApplication sharedApplication].keyWindow.rootViewController;
        UIStoryboard* storyborard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ConfigTableViewController* cvc = [storyborard instantiateViewControllerWithIdentifier:NSStringFromClass([ConfigTableViewController class])];
        [nav pushViewController:cvc animated:YES];
//        NSMutableArray *viewControllers = [nav.viewControllers mutableCopy];
//        [viewControllers removeLastObject];
//        [viewControllers addObject:cvc];
//        [nav setViewControllers:viewControllers animated:YES];
        [SVProgressHUD dismiss];
        _isPush = NO;
    }
}

-(NSString*)dealString:(NSString*)result
{
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    result = [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([result isEqualToString:@"untag"]) {
        return @"";
    }
    return result;
}

-(NSString*)dealString:(NSString*)result andReplaceString:(NSString*)replaceStr
{
    result = [result stringByReplacingOccurrencesOfString:replaceStr withString:@""];
    result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    result = [result stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    result = [result stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if ([result isEqualToString:@"untag"]) {
        return @"";
    }
    return result;
}

-(NSString*)configString:(NSString*)str
{
    str = [str stringByAppendingString:@"\n"];
    return str;
}

-(void)initBool
{
    version = NO;
    versionDate = NO;
    Service1Enable = NO;
    Service1name = NO;
    Service1Servicelist = NO;
    Service1VlanId = NO;
    Service1VlanPri = NO;
    Service1Mode = NO;
    Service1Portmap = NO;
    wan_dhcp_option60_enabled = NO;
    wan_vendor = NO;
    wanConnectionMode = NO;
    wan_ipaddr = NO;
    wan_netmask = NO;
    wan_gateway = NO;
    wan_primary_dns = NO;
    wan_secondary_dns = NO;
    wan_pppoe_user = NO;
    wan_pppoe_pass = NO;
    pppoeerrcode = NO;
    getSSID = NO;
    getWPAPSK1 = NO;
}

@end
