//
//  WLIProfileViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIConnect.h"
#import "UIImageView+AFNetworking.h"
#import "WLIViewController.h"

@interface WLIProfileViewController : WLIViewController <UIAlertViewDelegate> {
    WLIUser *_user;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUserProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowingCount;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowersCount;

@property (strong, nonatomic) IBOutlet UILabel *labelAddress;
@property (strong, nonatomic) IBOutlet UILabel *labelPhone;
@property (strong, nonatomic) IBOutlet UILabel *labelWeb;
@property (strong, nonatomic) IBOutlet UILabel *labelEmail;

@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonSearchUsers;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogout;

@property (strong, nonatomic, setter = setUser:) WLIUser *user;

- (IBAction)buttonFollowToggleTouchUpInside:(id)sender;
- (IBAction)buttonFollowingTouchUpInside:(id)sender;
- (IBAction)buttonFollowersTouchUpInside:(id)sender;
- (IBAction)buttonSearchUsersTouchUpInside:(id)sender;
- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender;

@end
