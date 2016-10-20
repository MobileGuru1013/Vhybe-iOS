//
//  WLIAppDelegate.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLITabBarController.h"
#import <CoreLocation/CoreLocation.h>

@interface WLIAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WLITabBarController *tabBarController;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)createViewHierarchy;

@end
