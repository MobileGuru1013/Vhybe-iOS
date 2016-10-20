//
//  WLIPostCell.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITableViewCell.h"
#import "WLIPost.h"
#import "UIImageView+AFNetworking.h"

@class WLIPostCell;

@interface WLIPostCell : WLITableViewCell {
    
    CGRect frameDefaultLabelPostTitle;
    CGRect frameDefaultImageViewPost;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelPostTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPostImage;
@property (strong, nonatomic) IBOutlet UIButton *buttonLike;
@property (strong, nonatomic) IBOutlet UIButton *buttonComment;
@property (strong, nonatomic) IBOutlet UIButton *buttonLikes;
@property (weak, nonatomic) IBOutlet UIButton *buttonGoToPost;
@property (weak, nonatomic) IBOutlet UIView *ImageBottomView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_CommentCount;

@property (strong, nonatomic) WLIPost *post;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

- (IBAction)buttonUserTouchUpInside:(id)sender;
- (IBAction)buttonPostTouchUpInside:(id)sender;
- (IBAction)buttonLikeTouchUpInside:(id)sender;
- (IBAction)buttonCommentTouchUpInside:(id)sender;
- (IBAction)buttonLikesTouchUpInside:(id)sender;

+ (CGSize)sizeWithPost:(WLIPost*)post;


@end
