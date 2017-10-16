//
//  ConfigTableViewController.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/24.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "ConfigTableViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "popViewController.h"
#import "YSSocketProtocol.h"
#import "Config.h"
#import "cofigInfo.h"
#import <SVProgressHUD.h>
#import "RealReachability.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ConfigTableViewController ()<UIPopoverPresentationControllerDelegate,UITextFieldDelegate>
{
    CGFloat rowHeight_;
    NSString* _currentWifiName;
}

@property(nonatomic,strong)popViewController* popViewController;
@property(nonatomic,strong)popViewController* wanConnectionModePOP;
@property(nonatomic,strong)NSString* wanConnectionMode;

@property(nonatomic,strong)UIView* PPPOEView;
@property(nonatomic,strong)UITextField* userNameTF;
@property(nonatomic,strong)UITextField* passWordTF;

@property(nonatomic,strong)UIView* DHCPView;
@property(nonatomic,strong)UILabel* functionLab;
@property(nonatomic,strong)UISwitch* funSW;
@property(nonatomic,strong)UILabel* function60Lab;

@property(nonatomic,strong)UIView* STATICView;
@property(nonatomic,strong)UITextField* ipTF;
@property(nonatomic,strong)UITextField* yanmaTF;
@property(nonatomic,strong)UITextField* wangguanTF;
@property(nonatomic,strong)UITextField* firstDNSTF;
@property(nonatomic,strong)UITextField* reserveDNSTF;

@property(nonatomic,strong)NSMutableArray* portArr;

@end

@implementation ConfigTableViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"配置";
    [self setupForDismissKeyboard];
    [self setNav];
    [self setUpData];
    [self setConfigCommod];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(connectStyleChanged:) name:@"connectStyleChanged" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPageNoti) name:@"refreshConfig" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:)name:kRealReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshErrorCode) name:@"refreshErrorCode" object:nil];
    
    [self judgeNetWorkStatus];
}

-(void)judgeNetWorkStatus
{
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
    NSLog(@"Initial reachability status:%@",@(status));
    if (status == RealStatusNotReachable)
    {
        self.netStatus.image = [UIImage imageNamed:@"off"];
        if ([_connectStyleBtn.titleLabel.text containsString:@"PPPOE"]) {
            [[YSSocketProtocol shareSocketProtocol]pppoeerrcode];
        }
    }else{
        self.netStatus.image = [UIImage imageNamed:@"on"];
        self.errorCodeLab.text = @"";
    }
}

#pragma mark - 通知

-(void)refreshErrorCode
{
    NSString* codeStr = [NSString string];
    if ([[cofigInfo sharedInstance].pppoeerrcode containsString:@"678"]) {
        codeStr = @"连接超时";
    }else if ([[cofigInfo sharedInstance].pppoeerrcode containsString:@"691"]){
        codeStr = @"认证失败";
    }else if ([[cofigInfo sharedInstance].pppoeerrcode containsString:@"769"]){
        codeStr = @"网卡禁用";
    }else{
        codeStr = @"拨号异常,请核查链路";
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.errorCodeLab.text = codeStr;
    });
}

- (void)networkChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    if (status == RealStatusNotReachable)
    {
        self.netStatus.image = [UIImage imageNamed:@"off"];
        if ([_connectStyleBtn.titleLabel.text containsString:@"PPPOE"]) {
            [[YSSocketProtocol shareSocketProtocol]pppoeerrcode];
        }
    }else{
        self.netStatus.image = [UIImage imageNamed:@"on"];
        self.errorCodeLab.text = @"";
    }
}

