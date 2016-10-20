//
//  WLIPostCollectionViewCell.h
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIPost.h"
#import "WLITableViewCell.h"

@interface WLIPostCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPost;

@property (strong, nonatomic) WLIPost *post;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

@end
