//
//  cloudAndPwdAlertView.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/23.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "cloudAndPwdAlertView.h"

@implementation cloudAndPwdAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)pop {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)cancleBtnClick:(id)sender {
    [self dismissPop];
}
- (IBAction)copyBtnClick:(id)sender {
    [self dismissPop];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.passwordLab.text;
    NSString * urlString = @"App-Prefs:root=WIFI";
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            
        } else {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }
        
    }
}

-(void)dismissPop
{
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
