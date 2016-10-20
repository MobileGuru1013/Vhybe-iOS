//
//  WLIUserCell.h
//  Friends
//
//  Created by Planet 1107 on 07/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIUser.h"
#import "WLITableViewCell.h"

@interface WLIUserCell : WLITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUserImage;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollowUnfollow;
@property (strong, nonatomic) IBOutlet UIButton *cellBtn_Chat;

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

- (IBAction)buttonFollowUnfollowTouchUpInside:(UIButton *)sender;

@end
