//
//  WLITimelineViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITimelineViewController.h"
#import "WLINewPostViewController.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"
#import "WLIEditProfileViewController.h"
#import "DatabaseManager.h"

@implementation WLITimelineViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Timeline";
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-github"] style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemComposeTouchUpInside:)];
    UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIcon:@"fa-pencil-square-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:25] style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemComposeTouchUpInside:)];
    
    self.navigationItem.rightBarButtonItem = submitBarButton;
    [self reloadData:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    if ([sharedConnect.currentUser.userFullName isEqualToString:@""]) {
        WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
        UINavigationController *editProfileNavigationController = [[UINavigationController alloc] initWithRootViewController:editProfileViewController];
        editProfileNavigationController.navigationBar.translucent = NO;
        [self.navigationController presentViewController:editProfileNavigationController animated:YES completion:nil];
    }
    
    [sharedConnect getInterestsonCompletion:^(ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            NSLog(@"Interests Saved");
        }
    }];
    [sharedConnect getOccupationonCompletion:^(ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            NSLog(@"Occupation Saved");
        }
    }];
    
    [self loadPreviousChat];
}

-(void)loadPreviousChat
{
    [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT server_date FROM tbl_chat_detail WHERE to_user_id = %d OR from_user_id = %d ORDER BY server_date DESC LIMIT 1;",sharedConnect.currentUser.userID,sharedConnect.currentUser.userID] onCompletion:^(NSMutableArray *results) {
        NSString *lastSyncDate;
        if (results.count != 0) {
            lastSyncDate=[[results objectAtIndex:0] objectForKey:@"server_date"];
        }
        
        [sharedConnect getChatDetailDataUserID:sharedConnect.currentUser.userID lastSyncDate:lastSyncDate onCompletion:^(NSMutableArray *chatDetail, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
                for (NSInteger i = chatDetail.count-1;i>=0;i--) {
                    NSDictionary *chatDetails = chatDetail[i];
                    [[DatabaseManager getInstance] saveChat:@{@"to_user_id":[chatDetails valueForKey:@"to_id"],@"from_user_id":[chatDetails valueForKey:@"from_id"],@"message":[chatDetails valueForKey:@"text"],@"isImage":[NSNumber numberWithInteger:[[chatDetails valueForKey:@"isImage"] integerValue]],@"unread":@0,@"created_date":formattedDate,@"server_date":[chatDetails valueForKey:@"serverdatetime"]}];
                }
            }
        }];
    }];
    
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
        page  = (self.posts.count / kDefaultPageSize) + 1;
    }
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            loading = NO;
            self.posts = posts;
            if (self.posts.count) {
                loadMore = posts.count == kDefaultPageSize;
            }
            [self.tableViewRefresh reloadData];
            [refreshManager tableViewReloadFinishedAnimated:YES];
            self.lbl_Background.hidden = YES;
            /*self.tableViewRefresh.hidden = NO;*/
            [self.view bringSubviewToFront:self.tableViewRefresh];
        } else if (serverResponseCode == NOT_FOUND) {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"No results found.";
            self.lbl_Background.hidden = NO;
            /*self.tableViewRefresh.hidden = YES;*/
            [self.view bringSubviewToFront:self.lbl_Background];
        } else if (serverResponseCode == NO_CONNECTION) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"No connection. Please try again.";
            self.lbl_Background.hidden = NO;
            /*self.tableViewRefresh.hidden = YES;*/
            [self.view bringSubviewToFront:self.lbl_Background];
        } else {
            //[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_Background.text = @"No posts for Timeline";
            self.lbl_Background.hidden = NO;
            loading = NO;
             /*self.tableViewRefresh.hidden = YES;*/
            [self.view bringSubviewToFront:self.lbl_Background];
        }
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIPostCell";
        WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.post = self.posts[indexPath.row];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        if (self.posts.count)
            cell.hidden = NO;
        else
            cell.hidden = YES;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return self.posts.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row]].height;
    } else if (indexPath.section == 0){
        return 44 * loading * self.posts.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
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

- (void)barButtonItemComposeTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:newPostNavigationController animated:YES completion:nil];
}

@end
