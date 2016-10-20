//
//  WLIFollowingViewController.m
//  Friends
//
//  Created by Planet 1107 on 03/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIFollowingViewController.h"
#import "GlobalDefines.h"
#import "WLIUserCell.h"
#import "WLILoadingCell.h"

@implementation WLIFollowingViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.following = [NSMutableArray array];
        //self.title = @"Friends";
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData {
    
    loading = YES;
    int page = (self.following.count / kDefaultPageSize) + 1;
    [sharedConnect followingForUserID:self.user.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *following, ServerResponse serverResponseCode) {
        loading = NO;
        [self.following addObjectsFromArray:following];
        loadMore = following.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIUserCell";
        WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.user = self.following[indexPath.row];
        cell.buttonFollowUnfollow.hidden = YES;
        cell.cellBtn_Chat.hidden = YES;
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return self.following.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 44;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.following.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData];
    }
}


#pragma mark - WLIUserCellDelegate methods

- (void)followUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender{
    
    WLIUserCell *cell = (WLIUserCell*)senderCell;
    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
    user.followingUser = YES;
    [sharedConnect setFollowOnUserID:user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
        if (serverResponseCode != OK) {
            user.followingUser = NO;
            [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured, user was not followed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender{
    
    WLIUserCell *cell = (WLIUserCell*)senderCell;
    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
    user.followingUser = NO;
    [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
        if (serverResponseCode != OK) {
            user.followingUser = YES;
            [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured, user was not unfollowed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

@end
