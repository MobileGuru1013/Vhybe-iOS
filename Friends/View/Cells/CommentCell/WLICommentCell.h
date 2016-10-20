//
//  WLICommentCell.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIComment.h"
#import "WLITableViewCell.h"

@interface WLICommentCell : WLITableViewCell {
    
    CGRect frameDefaultLabelCommentText;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUsername;
@property (strong, nonatomic) IBOutlet UILabel *labelTimeAgo;
@property (strong, nonatomic) IBOutlet UILabel *labelCommentTtext;

@property (strong, nonatomic) WLIComment *comment;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

- (IBAction)buttonUserTouchUpInside:(id)sender;
+ (CGSize)sizeWithComment:(WLIComment *)comment;

@end
