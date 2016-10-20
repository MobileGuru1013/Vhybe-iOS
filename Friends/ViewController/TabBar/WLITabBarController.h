//
//  WLITabBarController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIWelcomeViewController.h"

@interface WLITabBarController : UITabBarController <WLIWelcomeViewControllerDelegate> {
    WLIWelcomeViewController *welcomeViewController;
}

@end