-(void)connectStyleChanged:(NSNotification*)noti
{
    NSDictionary* userinfo = noti.userInfo;
    NSInteger type = [userinfo[@"type"] integerValue];
    NSString* style = userinfo[@"style"];
    if (type == 1) {
        [self.connectStyleBtn setTitle:[NSString stringWithFormat:@"%@ ▼",style] forState:UIControlStateNormal];
        [cofigInfo sharedInstance].set_wanConnectionMode = [NSString stringWithFormat:@"nvram_set wanConnectionMode \"%@\"",style];
        NSLog(@"set_wanConnectionMode==%@",[cofigInfo sharedInstance].set_wanConnectionMode);
        [self judgeWanConnectionMode:style];
    }else if(type == 2){
        [self.serviceBlandClassBtn setTitle:[NSString stringWithFormat:@"%@ ▼",style] forState:UIControlStateNormal];
        [cofigInfo sharedInstance].set_Service1Servicelist = [NSString stringWithFormat:@"nvram_set Service1Servicelist \"%@\"",style];
        NSLog(@"set_Service1Servicelist==%@",[cofigInfo sharedInstance].set_Service1Servicelist);
    }
    
}

-(void)judgeWanConnectionMode:(NSString*)mode
{
    if ([mode isEqualToString:@"PPPOE"]) {
        _PPPOEView.hidden = NO;
        _DHCPView.hidden = YES;
        _STATICView.hidden = YES;
        rowHeight_ = 150;
    }else if ([mode isEqualToString:@"STATIC"]) {
        _PPPOEView.hidden = YES;
        _DHCPView.hidden = YES;
        _STATICView.hidden = NO;
        rowHeight_ = 260;
    }else if ([mode isEqualToString:@"DHCP"]) {
        _PPPOEView.hidden = YES;
        _DHCPView.hidden = NO;
        _STATICView.hidden = YES;
        rowHeight_ = 140;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

-(void)refreshPageNoti
{
    [self performSelectorOnMainThread:@selector(setUpData) withObject:nil waitUntilDone:NO];
}

#pragma mark - setConfig

-(void)setConfigCommod
{
    [cofigInfo sharedInstance].set_Service1Enable = [NSString stringWithFormat:@"nvram_set Service1Enable \"1\""];
    NSLog(@"set_Service1Enable==%@",[cofigInfo sharedInstance].set_Service1Enable);
    
    if ([[cofigInfo sharedInstance].Service1name hasPrefix:@"1_INTERNET_R_VID_"]) {
        if ([[cofigInfo sharedInstance].Service1VlanId isEqualToString:@"0"]) {
            [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name 1_INTERNET_R_VID_untag"];
        }else{
            [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name 1_INTERNET_R_VID_%@",[cofigInfo sharedInstance].Service1VlanId];
        }
    }else{
        [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name %@",[cofigInfo sharedInstance].Service1name];
    }
    
    [cofigInfo sharedInstance].set_Service1Servicelist = [NSString stringWithFormat:@"nvram_set Service1Servicelist \"%@\"",[cofigInfo sharedInstance].Service1Servicelist];
    NSLog(@"set_Service1Servicelist==%@",[cofigInfo sharedInstance].set_Service1Servicelist);
    
    [cofigInfo sharedInstance].set_Service1VlanId = [NSString stringWithFormat:@"nvram_set Service1VlanId %@",[cofigInfo sharedInstance].Service1VlanId];
    NSLog(@"set_Service1VlanId==%@",[cofigInfo sharedInstance].set_Service1VlanId);
    
    [cofigInfo sharedInstance].set_Service1VlanPri = [NSString stringWithFormat:@"nvram_set Service1VlanPri %@",[cofigInfo sharedInstance].Service1VlanPri];
    NSLog(@"set_Service1VlanPri==%@",[cofigInfo sharedInstance].set_Service1VlanPri);
    
    [cofigInfo sharedInstance].set_Service1Portmap = [NSString stringWithFormat:@"nvram_set Service1Portmap %@",[cofigInfo sharedInstance].Service1Portmap];
    NSLog(@"set_Service1Portmap==%@",[cofigInfo sharedInstance].set_Service1Portmap);
    
    [cofigInfo sharedInstance].set_wan_dhcp_option60_enabled = [NSString stringWithFormat:@"nvram_set wan_dhcp_option60_enabled \"%@\"",[cofigInfo sharedInstance].wan_dhcp_option60_enabled];
    NSLog(@"set_wan_dhcp_option60_enabled==%@",[cofigInfo sharedInstance].set_wan_dhcp_option60_enabled);
    
    if ([[cofigInfo sharedInstance].wan_dhcp_option60_enabled boolValue]) {
        [cofigInfo sharedInstance].set_wan_vendor = [NSString stringWithFormat:@"nvram_set wan_vendor %@",[cofigInfo sharedInstance].wan_vendor];
    }else{
        [cofigInfo sharedInstance].set_wan_vendor = [NSString stringWithFormat:@"nvram_set wan_vendor  "];
    }
    
    NSLog(@"set_wan_vendor== %@",[cofigInfo sharedInstance].set_wan_vendor);
    
    
    [cofigInfo sharedInstance].set_wanConnectionMode = [NSString stringWithFormat:@"nvram_set wanConnectionMode \"%@\"",[cofigInfo sharedInstance].wanConnectionMode];
    NSLog(@"set_wanConnectionMode==%@",[cofigInfo sharedInstance].set_wanConnectionMode);
    
    [cofigInfo sharedInstance].set_wan_ipaddr = [NSString stringWithFormat:@"nvram_set wan_ipaddr %@",[cofigInfo sharedInstance].wan_ipaddr];
    NSLog(@"set_wan_ipaddr==%@",[cofigInfo sharedInstance].set_wan_ipaddr);
    
    [cofigInfo sharedInstance].set_wan_netmask = [NSString stringWithFormat:@"nvram_set wan_netmask %@",[cofigInfo sharedInstance].wan_netmask];
    NSLog(@"set_wan_netmask==%@",[cofigInfo sharedInstance].set_wan_netmask);
    
    [cofigInfo sharedInstance].set_wan_gateway = [NSString stringWithFormat:@"nvram_set wan_gateway %@",[cofigInfo sharedInstance].wan_gateway];
    NSLog(@"set_wan_gateway==%@",[cofigInfo sharedInstance].set_wan_gateway);
    
    [cofigInfo sharedInstance].set_wan_primary_dns = [NSString stringWithFormat:@"nvram_set wan_primary_dns %@",[cofigInfo sharedInstance].wan_primary_dns];
    NSLog(@"set_wan_primary_dns==%@",[cofigInfo sharedInstance].set_wan_primary_dns);
    
    [cofigInfo sharedInstance].set_wan_secondary_dns = [NSString stringWithFormat:@"nvram_set wan_secondary_dns %@",[cofigInfo sharedInstance].wan_secondary_dns];
    NSLog(@"set_wan_secondary_dns==%@",[cofigInfo sharedInstance].set_wan_secondary_dns);
    
    [cofigInfo sharedInstance].set_wan_pppoe_user = [NSString stringWithFormat:@"nvram_set wan_pppoe_user %@",[cofigInfo sharedInstance].wan_pppoe_user];
    NSLog(@"set_wan_pppoe_user==%@",[cofigInfo sharedInstance].set_wan_pppoe_user);
    
    [cofigInfo sharedInstance].set_wan_pppoe_pass = [NSString stringWithFormat:@"nvram_set wan_pppoe_pass %@",[cofigInfo sharedInstance].wan_pppoe_pass];
    NSLog(@"set_wan_pppoe_pass==%@",[cofigInfo sharedInstance].set_wan_pppoe_pass);

}

#pragma mark - 填充数据

-(void)setUpData
{
    rowHeight_ = 150;
    self.VLANIDLab.text = [cofigInfo sharedInstance].Service1VlanId;
    if ([[cofigInfo sharedInstance].Service1VlanId isEqualToString:@"0"]) {
        [self.VLANSch setOn:NO];
    }else{
        [self.VLANSch setOn:YES];
    }
    self.priorityLab.text = [cofigInfo sharedInstance].Service1VlanPri;
    NSString* portMap = [cofigInfo sharedInstance].Service1Portmap;
    NSMutableArray* valueArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < portMap.length; i++) {
        if (i < 8) {
            NSString* value = [portMap substringWithRange:NSMakeRange(i, 1)];
            [valueArr addObject:value];
        }
    }
    if (valueArr.count > 7) {
        [self.LAN1Sch setOn:[valueArr[0] boolValue]];
        [self.LAN2Sch setOn:[valueArr[1] boolValue]];
        [self.LAN3Sch setOn:[valueArr[2] boolValue]];
        [self.LAN4Sch setOn:[valueArr[3] boolValue]];
        [self.wifi1Sch setOn:[valueArr[4] boolValue]];
        [self.wifi2Sch setOn:[valueArr[5] boolValue]];
        [self.wifi3Sch setOn:[valueArr[6] boolValue]];
        [self.wifi4Sch setOn:[valueArr[7] boolValue]];
    }
    
    [self.connectStyleBtn setTitle:[NSString stringWithFormat:@"%@ ▼",[cofigInfo sharedInstance].wanConnectionMode] forState:UIControlStateNormal];
    [self judgeWanConnectionMode:[cofigInfo sharedInstance].wanConnectionMode];
    
    _userNameTF.text = [cofigInfo sharedInstance].wan_pppoe_user;
    _passWordTF.text = [cofigInfo sharedInstance].wan_pppoe_pass;
    
    [_funSW setOn:[[cofigInfo sharedInstance].wan_dhcp_option60_enabled boolValue]];
    _function60Lab.text = [cofigInfo sharedInstance].wan_vendor;
    
    self.ipTF.text = [cofigInfo sharedInstance].wan_ipaddr;
    self.yanmaTF.text = [cofigInfo sharedInstance].wan_netmask;
    self.wangguanTF.text = [cofigInfo sharedInstance].wan_gateway;
    self.firstDNSTF.text = [cofigInfo sharedInstance].wan_primary_dns;
    self.reserveDNSTF.text = [cofigInfo sharedInstance].wan_secondary_dns;

    [self.serviceBlandClassBtn setTitle:[NSString stringWithFormat:@"%@ ▼",[cofigInfo sharedInstance].Service1Servicelist] forState:UIControlStateNormal];
}

#pragma mark - nav click

-(void)backclick
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"您确定要退出配置吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[YSSocketProtocol shareSocketProtocol]disConnectToHost];
//        [YSSocketProtocol shareSocketProtocol].asyncSocket = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//刷新配置信息
-(void)refreshPage
{
    [[YSSocketProtocol shareSocketProtocol]updateDonfigData];
}

-(void)commitPage
{
//    [self getWifiName];
//    if ([_currentWifiName isEqualToString:self.wifiName]) {
        [cofigInfo sharedInstance].set_wan_ipaddr = [NSString stringWithFormat:@"nvram_set wan_ipaddr %@",_ipTF.text];
        NSLog(@"set_wan_ipaddr==%@",[cofigInfo sharedInstance].set_wan_ipaddr);
        
        [cofigInfo sharedInstance].set_wan_netmask = [NSString stringWithFormat:@"nvram_set wan_netmask %@",_yanmaTF.text];
        NSLog(@"set_wan_netmask==%@",[cofigInfo sharedInstance].set_wan_netmask);
        
        [cofigInfo sharedInstance].set_wan_gateway = [NSString stringWithFormat:@"nvram_set wan_gateway %@",_wangguanTF.text];
        NSLog(@"set_wan_gateway==%@",[cofigInfo sharedInstance].set_wan_gateway);
        
        [cofigInfo sharedInstance].set_wan_primary_dns = [NSString stringWithFormat:@"nvram_set wan_primary_dns %@",_firstDNSTF.text];
        NSLog(@"set_wan_primary_dns==%@",[cofigInfo sharedInstance].set_wan_primary_dns);
        
        [cofigInfo sharedInstance].set_wan_secondary_dns = [NSString stringWithFormat:@"nvram_set wan_secondary_dns %@",_reserveDNSTF.text];
        NSLog(@"set_wan_secondary_dns==%@",[cofigInfo sharedInstance].set_wan_secondary_dns);
        
        [cofigInfo sharedInstance].set_wan_pppoe_user = [NSString stringWithFormat:@"nvram_set wan_pppoe_user %@",_userNameTF.text];
        NSLog(@"set_wan_pppoe_user==%@",[cofigInfo sharedInstance].set_wan_pppoe_user);
        
        [cofigInfo sharedInstance].set_wan_pppoe_pass = [NSString stringWithFormat:@"nvram_set wan_pppoe_pass %@",_passWordTF.text];
        NSLog(@"set_wan_pppoe_pass==%@",[cofigInfo sharedInstance].set_wan_pppoe_pass);
        
        NSString* portMap = [self.portArr componentsJoinedByString:@""];
        [cofigInfo sharedInstance].set_Service1Portmap = [NSString stringWithFormat:@"nvram_set Service1Portmap %@",portMap];
        NSLog(@"set_Service1Portmap==%@",[cofigInfo sharedInstance].set_Service1Portmap);
        
        [[YSSocketProtocol shareSocketProtocol]setData];
//    }else{
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"请连接到%@",self.wifiName] preferredStyle:UIAlertControllerStyleAlert];
//        [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        }]];
//        [self presentViewController:alertController animated:YES completion:nil];
//    }
}

#pragma mark - 点击／value change事件

- (IBAction)connectStyleBtnClick:(UIButton *)sender {
    [self presentViewController:self.popViewController animated:YES completion:nil];
}

-(void)function60Click
{
    if (_funSW.isOn) {
        [self alertVCWithMessage:@"设置Option60"];
    }
}

-(void)funSwChanged:(UISwitch*)sender
{
    [cofigInfo sharedInstance].set_wan_dhcp_option60_enabled = [NSString stringWithFormat:@"nvram_set wan_dhcp_option60_enabled \"%d\"",_funSW.isOn];
    NSLog(@"set_wan_dhcp_option60_enabled==%@",[cofigInfo sharedInstance].set_wan_dhcp_option60_enabled);
    if (!sender.isOn) {
        self.function60Lab.text = @"";
        [cofigInfo sharedInstance].set_wan_vendor = [NSString stringWithFormat:@"nvram_set wan_vendor  "];
        
    }else{
        self.function60Lab.text = [cofigInfo sharedInstance].wan_vendor;
        [cofigInfo sharedInstance].set_wan_vendor = [NSString stringWithFormat:@"nvram_set wan_vendor %@",[cofigInfo sharedInstance].wan_vendor];
    }
    
}

- (IBAction)VLANChanged:(UISwitch *)sender {
    if (!sender.isOn) {
        self.VLANIDLab.text = @"0";
        [cofigInfo sharedInstance].set_Service1VlanId = [NSString stringWithFormat:@"nvram_set Service1VlanId %@",self.VLANIDLab.text];
        if ([[cofigInfo sharedInstance].Service1name hasPrefix:@"1_INTERNET_R_VID_"]) {
            [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name 1_INTERNET_R_VID_untag"];
        }
    }else{
        if ([[cofigInfo sharedInstance].Service1name hasPrefix:@"1_INTERNET_R_VID_"]) {
            [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name 1_INTERNET_R_VID_%@",[cofigInfo sharedInstance].Service1VlanId];
        }
    }
}
- (IBAction)serviceBlandClassBtnClick:(id)sender {
    [self presentViewController:self.wanConnectionModePOP animated:YES completion:nil];
}

- (IBAction)LAN1Changed:(UISwitch *)sender {
    [self getportStringWithIndex:0 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)LAN2Changed:(UISwitch *)sender {
    [self getportStringWithIndex:1 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)LAN3Changed:(UISwitch *)sender {
    [self getportStringWithIndex:2 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)LAN4Changed:(UISwitch *)sender {
    [self getportStringWithIndex:3 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)wifi1Changed:(UISwitch *)sender {
    [self getportStringWithIndex:4 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)wifi2Changed:(UISwitch *)sender {
    [self getportStringWithIndex:5 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)wifi3Changed:(UISwitch *)sender {
    [self getportStringWithIndex:6 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

- (IBAction)wifi4Changed:(UISwitch *)sender {
    [self getportStringWithIndex:7 andValue:[NSString stringWithFormat:@"%d",sender.isOn]];
}

-(void)getportStringWithIndex:(NSInteger)index andValue:(NSString*)value
{
    [self.portArr replaceObjectAtIndex:index withObject:value];
    NSLog(@"portArr---%@",[self.portArr componentsJoinedByString:@","]);
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.VLANSch.isOn) {
        if (indexPath.row == 3) {
            [self alertVCWithMessage:@"有效值为 2-4080,4082-4095"];
        }else if (indexPath.row == 4) {
            [self alertVCWithMessage:@"优先级"];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 60;
    }else if (indexPath.row == 1) {//260 140 100
        return rowHeight_;
    }else if (indexPath.row == 2) {
        return 60;
    }else if (indexPath.row == 3) {
        return 60;
    }else if (indexPath.row == 4) {
        return 60;
    }else if (indexPath.row == 5) {
        return 60;
    }else if (indexPath.row == 6) {
        return 60;
    }
    return 40;
}

#pragma mark - alertVc

-(void)alertVCWithMessage:(NSString*)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField * userNameTextField = alertController.textFields.firstObject;
        if ([message containsString:@"有效值为"]) {
            NSInteger vlanId = [userNameTextField.text integerValue];
            if (vlanId < 2 || vlanId > 4095 || (vlanId == 4081)) {
                [SVProgressHUD showErrorWithStatus:@"该VLAN ID无效"];
                return ;
            }
            self.VLANIDLab.text = userNameTextField.text;
            
            [cofigInfo sharedInstance].set_Service1VlanId = [NSString stringWithFormat:@"nvram_set Service1VlanId %@",userNameTextField.text];
            NSLog(@"set_Service1VlanId == %@" ,[cofigInfo sharedInstance].set_Service1VlanId);
            
            if ([[cofigInfo sharedInstance].Service1name hasPrefix:@"1_INTERNET_R_VID_"]) {
                [cofigInfo sharedInstance].set_Service1name = [NSString stringWithFormat:@"nvram_set Service1name 1_INTERNET_R_VID_%@",self.VLANIDLab.text];
            }
            
        }else if ([message containsString:@"优先级"]){
            NSInteger vlanId = [userNameTextField.text integerValue];
            if (vlanId < 0 || vlanId > 7) {
                [SVProgressHUD showErrorWithStatus:@"该优先级的值无效"];
                return;
            }
            self.priorityLab.text = userNameTextField.text;
            [cofigInfo sharedInstance].set_Service1VlanPri = [NSString stringWithFormat:@"nvram_set Service1VlanPri \"%@\"",userNameTextField.text];
            NSLog(@"set_Service1VlanPri == %@" ,[cofigInfo sharedInstance].set_Service1VlanPri);
        }else if ([message containsString:@"设置Option60"]){
            self.function60Lab.text = userNameTextField.text;
            [cofigInfo sharedInstance].set_wan_vendor = [NSString stringWithFormat:@"nvram_set wan_vendor %@",userNameTextField.text];
            NSLog(@"set_wan_vendor == %@" ,[cofigInfo sharedInstance].set_wan_vendor);
        }
        
    }]];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入内容";
        textField.keyboardType = UIKeyboardTypeNumberPad;
//        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

#pragma mark - setNav

-(void)setNav
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backclick)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(refreshPage)];

    UIBarButtonItem* commitItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"upload"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(commitPage)];
    self.navigationItem.rightBarButtonItems = @[refreshItem,commitItem];
}

-(void)setConnectStyleView:(UIView *)connectStyleView
{
    _connectStyleView = connectStyleView;
    [_connectStyleView addSubview:self.DHCPView];
    [_connectStyleView addSubview:self.STATICView];
    [_connectStyleView addSubview:self.PPPOEView];
    [_DHCPView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_connectStyleView);
    }];
    [_STATICView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_connectStyleView);
    }];
    [_PPPOEView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(_connectStyleView);
    }];
}

