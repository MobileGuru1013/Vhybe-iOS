//
//  WLIViewController.h
//  Friends
//
//  Created by Planet 1107 on 9/30/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PNTToolbar.h"
#import "WLIPostCell.h"
#import "MNMPullToRefreshManager.h"
#import "WLIConnect.h"

@protocol WLIViewControllerRefreshProtocol <NSObject>

@property (strong, nonatomic) UITableView *tableViewRefresh;
- (void)reloadData:(BOOL)reloadAll;

@end

@interface WLIViewController : UIViewController <WLICellDelegate, MNMPullToRefreshManagerClient> {
    
    PNTToolbar *toolbar;
    MNMPullToRefreshManager *refreshManager;
    MBProgressHUD *hud;
    BOOL loadMore;
    BOOL loading;
    __weak WLIConnect *sharedConnect;
}

@end
