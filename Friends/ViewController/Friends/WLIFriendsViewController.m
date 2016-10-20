//
//  WLIFriendsViewController.m
//  Friends
//
//  Created by Kapil on 15/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIFriendsViewController.h"
#import "WLIUserCell.h"
#import "WLIChatListCell.h"
#import "WLILoadingCell.h"
#import "NSString+FontAwesome.h"
#import "DatabaseManager.h"
#import "ChatManager.h"

@interface WLIFriendsViewController ()

@end

@implementation WLIFriendsViewController
{
    WLIUser *currUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Friends";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    self.friends = [NSMutableArray array];
    self.requests = [NSMutableArray array];
    self.chatList = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated
{
    currUser = [WLIConnect sharedConnect].currentUser;
    if (self.sgmt_FriendChat.selectedSegmentIndex == 0) {
        //WebServiceCall
        [self.chatList removeAllObjects];
        [self.tblv_Friends reloadData];
        [self reloadData];
    }
    
    [self loadPreviousChat];
}

-(void)loadPreviousChat
{
    [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT server_date FROM tbl_chat_detail WHERE to_user_id = %d OR from_user_id = %d ORDER BY server_date DESC LIMIT 1;",currUser.userID,currUser.userID] onCompletion:^(NSMutableArray *results) {
        NSString *lastSyncDate;
        if (results.count != 0) {
            lastSyncDate=[[results objectAtIndex:0] objectForKey:@"server_date"];
        }
        
        [sharedConnect getChatDetailDataUserID:currUser.userID lastSyncDate:lastSyncDate onCompletion:^(NSMutableArray *chatDetail, ServerResponse serverResponseCode) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)FriendsSegmentChanged:(id)sender {
    
    if (self.sgmt_FriendChat.selectedSegmentIndex == 0) {
        [self.chatList removeAllObjects];
        [self.tblv_Friends reloadData];
        [self reloadData];
    }
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 1)
    {
        [self.friends removeAllObjects];
        [self.tblv_Friends reloadData];
        [self reloadData];
    }
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 2)
    {
        [self.requests removeAllObjects];
        [self.tblv_Friends reloadData];
        [self reloadData];
    }
}

#pragma mark - Data loading methods

- (void)reloadData {
    
    if (self.sgmt_FriendChat.selectedSegmentIndex == 0)
    {
        loading = YES;
        int page = (self.friends.count / kDefaultPageSize) + 1;
        [sharedConnect getChatDataUserID:currUser.userID onCompletion:^(NSMutableArray *chatData, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                loading = NO;
                [self.chatList addObjectsFromArray:chatData];
                loadMore = chatData.count == kDefaultPageSize;
                [self.tblv_Friends reloadData];
                self.lbl_background.hidden = YES;
                self.tblv_Friends.hidden = NO;
            }
            else if (serverResponseCode == NOT_FOUND)
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"You don't have any chat records." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_background.text = @"You don't have any chat records.";
                self.tblv_Friends.hidden = YES;
                self.lbl_background.hidden = NO;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_background.text = @"Something went wrong, Please try again later.";
                self.tblv_Friends.hidden = YES;
                self.lbl_background.hidden = NO;
            }
        }];
        
    }
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 1)
    {
        loading = YES;
        int page = (self.friends.count / kDefaultPageSize) + 1;
        [sharedConnect followingForUserID:currUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *following, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                loading = NO;
                [self.friends addObjectsFromArray:following];
                loadMore = following.count == kDefaultPageSize;
                [self.tblv_Friends reloadData];
                self.lbl_background.hidden = YES;
                self.tblv_Friends.hidden = NO;
            }
            else if (serverResponseCode == NOT_FOUND)
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"You don't have any friends." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_background.text = @"You don't have any friends.";
                self.tblv_Friends.hidden = YES;
                self.lbl_background.hidden = NO;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_background.text = @"Something went wrong, Please try again later.";
            self.tblv_Friends.hidden = YES;
            self.lbl_background.hidden = NO;
            }
        }];
    }
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 2)
    {
        loading = YES;
        int page = (self.requests.count / kDefaultPageSize) + 1;
        [sharedConnect friendRequestForUserID:currUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *following, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                loading = NO;
                [self.requests addObjectsFromArray:following];
                loadMore = following.count == kDefaultPageSize;
                [self.tblv_Friends reloadData];
                self.tblv_Friends.hidden = NO;
                self.lbl_background.hidden = YES;
            }
            else if (serverResponseCode == NOT_FOUND)
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"You don't have any pending requests." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                self.lbl_background.text = @"You don't have any pending requests.";
                self.tblv_Friends.hidden = YES;
                self.lbl_background.hidden = NO;
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            self.lbl_background.text = @"Something went wrong, Please try again later.";
            self.tblv_Friends.hidden = YES;
            self.lbl_background.hidden = NO;
            }
        }];
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WLIUserCell *cell;
    
    if (self.sgmt_FriendChat.selectedSegmentIndex == 0)
    {
        if (indexPath.section == 1){
            static NSString *CellIdentifier = @"WLIChatListCell";
            WLIChatListCell *cell = (WLIChatListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIChatListCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            NSDictionary *chatDetail = self.chatList[indexPath.row];
            WLIUser *user = [[WLIUser alloc] initWithDictionary:[chatDetail valueForKey:@"userdetail"]];
            cell.user = user;
            cell.lbl_TimeStamp.text = [NSString stringWithFormat:@"%@ ago",[chatDetail valueForKey:@"timestamp"]];
            cell.lbl_UnreadCount.text = [NSString stringWithFormat:@"%@",[chatDetail valueForKey:@"unread"]];
            cell.lbl_LastChat.text = [chatDetail valueForKey:@"text"];
            cell.btn_ShowChatDetails.tag = 5;
            cell.btn_ShowChatDetails.restorationIdentifier = [[chatDetail valueForKey:@"userdetail"] valueForKey:@"channnelId"];
            return cell;
        } else {
            static NSString *CellIdentifier = @"WLILoadingCell";
            WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
            }
            
            return cell;
        }
    }else if (self.sgmt_FriendChat.selectedSegmentIndex == 1)
    {
        if (indexPath.section == 1){
            static NSString *CellIdentifier = @"WLIUserCell";
            WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.user = self.friends[indexPath.row];
            [cell.buttonFollowUnfollow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-trash-o"] forState:UIControlStateNormal];
            cell.buttonFollowUnfollow.tag = 1;
            [cell.cellBtn_Chat setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment"] forState:UIControlStateNormal];
            cell.cellBtn_Chat.tag = 2;
            cell.cellBtn_Chat.restorationIdentifier = cell.user.userChannelID;
            
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
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 2)
    {
        if (indexPath.section == 1){
            static NSString *CellIdentifier = @"WLIUserCell";
            WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.user = self.requests[indexPath.row];
            [cell.buttonFollowUnfollow setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-times-circle"] forState:UIControlStateNormal];
            cell.buttonFollowUnfollow.tag = 3;
            [cell.cellBtn_Chat setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-check-circle"] forState:UIControlStateNormal];
            cell.cellBtn_Chat.tag = 4;
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
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sgmt_FriendChat.selectedSegmentIndex == 0)
    {
        if (section == 1) {
            return self.chatList.count;
        } else {
            if (loadMore) {
                return 1;
            } else {
                return 0;
            }
        }
        
    }else if (self.sgmt_FriendChat.selectedSegmentIndex == 1)
    {
        if (section == 1) {
            return self.friends.count;
        } else {
            if (loadMore) {
                return 1;
            } else {
                return 0;
            }
        }

    }
    else if (self.sgmt_FriendChat.selectedSegmentIndex == 2)
    {
        if (section == 1) {
            return self.requests.count;
        } else {
            if (loadMore) {
                return 1;
            } else {
                return 0;
            }
        }

    }
    return 0;
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
        return 44 * loadMore * self.friends.count == 0;
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

- (void)followUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender {
    
//    WLIUserCell *cell = (WLIUserCell*)senderCell;
//    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
//    user.followingUser = YES;
//    [sharedConnect setFollowOnUserID:user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
//        if (serverResponseCode != OK) {
//            user.followingUser = NO;
//            [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured, user was not followed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//    }];
    
    if ([sender tag]==2) {
        //Chat Friend
        NSLog(@"Go to chat view");
                    WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil];
                    ChattingViewController.channelID = sender.restorationIdentifier;
                    ChattingViewController.toUserID = user;
                    UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
                    ChattingNavigationController.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
    }
    else if ([sender tag]==4)
    {
        //Accept Friend Request
        [sharedConnect ResponseFriendRequestOnUserID:user.userID Approved:@"1" onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self.requests removeAllObjects];
                [self.tblv_Friends reloadData];
                [self reloadData];
            }
        }];

    }
    else if ([sender tag]==5)
    {
        //ChatView
        NSLog(@"Go to chat view");
        
        WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil completion:^(NSString *backVC){
            if ([backVC isEqualToString:@"ChattingVC"]) {
                
            }
        }];
        ChattingViewController.channelID = sender.restorationIdentifier;
        ChattingViewController.toUserID = user;
        UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
        ChattingNavigationController.navigationBar.translucent = NO;
        [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
        
        /* NSMutableArray *results = [NSMutableArray array];
         results = [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT server_date FROM tbl_chat_detail WHERE (to_user_id = %d AND from_user_id = %d) OR (to_user_id = %d AND from_user_id = %d) ORDER BY chat_detail_id DESC LIMIT 1;",currUser.userID,user.userID,user.userID,currUser.userID]];
         NSLog(@"Results: %@",results);
         [[results objectAtIndex:0] objectForKey:@"server_date"];*/
        
        /*[hud show:YES];
       
        
        [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT server_date FROM tbl_chat_detail WHERE (to_user_id = %d AND from_user_id = %d) OR (to_user_id = %d AND from_user_id = %d) ORDER BY chat_detail_id DESC LIMIT 1;",currUser.userID,user.userID,user.userID,currUser.userID] onCompletion:^(NSMutableArray *results) {
            NSString *lastSyncDate;
            if (results.count != 0) {
                lastSyncDate=[[results objectAtIndex:0] objectForKey:@"server_date"];
            }
            
            [sharedConnect getChatDetailDataUserID:currUser.userID toUser:user.userID lastSyncDate:lastSyncDate onCompletion:^(NSMutableArray *chatDetail, ServerResponse serverResponseCode) {
                if (serverResponseCode == OK) {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
                    NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
                    for (NSInteger i = chatDetail.count-1;i>=0;i--) {
                        NSDictionary *chatDetails = chatDetail[i];
                        [[DatabaseManager getInstance] saveChat:@{@"to_user_id":[chatDetails valueForKey:@"to_id"],@"from_user_id":[chatDetails valueForKey:@"from_id"],@"message":[chatDetails valueForKey:@"text"],@"isImage":[NSNumber numberWithInteger:[[chatDetails valueForKey:@"isImage"] integerValue]],@"unread":@0,@"created_date":formattedDate,@"server_date":[chatDetails valueForKey:@"serverdatetime"]}];
                }
                    [hud hide:YES];
                    WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil];
                    ChattingViewController.channelID = sender.restorationIdentifier;
                    ChattingViewController.toUserID = user;
                    UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
                    ChattingNavigationController.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
            }
                else
                {
                    [hud hide:YES];
                    WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil];
                    ChattingViewController.channelID = sender.restorationIdentifier;
                    ChattingViewController.toUserID = user;
                    UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
                    ChattingNavigationController.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
                }
            }];
        }];*/
        
    }
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell buttonTag:(UIButton *)sender {
    
//    WLIUserCell *cell = (WLIUserCell*)senderCell;
//    [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-follow.png"] forState:UIControlStateNormal];
//    user.followingUser = NO;
//    [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
//        if (serverResponseCode != OK) {
//            user.followingUser = YES;
//            [cell.buttonFollowUnfollow setImage:[UIImage imageNamed:@"btn-unfollow.png"] forState:UIControlStateNormal];
//            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An error occured, user was not unfollowed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//        }
//    }];
    if ([sender tag]==1) {
        //Remove Friend
       /* */
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Friend" message:@"Do you really want to delete this friend?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        alert.tag =user.userID;
        [alert show];

    }
    else if ([sender tag]==3)
    {
        //Reject Friend Request
        [sharedConnect ResponseFriendRequestOnUserID:user.userID Approved:@"0" onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self.requests removeAllObjects];
                [self.tblv_Friends reloadData];
                [self reloadData];
            }
        }];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [sharedConnect UnfriendRequestOnUserID:(int)alertView.tag onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self.friends removeAllObjects];
                [self.tblv_Friends reloadData];
                [self reloadData];
            }
        }];
    }
}

@end
