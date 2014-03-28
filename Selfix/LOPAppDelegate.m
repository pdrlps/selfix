//
//  LOPAppDelegate.m
//  Selfix
//
//  Created by Pedro Lopes on 26/03/14.
//  Copyright (c) 2014 Pedro Lopes. All rights reserved.
//

#import "LOPAppDelegate.h"

#import <SimpleAuth/SimpleAuth.h>

@implementation LOPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    SimpleAuth.configuration[@"instagram"] = @{
                                               @"client_id" : @"703e58325e474f099e72dbc5969fdeee",
                                               SimpleAuthRedirectURIKey : @"selfix://auth/instagram"
                                               };
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // configure root and photos view controllers
    LOPPhotosViewController *photosViewController = [[LOPPhotosViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:photosViewController];
    self.window.rootViewController = navigationController;
    
    // configure top navigation bar
    UINavigationBar *navBar = navigationController.navigationBar;
    navBar.barTintColor = [UIColor colorWithRed:0.43 green:0.44 blue:0.76 alpha:1];
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
