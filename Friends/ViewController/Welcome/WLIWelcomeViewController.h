//
//  WLIWelcomeViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLILoginViewController.h"
#import "WLIRegistrationViewController.h"

@protocol WLIWelcomeViewControllerDelegate <NSObject>

- (void)showLogin;
- (void)showRegister;

@end

@interface WLIWelcomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageViewLogo;
@property (weak, nonatomic) id <WLIWelcomeViewControllerDelegate> delegate;

- (IBAction)buttonLoginTouchUpInside:(id)sender;
- (IBAction)buttonRegisterTouchUpInside:(id)sender;

@end
