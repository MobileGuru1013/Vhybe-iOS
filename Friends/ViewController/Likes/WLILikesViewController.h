//
//  WLILikesViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLILikesViewController : WLIViewController

@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) WLIPost *post;
@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;

@end
