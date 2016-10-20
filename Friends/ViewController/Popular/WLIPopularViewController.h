//
//  WLIPopularViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLIPopularViewController : WLIViewController <WLIViewControllerRefreshProtocol,UITableViewDataSource,UITableViewDelegate>{
    
    BOOL loadingPopular;
    BOOL loadingRecent;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlPopularRecent;

@property (strong, nonatomic) NSArray *popularPosts;
@property (strong, nonatomic) NSArray *recentPosts;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Background;
@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;

- (IBAction)segmentedControlPopularRecentValueChanged:(UISegmentedControl *)sender;

@end
