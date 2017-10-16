//
//  smallSwitch.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/30.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "smallSwitch.h"

@implementation smallSwitch

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.transform = CGAffineTransformMakeScale(0.9,0.9);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
