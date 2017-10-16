//
//  MainTableViewController.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/7.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "MainTableViewController.h"
#import "QRCScannerViewController.h"
#import "MainTableViewCell.h"
#import "TelnetTableViewController.h"
#import "ipModel.h"
#import "TelDataBase.h"
#import "cloudAndPwdAlertView.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Config.h"
#import "appColor.h"
#import "ConfigTableViewController.h"
#import "YSSocketProtocol.h"

@interface MainTableViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString* _currentWifiName;
}
/**  数据源 */
@property(nonatomic,strong)NSMutableArray* dataArray;
/**  popview */
@property(nonatomic,strong)cloudAndPwdAlertView* alertView;

@end

@implementation MainTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[YSSocketProtocol shareSocketProtocol]disConnectToHost];
    [self loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"运维工具";
    [self setUpTableview];
    
    UIBarButtonItem* connertorItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"connertor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(connertorCilck)];
    self.navigationItem.rightBarButtonItem = connertorItem;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(goScannerViewController)];
}

-(void)connertorCilck
{
    UIStoryboard* storyborard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TelnetTableViewController* tvc = [storyborard instantiateViewControllerWithIdentifier:NSStringFromClass([TelnetTableViewController class])];
    tvc.type = 3;
    [self.navigationController pushViewController:tvc animated:YES];
}

-(void)setUpTableview
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"maincell"];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self showScanerBtn];
}

-(void)loadData
{
    _dataArray = [[TelDataBase shareTelDataBase]queryIpListData];
    [self.tableView reloadData];
}

-(cloudAndPwdAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([cloudAndPwdAlertView class]) owner:nil options:nil][0];
        _alertView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    return _alertView;
}

-(void)showScanerBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(goScannerViewController) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
    btn.backgroundColor = mainColor;
    btn.layer.cornerRadius = 30;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tableView.bottom);
        make.size.equalTo(CGSizeMake(60, 60));
        make.right.equalTo(self.view.right).offset(-10);
    }];
}

-(void)goScannerViewController
{
    QRCScannerViewController *VC = [[QRCScannerViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark - datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    ipModel* ip = _dataArray[indexPath.row];
    cell.titleLab.text = ip.host;
    cell.contentLab.text = ip.wifiName;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

#pragma mark - delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self getWifiName];
    ipModel* ip = _dataArray[indexPath.row];
    if ([_currentWifiName isEqualToString:ip.wifiName]) {
        UIStoryboard* storyborard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TelnetTableViewController* tvc = [storyborard instantiateViewControllerWithIdentifier:NSStringFromClass([TelnetTableViewController class])];
        tvc.wifiName = ip.wifiName;
        tvc.password = ip.wifiPass;
        tvc.type = 1;
        tvc.host = ip.host;
        [self.navigationController pushViewController:tvc animated:YES];
    }else{
        self.alertView.wfiiLab.text = ip.wifiName;
        _alertView.passwordLab.text = ip.wifiPass;
//        _alertView.titleLab.text = @"请连接到下面Wi-Fi";
        [_alertView pop];
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ipModel* ip = _dataArray[indexPath.row];
        BOOL result = [[TelDataBase shareTelDataBase]deleteDataWithWifiName:ip.wifiName];
        if (result) {
            [_dataArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
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
