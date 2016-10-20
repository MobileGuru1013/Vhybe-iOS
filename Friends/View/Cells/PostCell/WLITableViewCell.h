//
//  WLITableViewCell.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIUser.h"
#import "WLIPost.h"

@class WLITableViewCell;

@protocol WLICellDelegate <NSObject>

- (void)showUser:(WLIUser*)user sender:(id)senderCell;
- (void)showImageForPost:(WLIPost*)post sender:(id)senderCell;
- (void)toggleLikeForPost:(WLIPost*)post sender:(id)senderCell;
- (void)showCommentsForPost:(WLIPost*)post sender:(id)senderCell;
- (void)showLikesForPost:(WLIPost *)post sender:(id)senderCell;
- (void)followUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender;
- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender;

@end

@interface WLITableViewCell : UITableViewCell

@end
