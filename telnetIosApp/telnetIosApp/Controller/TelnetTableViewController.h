//
//  TelnetTableViewController.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/7.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TelnetTableViewController : UITableViewController

/**  wifi  name */
@property(nonatomic,strong)NSString* wifiName;

/**  password */
@property(nonatomic,strong)NSString* password;

/**  host */
@property(nonatomic,strong)NSString* host;

/**  type  1 点击列表进入 2 扫码进入 3 点击导航栏图标进入 */
@property(nonatomic,assign)NSInteger type;

-(NSString*)getFtpUserName;
-(NSString*)getFtpPWD;

@end
