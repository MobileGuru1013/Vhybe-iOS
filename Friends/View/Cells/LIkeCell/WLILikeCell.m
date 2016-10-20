//
//  WLILikeCell.m
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILikeCell.h"
#import "UIImageView+AFNetworking.h"

static WLILikeCell *sharedCell = nil;

@implementation WLILikeCell

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
}

+ (CGSize)sizeWithLike:(WLILike *)like {
    
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLILikeCell" owner:nil options:nil] lastObject];
    }
    [sharedCell prepareForReuse];
    return sharedCell.frame.size;
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    if (self.like) {
        if (downloads) {
            NSURL *userImageURL = [NSURL URLWithString:self.like.user.userAvatarPath];
            NSMutableURLRequest *userImageRequest = [NSMutableURLRequest requestWithURL:userImageURL cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:120.0];
            __weak WLILikeCell *weakSelf = self;
            [self.imageViewUser setImageWithURLRequest:userImageRequest placeholderImage:[UIImage imageNamed:@""] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakSelf.imageViewUser.image = image;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { }];
        }
        self.labelUsername.text = self.like.user.userFullName;
    }
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.like.user sender:self];
    }
}

@end
