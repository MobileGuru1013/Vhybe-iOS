//
//  WLIPopularViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPopularViewController.h"
#import "WLILoadingCell.h"
#import "WLIPostCollectionViewCell.h"
#import "GlobalDefines.h"
#import "WLILoadingCollectionViewCell.h"
#import "WLINewPostViewController.h"
#import "UIImage+FontAwesome.h"

@implementation WLIPopularViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Popular";
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIcon:@"fa-pencil-square-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:25] style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemComposeTouchUpInside:)];
    
    self.navigationItem.rightBarButtonItem = submitBarButton;
    
    [self reloadData:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    int page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0)
            page  = (self.popularPosts.count / kDefaultPageSize) + 1;
        else
            page  = (self.recentPosts.count / kDefaultPageSize) + 1;
        
    }
    if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0)  {
        [sharedConnect popularPostsOnPage:1 pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
            
            if (serverResponseCode == OK) {
                loading = NO;
                self.popularPosts = posts;
                loadMore = posts.count == kDefaultPageSize;
                [self.tableViewRefresh reloadData];
                [refreshManager tableViewReloadFinishedAnimated:YES];
                self.lbl_Background.hidden = YES;
                self.tableViewRefresh.hidden = NO;
            } else if (serverResponseCode == NOT_FOUND) {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"No results found.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            } else if (serverResponseCode == NO_CONNECTION) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"No connection. Please try again.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"Something went wrong. Please try again.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            }
        }];

    }
    else {
        [sharedConnect recentPostsWithPageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
            
            if (serverResponseCode == OK) {
                loading = NO;
                self.recentPosts = posts;
                loadMore = posts.count == kDefaultPageSize;
                [self.tableViewRefresh reloadData];
                [refreshManager tableViewReloadFinishedAnimated:YES];
                self.lbl_Background.hidden = YES;
                self.tableViewRefresh.hidden = NO;
            } else if (serverResponseCode == NOT_FOUND) {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"No results found.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            } else if (serverResponseCode == NO_CONNECTION) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"No connection. Please try again.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_Background.text = @"Something went wrong. Please try again.";
                self.lbl_Background.hidden = NO;
                self.tableViewRefresh.hidden = YES;
            }
        }];

    }
    
   }

#pragma mark - Data loading methods

/*- (void)reloadDataOnSegment:(int)segment {
    
    if (segment == 0) {
        loadingPopular = YES;
        [hud show:YES];
        [sharedConnect popularPostsOnPage:1 pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
            loadingPopular = NO;
            self.popularPosts = posts;
            [self.tableViewRefresh reloadData];
            [hud hide:NO];
            [self updateReloadButton];
            [refreshManager tableViewReloadFinishedAnimated:YES];
        }];
    } else {
        loadingRecent = YES;
        [hud show:YES];
        [sharedConnect recentPostsWithPageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
            loadingRecent = NO;
            self.recentPosts = posts;
            [self.tableViewRefresh reloadData];
            [hud hide:NO];
            [self updateReloadButton];
            [refreshManager tableViewReloadFinishedAnimated:YES];
        }];
    }
}
*/

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0) {
        if (indexPath.section == 1){
            static NSString *CellIdentifier = @"WLIPostCell";
            WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.post = self.popularPosts[indexPath.row];
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
    else
    {
        if (indexPath.section == 1){
            static NSString *CellIdentifier = @"WLIPostCell";
            WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.post = self.recentPosts[indexPath.row];
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
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0)
    {
        if (section == 1) {
            return self.popularPosts.count;
        } else {
            if (loadMore) {
                return 1;
            } else {
                return 0;
            }
        }
    }
    else
    {
        if (section == 1) {
            return self.recentPosts.count;
        } else {
            if (loadMore) {
                return 1;
            } else {
                return 0;
            }
        }
    }
    
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0)
    {
        if (indexPath.section == 1) {
            return [WLIPostCell sizeWithPost:self.popularPosts[indexPath.row]].height;
        } else if (indexPath.section == 0){
            return 44 * loading * self.popularPosts.count == 0;
        } else {
            return 44 * loadMore;
        }

    }
    else
    {
        if (indexPath.section == 1) {
            return [WLIPostCell sizeWithPost:self.recentPosts[indexPath.row]].height;
        } else if (indexPath.section == 0){
            return 44 * loading * self.recentPosts.count == 0;
        } else {
            return 44 * loadMore;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:YES];
    }
}


#pragma mark - WLIPostCellDelegate methods

- (void)toggleLikeForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell {
    
    if (post.likedThisPost) {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
        post.postLikesCount--;
        post.likedThisPost = NO;
        if (post.postLikesCount == 1) {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
        } else {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
        }
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount == 1) {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
                } else {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
                }
            }
        }];
    } else {
        [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-liked.png"] forState:UIControlStateNormal];
        post.postLikesCount++;
        post.likedThisPost = YES;
        if (post.postLikesCount == 1) {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
        } else {
            [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
        }
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [senderCell.buttonLike setImage:[UIImage imageNamed:@"btn-like.png"] forState:UIControlStateNormal];
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 1) {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d like", post.postLikesCount] forState:UIControlStateNormal];
                } else {
                    [senderCell.buttonLikes setTitle:[NSString stringWithFormat:@"%d likes", post.postLikesCount] forState:UIControlStateNormal];
                }
            }
        }];
    }
}


#pragma mark - Actions methods

- (IBAction)segmentedControlPopularRecentValueChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.popularPosts = nil;
        if (!loadingPopular) {
            [self reloadData:YES];
        }
    } else {
        self.recentPosts = nil;
        if (!loadingRecent) {
            [self reloadData:YES];
        }
    }
    [self updateReloadButton];
}

- (void)barButtonItemComposeTouchUpInside:(UIBarButtonItem*)reloadBarButtonItem {
    
   /* if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0 && !loadingPopular) {
        [self reloadDataOnSegment:0];
    } else if (self.segmentedControlPopularRecent.selectedSegmentIndex == 1 && !loadingRecent) {
        [self reloadDataOnSegment:1];
    }
    [self updateReloadButton];*/
    
    WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:newPostNavigationController animated:YES completion:nil];
}

- (void)updateReloadButton {
    
    if (self.segmentedControlPopularRecent.selectedSegmentIndex == 0) {
        if (loadingPopular) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    } else {
        if (loadingRecent) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
}

@end
