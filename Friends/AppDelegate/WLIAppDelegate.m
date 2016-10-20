//
//  WLIAppDelegate.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIAppDelegate.h"
#import "WLINewPostViewController.h"
#import "WLINearbyViewController.h"
#import "WLIPopularViewController.h"
#import "WLIProfileViewController.h"
#import "WLITimelineViewController.h"
#import "WLISearchPostViewController.h"
#import "WLIFriendsViewController.h"
#import "WLIConnect.h"
#import "DatabaseManager.h"
#import "UIImage+FontAwesome.h"

@implementation WLIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
       [self.window makeKeyAndVisible];
    
    CLAuthorizationStatus locationAuthorizationStatus = [CLLocationManager authorizationStatus];
    if (locationAuthorizationStatus != kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f) {
            [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
        }
    }
    
    [self createViewHierarchy];
    [[DatabaseManager getInstance] setupDatabase];
    
    //Push Notification
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // Register for Push Notitications
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    // navigation bar appearance
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0f/255.0f green:80.0f/255.0f blue:70.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back64.png"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back44.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    
    // status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window.backgroundColor = [UIColor whiteColor];
 
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController  shouldSelectViewController:(UIViewController *)viewController {
    
    UINavigationController *navigationViewController = (UINavigationController *)viewController;
    if ([navigationViewController.topViewController isKindOfClass:[WLINewPostViewController class]]) {
        WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
        UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
        newPostNavigationController.navigationBar.translucent = NO;
        [tabBarController presentViewController:newPostNavigationController animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Other methods

- (void)createViewHierarchy {
    
    WLITimelineViewController *timelineViewController = [[WLITimelineViewController alloc] initWithNibName:@"WLITimelineViewController" bundle:nil];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.navigationBar.translucent = NO;
    
    WLIPopularViewController *popularViewController = [[WLIPopularViewController alloc] initWithNibName:@"WLIPopularViewController" bundle:nil];
    UINavigationController *popularNavigationController = [[UINavigationController alloc] initWithRootViewController:popularViewController];
    popularNavigationController.navigationBar.translucent = NO;
    
    /*WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;*/
    
    WLISearchPostViewController *searchPostViewController = [[WLISearchPostViewController alloc] initWithNibName:@"WLISearchPostViewController" bundle:nil];    
    UINavigationController *searchPostNavigationController = [[UINavigationController alloc] initWithRootViewController:searchPostViewController];
    searchPostNavigationController.navigationBar.translucent = NO;
    
    /*WLINearbyViewController *nearbyViewController = [[WLINearbyViewController alloc] initWithNibName:@"WLINearbyViewController" bundle:nil];
    UINavigationController *nearbyNavigationController = [[UINavigationController alloc] initWithRootViewController:nearbyViewController];
    nearbyNavigationController.navigationBar.translucent = NO;*/
    
    WLIFriendsViewController *friendsViewController = [[WLIFriendsViewController alloc] initWithNibName:@"WLIFriendsViewController" bundle:nil];
    UINavigationController *friendsNavigationController = [[UINavigationController alloc] initWithRootViewController:friendsViewController];
    friendsNavigationController.navigationBar.translucent = NO;
    
    WLIProfileViewController *profileViewController = [[WLIProfileViewController alloc] initWithNibName:@"WLIProfileViewController" bundle:nil];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    profileNavigationController.navigationBar.translucent = NO;
    
    self.tabBarController = [[WLITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[timelineNavigationController, popularNavigationController,searchPostNavigationController, friendsNavigationController, profileNavigationController];

    UITabBarItem *timelineTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageWithIcon:@"fa-paper-plane-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageWithIcon:@"fa-paper-plane-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    timelineTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    timelineViewController.tabBarItem = timelineTabBarItem;
    UITabBarItem *popularTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageWithIcon:@"fa-heart-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageWithIcon:@"fa-heart-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    popularTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    popularViewController.tabBarItem = popularTabBarItem;
    UITabBarItem *searchPostTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageWithIcon:@"fa-search" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageWithIcon:@"fa-search" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    searchPostTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    searchPostViewController.tabBarItem = searchPostTabBarItem;
    UITabBarItem *friendsTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageWithIcon:@"fa-comments-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageWithIcon:@"fa-comments-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    friendsTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    friendsViewController.tabBarItem = friendsTabBarItem;
    UITabBarItem *profileTabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:[[UIImage imageWithIcon:@"fa-user" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageWithIcon:@"fa-user" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:35] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    profileTabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    profileViewController.tabBarItem = profileTabBarItem;
    
    self.window.rootViewController = self.tabBarController;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    NSString* strDeviceToken = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                              stringByReplacingOccurrencesOfString: @" " withString: @""];
    [[NSUserDefaults standardUserDefaults] setObject:strDeviceToken forKey:@"UserDeviceToken"];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in RegisterForRemoteNotifications: %@",error);
}

@end
