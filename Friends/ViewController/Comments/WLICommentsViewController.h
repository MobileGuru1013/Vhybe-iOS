//
//  WLICommentsViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLICommentsViewController : WLIViewController <WLIViewControllerRefreshProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSMutableArray *comments;
@property (strong, nonatomic) IBOutlet UIView *viewEnterComment;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEnterComment;
@property (strong, nonatomic) WLIPost *post;
@property (strong, nonatomic) IBOutlet UILabel *lbl_Comment;

@end
