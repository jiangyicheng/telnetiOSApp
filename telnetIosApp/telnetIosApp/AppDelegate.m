//
//  AppDelegate.m
//  telnetIosApp
//
//  Created by 姜易成 on 2017/8/7.
//  Copyright © 2017年 姜易成. All rights reserved.
//

#import "AppDelegate.h"
#import "RealReachability.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark - 设置屏幕横竖屏
//_allowRotation = 1 时 屏幕支持横屏
//_allowRotation = 2 时 屏幕支持竖屏
//否则的话横竖屏都支持
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if (_allowRotation == 1) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    else if(_allowRotation == 2)
    {
        return (UIInterfaceOrientationMaskPortrait);
    }
    return UIInterfaceOrientationMaskAll;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [GLobalRealReachability startNotifier];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
