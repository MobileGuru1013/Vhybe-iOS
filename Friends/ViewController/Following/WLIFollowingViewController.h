//
//  WLIFollowingViewController.h
//  Friends
//
//  Created by Planet 1107 on 03/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIViewController.h"

@interface WLIFollowingViewController : WLIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) WLIUser *user;
@property (strong, nonatomic) NSMutableArray *following;

@end
