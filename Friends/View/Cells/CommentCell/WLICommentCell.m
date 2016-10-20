//
//  WLICommentCell.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLICommentCell.h"
#import "UIImageView+AFNetworking.h"

static WLICommentCell *sharedCell = nil;

@implementation WLICommentCell

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
    frameDefaultLabelCommentText = self.labelCommentTtext.frame;
    //frameDefaultImageViewPost = self.imageViewPostImage.frame;
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height/2;
    self.imageViewUser.layer.masksToBounds = YES;
}


#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateFramesAndDataWithDownloads:YES];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    self.labelCommentTtext.frame = frameDefaultLabelCommentText;
}

+ (CGSize)sizeWithComment:(WLIComment *)comment {
    
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLICommentCell" owner:nil options:nil] lastObject];
    }
    [sharedCell prepareForReuse];
    sharedCell.comment = comment;
    [sharedCell updateFramesAndDataWithDownloads:NO];
    
    return CGSizeMake(sharedCell.frame.size.width, CGRectGetMaxY(sharedCell.labelCommentTtext.frame) + 10.0f);
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    if (self.comment && ![self.comment isEqual:[NSNull null]]) {
        
        if (downloads) {
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.comment.user.userAvatarPath]];
        }
        
        self.labelUsername.text = self.comment.user.userFullName;
        self.labelTimeAgo.text = @"";
        
        //Set and resize
        self.labelCommentTtext.text = self.comment.commentText;
        [self.labelCommentTtext sizeToFit];
        if (self.labelCommentTtext.frame.size.width < frameDefaultLabelCommentText.size.width) {
            self.labelCommentTtext.frame = CGRectMake(self.labelCommentTtext.frame.origin.x, self.labelCommentTtext.frame.origin.y, frameDefaultLabelCommentText.size.width, self.labelCommentTtext.frame.size.height);
        }
        if (self.labelCommentTtext.frame.size.height < frameDefaultLabelCommentText.size.height) {
            self.labelCommentTtext.frame = CGRectMake(self.labelCommentTtext.frame.origin.x, self.labelCommentTtext.frame.origin.y, self.labelCommentTtext.frame.size.width, frameDefaultLabelCommentText.size.height);
        }
        //Set and resize done
    }
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.comment.user sender:self];
    }
}

@end
