//
//  cloudAndPwdAlertView.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/23.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface cloudAndPwdAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *wfiiLab;
@property (weak, nonatomic) IBOutlet UILabel *passwordLab;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
- (void)pop ;
@end
