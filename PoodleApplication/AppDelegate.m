//
//  AppDelegate.m
//  Poodle
//
//  Created by Poodle on 2020/3/3.
//  Copyright © 2020 Poodle. All rights reserved.
//

#import "AppDelegate.h"
#import "PDLToolKit_iOS.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"%s", sel_getName(_cmd));

    return YES;
}

@end
