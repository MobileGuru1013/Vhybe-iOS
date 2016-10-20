//
//  WLIViewController.m
//  Friends
//
//  Created by Planet 1107 on 9/30/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIViewController.h"
#import "WLICommentsViewController.h"
#import "WLILikesViewController.h"
#import "WLIProfileViewController.h"
#import "WLIPostViewController.h"
#import "ChatManager.h"
#import "NSString+FontAwesome.h"

@implementation WLIViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        sharedConnect = [WLIConnect sharedConnect];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    toolbar = [PNTToolbar defaultToolbar];
    if ([self conformsToProtocol:@protocol(WLIViewControllerRefreshProtocol)]) {
        id<WLIViewControllerRefreshProtocol> objectConformsToProtocol = (id<WLIViewControllerRefreshProtocol>)self;
        refreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:objectConformsToProtocol.tableViewRefresh withClient:self];
    }
    loadMore = YES;
    
    if (self.navigationController.viewControllers.count > 1) {
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.adjustsImageWhenHighlighted = NO;
        backButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
        //[backButton setImage:[UIImage imageNamed:@"nav-btn-back.png"] forState:UIControlStateNormal];
        [backButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
        backButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [backButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-arrow-left"] forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(barButtonItemBackTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    } else if (self.presentingViewController) {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.adjustsImageWhenHighlighted = NO;
        cancelButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
        //[cancelButton setImage:[UIImage imageNamed:@"nav-btn-close.png"] forState:UIControlStateNormal];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [cancelButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times"] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(barButtonItemCancelTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions methods

- (void)barButtonItemBackTouchUpInside:(UIButton*)backButton {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)barButtonItemCancelTouchUpInside:(UIButton*)backButton {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    [[ChatManager getInstance] chatServerClose];
}


#pragma mark - WLIPostCellDelegate methods

- (void)showUser:(WLIUser*)user sender:(WLIPostCell*)senderCell {
    
    WLIProfileViewController *profileViewController = [[WLIProfileViewController alloc] initWithNibName:@"WLIProfileViewController" bundle:nil];
    profileViewController.user = user;
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)showImageForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
    if (![self isMemberOfClass:[WLIPostViewController class]]) {
        WLIPostViewController *postViewController = [[WLIPostViewController alloc] initWithNibName:@"WLIPostViewController" bundle:nil];
        postViewController.post = post;
        [self.navigationController pushViewController:postViewController animated:YES];
    }
}

- (void)toggleLikeForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
}

- (void)showCommentsForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
    WLICommentsViewController *commentsViewController = [[WLICommentsViewController alloc] initWithNibName:@"WLICommentsViewController" bundle:nil];
    commentsViewController.post = post;
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (void)showLikesForPost:(WLIPost *)post sender:(WLITableViewCell*)senderCell {
    
    WLILikesViewController *likesViewController = [[WLILikesViewController alloc] initWithNibName:@"WLILikesViewController" bundle:nil];
    likesViewController.post = post;
    [self.navigationController pushViewController:likesViewController animated:YES];
}

- (void)followUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender {
    
    [sharedConnect setFollowOnUserID:user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
        
    }];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender {
    
    [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
        
    }];
}


#pragma mark - MNMPullToRefreshClient methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [refreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [refreshManager tableViewReleased];
    
}

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager {
    
    if (!loading) {
        id<WLIViewControllerRefreshProtocol> objectConformsToProtocol = (id<WLIViewControllerRefreshProtocol>)self;
        [objectConformsToProtocol reloadData:YES];
    } else {
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }
}

@end
