//
//  LOPAppDelegate.m
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPAppDelegate.h"

#import <SimpleAuth/SimpleAuth.h>
#import <Crashlytics/Crashlytics.h>

@implementation LOPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // instagram OAuth2
    SimpleAuth.configuration[@"instagram"] = @{
                                               @"client_id" : @"ea83702d7ef54da0b1f58eb3121b0178",
                                               SimpleAuthRedirectURIKey : @"selfix://auth/instagram"
                                               };
    // Crashlytics startup
    [Crashlytics startWithAPIKey:@"23fc3a72601974bf2932492e8609d82c6ca052fc"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // configure root and photos view controllers
    LOPPhotosViewController *photosViewController = [[LOPPhotosViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photosViewController];
    self.window.rootViewController = navigationController;
    
    // configure top navigation bar
    UINavigationBar *navBar = navigationController.navigationBar;
    navBar.barTintColor = [UIColor colorWithRed:0.24 green:0.72 blue:0.69 alpha:1];
    navBar.barStyle = UIBarStyleBlackOpaque;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
