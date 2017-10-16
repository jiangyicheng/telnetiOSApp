//
//  popViewController.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/24.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,PopType) {
    PopTypeMode = 1,
    PopTypeServiceBland,
};

@interface popViewController : UIViewController

@property(nonatomic,strong)NSArray* titleArr;
@property(nonatomic,assign)PopType type;

@end
