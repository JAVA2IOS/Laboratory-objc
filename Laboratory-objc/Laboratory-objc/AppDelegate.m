//
//  AppDelegate.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarController.h"
//#import "LABAudioManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioManagerInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    // 移除main.storyboard 时，需要重新初始化window
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    
    BaseTabBarController *baseTab = [[BaseTabBarController alloc] init];
    self.window.rootViewController = baseTab;
    [self.window makeKeyAndVisible];
    return YES;
}

/**
 中断
 - (void)audioManagerInterruption:(NSNotification *)notification {
 NSDictionary *userInfo = notification.userInfo;
 if ([[userInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue] == AVAudioSessionInterruptionTypeBegan) {
 NSLog(@"中断录音或者播放");
 [[LABAudioManager sharedInstance] stopRecordOrAudio];
 }
 }
 */



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//    [[LABAudioManager sharedInstance] stopRecordOrAudio];
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
