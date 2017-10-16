//
//  ipModel.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/29.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ipModel : NSObject

/**   */
@property(nonatomic,copy)NSString* host;
/**   */
@property(nonatomic,copy)NSString* port;
/**   */
@property(nonatomic,copy)NSString* wifiName;
/**   */
@property(nonatomic,copy)NSString* wifiPass;

@end
