//
//  ConfigTableViewController.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/24.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIView *connectStyleView;
@property (weak, nonatomic) IBOutlet UIButton *connectStyleBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorCodeLab;
@property (weak, nonatomic) IBOutlet UIButton *serviceBlandClassBtn;
@property (weak, nonatomic) IBOutlet UILabel *VLANIDLab;
@property (weak, nonatomic) IBOutlet UILabel *priorityLab;
@property (weak, nonatomic) IBOutlet UISwitch *VLANSch;
@property (weak, nonatomic) IBOutlet UISwitch *LAN1Sch;
@property (weak, nonatomic) IBOutlet UISwitch *LAN2Sch;
@property (weak, nonatomic) IBOutlet UISwitch *LAN3Sch;
@property (weak, nonatomic) IBOutlet UISwitch *LAN4Sch;
@property (weak, nonatomic) IBOutlet UISwitch *wifi1Sch;
@property (weak, nonatomic) IBOutlet UISwitch *wifi2Sch;
@property (weak, nonatomic) IBOutlet UISwitch *wifi3Sch;
@property (weak, nonatomic) IBOutlet UIImageView *netStatus;
@property (weak, nonatomic) IBOutlet UISwitch *wifi4Sch;
/**  wifi  name */
@property(nonatomic,strong)NSString* wifiName;

/**  password */
@property(nonatomic,strong)NSString* password;

@end
