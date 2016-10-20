//
//  WLISearchViewController.h
//  Friends
//
//  Created by Planet 1107 on 09/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLISearchViewController : WLIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableViewSearch;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarSearchUsers;

@property (strong, nonatomic) NSMutableArray *users;

@end
