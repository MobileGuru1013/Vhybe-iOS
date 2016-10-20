//
//  WLIPostCollectionViewCell.m
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "WLIConnect.h"

static WLIPostCollectionViewCell *sharedCell = nil;

@implementation WLIPostCollectionViewCell


#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - Cell methods

- (void)prepareForReuse {
    
    [super prepareForReuse];
    [self.imageViewPost cancelImageRequestOperation];
    self.imageViewPost.image = nil;
}


#pragma mark - Action methods

- (IBAction)buttonPostTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showImageForPost:sender:)] && self.post.postImagePath.length) {
        [self.delegate showImageForPost:self.post sender:self];
    }
}


@end
