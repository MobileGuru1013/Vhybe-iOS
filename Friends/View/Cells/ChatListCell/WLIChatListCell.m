//
//  WLIChatListCell.m
//  Friends
//
//  Created by Kapil on 29/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIChatListCell.h"
#import "UIImageView+AFNetworking.h"

@implementation WLIChatListCell

#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.imgv_UserImage.layer.cornerRadius = self.imgv_UserImage.frame.size.height/2;
    self.imgv_UserImage.layer.masksToBounds = YES;
}

#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.imgv_UserImage setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
    self.lbl_UserName.text = self.user.userFullName;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)ChatDetailsButtonTouchUpInside:(id)sender {
    if ([self.delegate respondsToSelector:@selector(followUser:sender:buttonTag:)]) {
        [self.delegate followUser:self.user sender:self buttonTag:sender];
    }
}
@end
