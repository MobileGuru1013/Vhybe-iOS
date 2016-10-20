//
//  WLIPostCell.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCell.h"
#import "WLIConnect.h"

static WLIPostCell *sharedCell = nil;

@implementation WLIPostCell

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    frameDefaultLabelPostTitle = self.labelPostTitle.frame;
    //frameDefaultImageViewPost = self.imageViewPostImage.frame;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doSingleTap)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageViewPostImage addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(doDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageViewPostImage addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height/2;
    self.imageViewUser.layer.masksToBounds = YES;
}

#pragma mark - GestureRecognizer

-(void)doSingleTap
{
    [self buttonPostTouchUpInside:nil];
}

-(void)doDoubleTap
{
    [self buttonLikeTouchUpInside:nil];
}

#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateFramesAndDataWithDownloads:YES];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    self.imageViewUser.image = nil;
    [self.imageViewPostImage cancelImageRequestOperation];
    self.imageViewPostImage.image = nil;
    self.labelPostTitle.frame = frameDefaultLabelPostTitle;
}

+ (CGSize)sizeWithPost:(WLIPost*)post {
    
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:nil options:nil] lastObject];
    }
    [sharedCell prepareForReuse];
    sharedCell.post = post;
    [sharedCell updateFramesAndDataWithDownloads:NO];
    
    CGSize size = CGSizeMake(sharedCell.frame.size.width, CGRectGetMaxY(sharedCell.labelPostTitle.frame) + 8.0f +10.0f);
    
    return size;
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    if (self.post) {
        if (downloads) {
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.post.user.userAvatarPath]];
        }
        self.labelUserName.text = self.post.user.userFullName;
        self.labelTimeAgo.text = self.post.postTimeAgo;
        
        //Set and resize
        self.labelPostTitle.text = self.post.postTitle;
        [self.labelPostTitle sizeToFit];
        if (self.labelPostTitle.frame.size.width < frameDefaultLabelPostTitle.size.width) {
            self.labelPostTitle.frame = CGRectMake(self.labelPostTitle.frame.origin.x, self.labelPostTitle.frame.origin.y, frameDefaultLabelPostTitle.size.width, self.labelPostTitle.frame.size.height);
        }
        if (self.labelPostTitle.frame.size.height < frameDefaultLabelPostTitle.size.height) {
            self.labelPostTitle.frame = CGRectMake(self.labelPostTitle.frame.origin.x, self.labelPostTitle.frame.origin.y, self.labelPostTitle.frame.size.width, frameDefaultLabelPostTitle.size.height);
        }
        //Set and resize done
        
        if (self.post.postImagePath.length) {
            self.buttonLike.frame = CGRectMake(self.buttonLike.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) -self.buttonLike.frame.size.height, self.buttonLike.frame.size.width, self.buttonLike.frame.size.height);
            self.buttonComment.frame = CGRectMake(self.buttonComment.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) -self.buttonComment.frame.size.height, self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
            self.lbl_CommentCount.frame = CGRectMake(self.buttonComment.frame.origin.x-self.lbl_CommentCount.frame.size.width, CGRectGetMaxY(self.imageViewPostImage.frame) -self.buttonComment.frame.size.height, self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
            self.buttonLikes.frame = CGRectMake(self.buttonLikes.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) -self.buttonLike.frame.size.height, self.buttonLikes.frame.size.width, self.buttonLikes.frame.size.height);
            self.ImageBottomView.hidden = NO;
            self.buttonGoToPost.frame = self.imageViewPostImage.frame;
            
            
            if (downloads) {
                [self.imageViewPostImage setImageWithURL:[NSURL URLWithString:self.post.postImagePath]];
            }
        } else {
            self.buttonLike.frame = CGRectMake(self.buttonLike.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonLike.frame.size.width, self.buttonLike.frame.size.height);
            self.buttonComment.frame = CGRectMake(self.buttonComment.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
            self.lbl_CommentCount.frame = CGRectMake(self.buttonComment.frame.origin.x-self.lbl_CommentCount.frame.size.width, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
            self.buttonLikes.frame = CGRectMake(self.buttonLikes.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonLikes.frame.size.width, self.buttonLikes.frame.size.height);
            CGRect frame = self.labelPostTitle.frame;
            frame.origin.y = self.buttonLike.frame.origin.y+self.buttonLike.frame.size.height;
            self.labelPostTitle.frame = frame;
            self.buttonGoToPost.frame = self.labelPostTitle.frame;
            self.ImageBottomView.hidden = YES;
        }
        
        if (self.post.likedThisPost) {
            [self.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
        } else {
            [self.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
        }
        
        if (self.post.postLikesCount == 1) {
            [self.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", self.post.postLikesCount] forState:UIControlStateNormal];
        } else {
            [self.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", self.post.postLikesCount] forState:UIControlStateNormal];
        }
    }
    self.lbl_CommentCount.text = [NSString stringWithFormat:@"%d",self.post.postCommentsCount];
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.post.user sender:self];
    }
}

- (IBAction)buttonPostTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showImageForPost:sender:)]) {
        [self.delegate showImageForPost:self.post sender:self];
    }
}

- (IBAction)buttonLikeTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(toggleLikeForPost:sender:)]) {
        [self.delegate toggleLikeForPost:self.post sender:self];
    }
}

- (IBAction)buttonCommentTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCommentsForPost:sender:)]) {
        [self.delegate showCommentsForPost:self.post sender:self];
    }
}

- (IBAction)buttonLikesTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showLikesForPost:sender:)]) {
        [self.delegate showLikesForPost:self.post sender:self];
    }
}

@end
