//
//  MainTableViewCell.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/30.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *titleImageV;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;

@end