#pragma mark - lazy

-(NSMutableArray *)portArr
{
    if (!_portArr) {
        _portArr = [[NSMutableArray alloc]init];
        NSString* portStr = [cofigInfo sharedInstance].Service1Portmap;
        for (int i = 0; i < portStr.length; i++) {
            NSString* temp = [portStr substringWithRange:NSMakeRange(i, 1)];
            [_portArr addObject:temp];
        }
    }
    return _portArr;
}

-(popViewController *)popViewController
{
    if (!_popViewController) {
        _popViewController = [[popViewController alloc]init];
    }
    _popViewController.modalPresentationStyle  = UIModalPresentationPopover;
    _popViewController.popoverPresentationController.sourceView = self.connectStyleBtn;
    _popViewController.popoverPresentationController.sourceRect = self.connectStyleBtn.bounds;
    _popViewController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    _popViewController.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    _popViewController.popoverPresentationController.delegate = self;
    _popViewController.preferredContentSize = CGSizeMake(100, 120);
    _popViewController.titleArr = @[@"DHCP",@"STATIC",@"PPPOE"];
    _popViewController.type = PopTypeMode;
    return _popViewController;
}

-(popViewController *)wanConnectionModePOP
{
    if (!_wanConnectionModePOP) {
        _wanConnectionModePOP = [[popViewController alloc]init];
    }
    _wanConnectionModePOP.modalPresentationStyle  = UIModalPresentationPopover;
    _wanConnectionModePOP.popoverPresentationController.sourceView = self.serviceBlandClassBtn;
    _wanConnectionModePOP.popoverPresentationController.sourceRect = self.serviceBlandClassBtn.bounds;
    _wanConnectionModePOP.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    _wanConnectionModePOP.popoverPresentationController.backgroundColor = [UIColor whiteColor];
    _wanConnectionModePOP.popoverPresentationController.delegate = self;
    _wanConnectionModePOP.preferredContentSize = CGSizeMake(180, 240);
    _wanConnectionModePOP.titleArr = @[@"INTERNET",@"TR069",@"VOIP",@"OTHER",@"INTERNET_TR069",@"TR069_VOIP"];
    _wanConnectionModePOP.type = PopTypeServiceBland;
    return _wanConnectionModePOP;
}

