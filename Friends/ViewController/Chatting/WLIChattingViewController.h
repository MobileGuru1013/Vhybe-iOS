//
//  WLIChattingViewController.h
//  Friends
//
//  Created by The Pranav Khandelwal on 5/25/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLIChattingViewController : WLIViewController

@property (strong,nonatomic) NSString *channelID;
@property (strong,nonatomic) WLIUser *toUserID;
@property (nonatomic, copy) void(^completion)(NSString *backVC);

- (void)receiveMessage:(NSNotification*)notification;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil completion:(void(^)(NSString *))completion;


@end
