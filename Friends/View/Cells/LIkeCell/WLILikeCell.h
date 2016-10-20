//
//  WLILikeCell.h
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLITableViewCell.h"
#import "WLILike.h"

@interface WLILikeCell : WLITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;

@property (assign, nonatomic) id<WLICellDelegate> delegate;
@property (strong, nonatomic) WLILike *like;

- (IBAction)buttonUserTouchUpInside:(id)sender;
+ (CGSize)sizeWithLike:(WLILike *)like;

@end