-(UIView *)PPPOEView
{
    if (!_PPPOEView) {
        _PPPOEView = [[UIView alloc]init];
        _userNameTF = [[UITextField alloc]init];
        _userNameTF.placeholder = @"用户名";
        [self configTextfield:_userNameTF];
        [_PPPOEView addSubview:_userNameTF];
        _passWordTF = [[UITextField alloc]init];
        _passWordTF.placeholder = @"密码";
        _passWordTF.secureTextEntry = YES;
        [self configTextfield:_passWordTF];
        [_PPPOEView addSubview:_passWordTF];
        [_userNameTF makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_PPPOEView.centerY).offset(-5);
            make.left.equalTo(_PPPOEView.left).offset(65);
            make.right.equalTo(_PPPOEView.right).offset(-20);
            make.height.equalTo(35);
        }];
        [_passWordTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_PPPOEView.centerY).offset(5);
            make.left.equalTo(_PPPOEView.left).offset(65);
            make.right.equalTo(_PPPOEView.right).offset(-20);
            make.height.equalTo(35);
        }];
        _PPPOEView.hidden = NO;
    }
    return _PPPOEView;
}

-(UIView *)STATICView
{
    if (!_STATICView) {
        _STATICView = [[UIView alloc]init];
        _ipTF = [[UITextField alloc]init];
        _ipTF.placeholder = @"IP地址";
        [self configTextfield:_ipTF];
        [_STATICView addSubview:_ipTF];
        _yanmaTF = [[UITextField alloc]init];
        _yanmaTF.placeholder = @"子网掩码";
        [self configTextfield:_yanmaTF];
        [_STATICView addSubview:_yanmaTF];
        _wangguanTF = [[UITextField alloc]init];
        _wangguanTF.placeholder = @"缺省网关";
        [self configTextfield:_wangguanTF];
        [_STATICView addSubview:_wangguanTF];
        _firstDNSTF = [[UITextField alloc]init];
        _firstDNSTF.placeholder = @"首选DNS服务器";
        [self configTextfield:_firstDNSTF];
        [_STATICView addSubview:_firstDNSTF];
        _reserveDNSTF = [[UITextField alloc]init];
        _reserveDNSTF.placeholder = @"备用DNS服务器";
        [self configTextfield:_reserveDNSTF];
        [_STATICView addSubview:_reserveDNSTF];
        [_ipTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_STATICView.top).offset(5);
            make.left.equalTo(_STATICView.left).offset(65);
            make.height.equalTo(35);
            make.right.equalTo(_STATICView.right).offset(-20);
        }];
        [_yanmaTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_ipTF.bottom).offset(5);
            make.left.equalTo(_STATICView.left).offset(65);
            make.right.equalTo(_STATICView.right).offset(-20);
            make.height.equalTo(35);
        }];
        [_wangguanTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_yanmaTF.bottom).offset(5);
            make.left.equalTo(_STATICView.left).offset(65);
            make.right.equalTo(_STATICView.right).offset(-20);
            make.height.equalTo(35);
        }];
        [_firstDNSTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_wangguanTF.bottom).offset(5);
            make.left.equalTo(_STATICView.left).offset(65);
            make.right.equalTo(_STATICView.right).offset(-20);
            make.height.equalTo(35);
        }];
        [_reserveDNSTF makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_firstDNSTF.bottom).offset(5);
            make.left.equalTo(_STATICView.left).offset(65);
            make.right.equalTo(_STATICView.right).offset(-20);
            make.height.equalTo(35);
        }];
        _STATICView.hidden = YES;
    }
    return _STATICView;
}

