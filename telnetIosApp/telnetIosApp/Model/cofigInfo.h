//
//  cofigInfo.h
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/30.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cofigInfo : NSObject

@property (nonatomic, strong)NSString *Service1Enable;
@property (nonatomic, strong)NSString *Service1name;
@property (nonatomic, strong)NSString *Service1Servicelist;
@property (nonatomic, strong)NSString *Service1VlanId;
@property (nonatomic, strong)NSString *Service1VlanPri;
@property (nonatomic, strong)NSString *Service1Mode;
@property (nonatomic, strong)NSString *Service1Portmap;
@property (nonatomic, strong)NSString *wan_dhcp_option60_enabled;
@property (nonatomic, strong)NSString *wan_vendor;
@property (nonatomic, strong)NSString *wanConnectionMode;
@property (nonatomic, strong)NSString *wan_ipaddr;
@property (nonatomic, strong)NSString *wan_netmask;
@property (nonatomic, strong)NSString *wan_gateway;
@property (nonatomic, strong)NSString *wan_primary_dns;
@property (nonatomic, strong)NSString *wan_secondary_dns;
@property (nonatomic, strong)NSString *wan_pppoe_user;
@property (nonatomic, strong)NSString *wan_pppoe_pass;
@property (nonatomic, strong)NSString *reachabilityStatus;

@property (nonatomic, strong)NSString *set_Service1Enable;
@property (nonatomic, strong)NSString *set_Service1name;
@property (nonatomic, strong)NSString *set_Service1Servicelist;
@property (nonatomic, strong)NSString *set_Service1VlanId;
@property (nonatomic, strong)NSString *set_Service1VlanPri;
@property (nonatomic, strong)NSString *set_Service1Mode;
@property (nonatomic, strong)NSString *set_Service1Portmap;
@property (nonatomic, strong)NSString *set_wan_dhcp_option60_enabled;
@property (nonatomic, strong)NSString *set_wan_vendor;
@property (nonatomic, strong)NSString *set_wanConnectionMode;
@property (nonatomic, strong)NSString *set_wan_ipaddr;
@property (nonatomic, strong)NSString *set_wan_netmask;
@property (nonatomic, strong)NSString *set_wan_gateway;
@property (nonatomic, strong)NSString *set_wan_primary_dns;
@property (nonatomic, strong)NSString *set_wan_secondary_dns;
@property (nonatomic, strong)NSString *set_wan_pppoe_user;
@property (nonatomic, strong)NSString *set_wan_pppoe_pass;
@property (nonatomic, strong)NSString *set_reachabilityStatus;

@property (nonatomic, strong)NSString *pppoeerrcode;

+ (instancetype)sharedInstance;

@end
