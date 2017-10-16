//
//  Config.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/30.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS
#import <Masonry.h>
#import <SVProgressHUD.h>
//屏幕宽高
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface Config : NSObject

UIColor* getColor(NSString * hexColor);

@end
