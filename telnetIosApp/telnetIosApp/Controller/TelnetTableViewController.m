//
//  TelnetTableViewController.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/7.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "TelnetTableViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "YSSocketProtocol.h"
#import <NetworkExtension/NetworkExtension.h>
#import "cloudAndPwdAlertView.h"
#import "TelDataBase.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Config.h"
#import "appColor.h"
#import "XMFTPServer.h"
#import "NSString+XP.h"
#import "FTPManager.h"


@interface TelnetTableViewController ()
{
    NSString* _currentWifiName;
    NSString* _currentHost;
}
@property (weak, nonatomic) IBOutlet UITextField *hostTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn;
/**  popview */
@property(nonatomic,strong)cloudAndPwdAlertView* alertView;
@property (nonatomic, strong) XMFTPServer *ftpServer;

@end

@implementation TelnetTableViewController

#pragma mark - paras for ftpConnection

-(NSString*)getFtpUserName
{
    return @"123";
}
-(NSString*)getFtpPWD
{
    return @"123";
}
#pragma mark - setter

-(cloudAndPwdAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([cloudAndPwdAlertView class]) owner:nil options:nil][0];
        _alertView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _alertView.wfiiLab.text = self.wifiName;
        _alertView.passwordLab.text = self.password;
    }
    return _alertView;
}

-(void)setHostTF:(UITextField *)hostTF
{
    _hostTF = hostTF;
    if (self.type == 1) {
        _hostTF.text = self.host;
    }else{
        _hostTF.text = @"192.168.1.1";
    }
    [_hostTF addTarget:self action:@selector(textDidChanged) forControlEvents:UIControlEventEditingChanged];
}

-(void)setPortTF:(UITextField *)portTF
{
    _portTF = portTF;
    _portTF.text = @"8062";
    [_portTF addTarget:self action:@selector(textDidChanged) forControlEvents:UIControlEventEditingChanged];
}

-(void)setLinkBtn:(UIButton *)linkBtn
{
    _linkBtn = linkBtn;
    _linkBtn.backgroundColor = mainColor;
    _linkBtn.layer.cornerRadius = 10;
    _linkBtn.layer.masksToBounds = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
//    [[YSSocketProtocol shareSocketProtocol]disConnectToHost];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"connect";
    
    [self setupForDismissKeyboard];
    _currentHost = self.hostTF.text;
    if (self.type == 2) {
        [self.alertView pop];
    }
    [self startFtp];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopFTPServer];
}

#pragma mark - 配置FTP
//开启FTP
-(void)startFtp
{
    unsigned int ftpPort = 23023;
    NSString *ip = [XMFTPHelper localIPAddress];
    if (![ip isIP]) {
        [SVProgressHUD showErrorWithStatus:@"开启FTP服务失败"];
    }
    [self stopFTPServer];
    NSString* str = [NSString stringWithFormat:@"ftp://%@:%d", ip, ftpPort];
    NSLog(@"ip==%@",str);
    _ftpServer = [[XMFTPServer alloc] initWithPort:ftpPort
                                           withDir:NSTemporaryDirectory()
                                      notifyObject:nil];
    _ftpServer.clientEncoding = NSUTF8StringEncoding;
}

//关闭Ftp
- (void)stopFTPServer {
    if (_ftpServer) {
        [_ftpServer stopFtpServer];
        _ftpServer = nil;
    }
}

- (IBAction)linkClick:(UIButton *)sender {

    [self getWifiName];
    if (![self.wifiName isEqualToString:_currentWifiName] && self.type != 3) {
        [self alertWithMessage:[NSString stringWithFormat:@"请连接到%@",self.wifiName]];
        return;
    }
    if (self.type == 3) {
        self.wifiName = _currentWifiName;
        self.password = @"";
    }
    if (self.hostTF.text.length == 0) {
        [self alertWithMessage:@"请输入主机名或IP地址"];
        return;
    }
    if (self.portTF.text.length == 0) {
        [self alertWithMessage:@"请输入端口号"];
        return;
    }
    NSString *regex = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];//^[a-zA-Z0-9]|[@  .  -   _]{1,31}$
    BOOL hostIsValid = [predicate evaluateWithObject:self.hostTF.text];
    if (!hostIsValid) {
        [self alertWithMessage:@"请输入正确的主机名或IP地址"];
        return;
    }

    if (![_currentHost isEqualToString:_hostTF.text]) {
        [[YSSocketProtocol shareSocketProtocol]disConnectToHost];
        [YSSocketProtocol shareSocketProtocol].asyncSocket = nil;
        sleep(1);
    }

//    @"192.168.1.1" 8062
    if ([[YSSocketProtocol shareSocketProtocol]isConnect]) {
        [YSSocketProtocol shareSocketProtocol].isPush = YES;
        [[YSSocketProtocol shareSocketProtocol]updateDonfigData];
    }else{
        [YSSocketProtocol shareSocketProtocol].disConectType = 1;
        [[YSSocketProtocol shareSocketProtocol]socketConnectWithHost:self.hostTF.text andPort:8062];
    }
    if(![[TelDataBase shareTelDataBase]isSaveWifiName:self.wifiName]){
        [[TelDataBase shareTelDataBase]savehort:self.hostTF.text port:self.portTF.text wifiName:self.wifiName wifiPass:self.password];
    }
    
    NSLog(@"点击链接按钮");
}

-(void)textDidChanged
{
    if (_hostTF.text.length != 0  && _portTF.text.length != 0) {
        _linkBtn.enabled = YES;
    }
}

-(void)alertWithMessage:(NSString*)msg
{
    UIAlertController* alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }else if (indexPath.row == 1){
//        if (self.type == 3) {
//            return 0;
//        }
        return 70;
    }else if (indexPath.row == 2){
        return 130;
    }
    return 80;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