-(UIView *)DHCPView
{
    if (!_DHCPView) {
        _DHCPView = [[UIView alloc]init];
        
        _functionLab = [[UILabel alloc]init];
        _functionLab.textColor = getColor(@"212121");
        _functionLab.font = [UIFont systemFontOfSize:15];
        _functionLab.textAlignment = NSTextAlignmentLeft;
        _functionLab.text = @"Option功能开关";
        [_DHCPView addSubview:_functionLab];
        
        _funSW = [[UISwitch alloc]init];
        _funSW.transform=CGAffineTransformMakeScale(0.9,0.9);
        [_funSW addTarget:self action:@selector(funSwChanged:) forControlEvents:UIControlEventValueChanged];
        [_DHCPView addSubview:_funSW];
        
        _function60Lab = [[UILabel alloc]init];
        _function60Lab.textColor = getColor(@"8c8c8c");
        _function60Lab.font = [UIFont systemFontOfSize:15];
        _function60Lab.textAlignment = NSTextAlignmentRight;
        _function60Lab.text = @"0";
        [_DHCPView addSubview:_function60Lab];
        
        UILabel* titleLab = [[UILabel alloc]init];
        titleLab.text = @"Option60";
        titleLab.textColor = getColor(@"212121");
        titleLab.font = [UIFont systemFontOfSize:15];
        titleLab.textAlignment = NSTextAlignmentLeft;
        titleLab.userInteractionEnabled = NO;
        [_DHCPView addSubview:titleLab];
        
        [_functionLab makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_DHCPView.top).offset(10);
            make.left.equalTo(_DHCPView.left).offset(65);
        }];
        [_funSW makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_functionLab.centerY);
            make.right.equalTo(_DHCPView.right).offset(-20);
        }];
        [_function60Lab makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_DHCPView.left).offset(0);
            make.top.equalTo(_functionLab.top).offset(10);
            make.right.equalTo(_DHCPView.right).offset(-20);
            make.bottom.equalTo(_DHCPView.bottom).offset(10);
        }];
        [titleLab makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_function60Lab.centerY);
            make.left.equalTo(_DHCPView.left).offset(65);
        }];
        
        _function60Lab.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(function60Click)];
        [_function60Lab addGestureRecognizer:tap];
        _DHCPView.hidden = YES;
    }
    return _DHCPView;
}

#pragma mark -- UIPresentationDelegate
//点击空白自动dismiss掉popViewController
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

-(UITextField*)configTextfield:(UITextField*)textfield
{
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.borderStyle = UITextBorderStyleRoundedRect;
    [textfield setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    textfield.font = [UIFont systemFontOfSize:15];
    textfield.keyboardType = UIKeyboardTypeASCIICapable;
    return textfield;
}

#pragma mark - UITextFieldDelegate



#pragma mark - 获取Wi-Fi名称

-(void)getWifiName
{
    id info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        _currentWifiName = info[@"SSID"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
