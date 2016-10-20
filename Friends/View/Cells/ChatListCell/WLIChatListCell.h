//
//  WLIChatListCell.h
//  Friends
//
//  Created by Kapil on 29/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIUser.h"
#import "WLITableViewCell.h"

@interface WLIChatListCell : WLITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lbl_UserName;
@property (strong, nonatomic) IBOutlet UILabel *lbl_LastChat;
@property (strong, nonatomic) IBOutlet UILabel *lbl_UnreadCount;
@property (strong, nonatomic) IBOutlet UILabel *lbl_TimeStamp;
@property (strong, nonatomic) IBOutlet UIImageView *imgv_UserImage;
@property (weak, nonatomic) IBOutlet UIButton *btn_ShowChatDetails;
- (IBAction)ChatDetailsButtonTouchUpInside:(id)sender;

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<WLICellDelegate> delegate;
@end
