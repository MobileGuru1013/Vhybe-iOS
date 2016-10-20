//
//  WLITimelineViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLITimelineViewController : WLIViewController <WLIViewControllerRefreshProtocol,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSArray *posts;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Background;


@end
