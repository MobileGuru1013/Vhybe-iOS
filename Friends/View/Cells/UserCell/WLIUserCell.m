//
//  WLIUserCell.m
//  Friends
//
//  Created by Planet 1107 on 07/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIUserCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSString+FontAwesome.h"

@implementation WLIUserCell

#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.imageViewUserImage.layer.cornerRadius = self.imageViewUserImage.frame.size.height/2;
    self.imageViewUserImage.layer.masksToBounds = YES;
    self.buttonFollowUnfollow.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.cellBtn_Chat.titleLabel.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
}


#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.imageViewUserImage setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
    self.labelUserName.text = self.user.userFullName;
//    if (self.user.followingUser) {
//        [self.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
//    } else {
//        [self.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
//    }
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.user sender:self];
    }
}

- (IBAction)buttonFollowUnfollowTouchUpInside:(UIButton *)sender {
    
    if ([sender tag] == 1 || [sender tag] == 3) {
        if ([self.delegate respondsToSelector:@selector(unfollowUser:sender:buttonTag:)]) {
            [self.delegate unfollowUser:self.user sender:self buttonTag:sender];
        }
    } else if ([sender tag] == 2 || [sender tag] == 4){
        if ([self.delegate respondsToSelector:@selector(followUser:sender:buttonTag:)]) {
            [self.delegate followUser:self.user sender:self buttonTag:sender];
        }
    }
}

@end
