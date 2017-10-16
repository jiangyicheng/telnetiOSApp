//
//  SocketProtocol.h
//  YongShang
//
//  Created by user on 16/10/10.
//  Copyright © 2016年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

@interface YSSocketProtocol : NSObject
<GCDAsyncSocketDelegate>

@property(nonatomic, strong)NSString *tag;

@property(nonatomic,assign)BOOL isPush;

@property(nonatomic,assign)NSInteger disConectType;

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;

+ (YSSocketProtocol *)shareSocketProtocol;

- (void)socketConnectWithHost:(NSString*)host andPort:(uint16_t)port;

-(void)disConnectToHost;

-(BOOL)isConnect;

-(void)updateDonfigData;

-(void)setData;

-(void)pppoeerrcode;

@end
