//
//  WLIProfileViewController.m
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIProfileViewController.h"
#import "WLISettingViewController.h"
#import "WLIEditProfileViewController.h"
#import "WLIFollowingViewController.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"
#import "WLIAppDelegate.h"
#import "WLILoadingCell.h"
#import "DatabaseManager.h"
#import "WLIChattingViewController.h"

@interface WLIProfileViewController ()

@end

@implementation WLIProfileViewController
{
    WLIUser *currUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Profile";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    int userID;
    if (self.user)
        userID=self.user.userID;
    else
        userID=[WLIConnect sharedConnect].currentUser.userID;
    [sharedConnect userWithUserID:userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            currUser = user;
            [self loadUserProfile];
        } else if (serverResponseCode == NOT_FOUND) {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"No results found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else if (serverResponseCode == NO_CONNECTION) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        [hud hide:YES];
    }];
    self.tableViewRefresh.contentInset = UIEdgeInsetsMake(-39, 0, 0, 0);
 
    [self.btnFriendsCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnFriendsCount setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
    [self.btnFriendRequest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnFriendRequest setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
    
    self.imgvProfilePic.layer.cornerRadius = self.imgvProfilePic.frame.size.width/2;//half of the width
    self.imgvProfilePic.layer.borderColor=[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0].CGColor;
    self.imgvProfilePic.layer.borderWidth=4.0f;
    self.imgvProfilePic.layer.masksToBounds = YES;
    
    
}

-(void)loadUserProfile
{
    /*[self.scrollView addSubview:self.view_MainProfile];
    CGSize size = CGSizeMake(self.view_MainProfile.frame.size.width, self.view_MainProfile.frame.size.width+self.view_secondary.frame.origin.y);
    self.scrollView.contentSize = size;
    toolbar.mainScrollView = self.scrollView;*/
    
    self.lbl_Gender.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.lbl_FALocation.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.lbl_FALocation.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"];
    self.lblUserName.text = currUser.userFullName;
    
    self.lbl_FAOccupation.font = [UIFont fontWithName:kFontAwesomeFamilyName size:12];
    self.lbl_FAOccupation.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-briefcase"];
    self.lbl_Occupation.text = currUser.userOccupation;
    
    
    [self.imgvProfilePic setImageWithURL:[NSURL URLWithString:currUser.userAvatarPath]];
    //self.imgvProfilePic.layer.backgroundColor = [UIColor colorWithPatternImage:tmp.image].CGColor;
    if ([currUser.userGender isEqualToString:@"male"] || !currUser.userGender.length)
        self.lbl_Gender.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-mars"];
    else if([currUser.userGender isEqualToString:@"female"])
        self.lbl_Gender.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-venus"];
    if ([currUser.userMaritalStatus isEqualToString:@"single"])
        self.lbl_RelationshipStatus.text = @"Single";
    else if ([currUser.userMaritalStatus isEqualToString:@"married"])
        self.lbl_RelationshipStatus.text = @"Relationship";
    self.lblInterestsValue.text = currUser.userInterests;
    self.lblLocationValue.text = [NSString stringWithFormat:@"%@",currUser.userLocation];
    if (self.lblLocationValue.text.length)
        self.lbl_FALocation.hidden = NO;
    else
        self.lbl_FALocation.hidden = YES;
    [self.btnFriendsCount setTitle:[NSString stringWithFormat:@"%@ Friends",currUser.userFriends] forState:UIControlStateNormal];
    
    self.btnFriendRequest.layer.masksToBounds=YES;
    self.btnFriendRequest.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.btnFriendRequest.layer.borderWidth= 1.0f;
    
    self.btnFriendsCount.layer.masksToBounds=YES;
    self.btnFriendsCount.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.btnFriendsCount.layer.borderWidth= 1.0f;
    
    self.btn_PostCount.layer.masksToBounds=YES;
    self.btn_PostCount.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.btn_PostCount.layer.borderWidth= 1.0f;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Interests" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino" size:18.0]}];
    self.lbl_Interests.attributedText = str;
    
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Recent Activity" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino" size:18.0]}];
    self.lbl_RecentActivity.attributedText = str1;
    
    if (![currUser.userBirthDate isEqualToString:@"0000-00-00"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSDate *formattedDate = [dateFormatter dateFromString:currUser.userBirthDate];
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:formattedDate];
        int numberOfYears = secondsBetween / 31536000;
        NSLog(@"There are %d Years in between the two dates.", numberOfYears);
        self.lblAgeValue.text = [NSString stringWithFormat:@"%d",numberOfYears];
    }
    else
        self.lblAgeValue.text = @"";
    
    [self.btnLogOut.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:25]];
    
    if (currUser.userID == [WLIConnect sharedConnect].currentUser.userID) {
        [self.btnLogOut setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-sign-out"] forState:UIControlStateNormal];
        self.btnLogOut.tag = 1;
        self.btnLogOut.hidden = NO;
        self.btnFriendRequest.hidden = YES;
        UIBarButtonItem *editBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithIcon:@"fa-pencil-square" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:25] style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemEditTouchUpInside:)];
        self.navigationItem.rightBarButtonItem = editBarButton;
        if (currUser.userOccupation.length) {
            CGRect frame = self.btnFriendsCount.frame;
            frame.origin.y = self.lbl_FAOccupation.frame.origin.y+self.lbl_FAOccupation.frame.size.height+5;
            self.btnFriendsCount.frame = frame;
            frame = self.btn_PostCount.frame;
            frame.origin.y = self.lbl_FAOccupation.frame.origin.y+self.lbl_FAOccupation.frame.size.height+5;
            self.btn_PostCount.frame = frame;
        }
        else
        {
            self.lbl_FAOccupation.hidden = YES;
            CGRect frame = self.btnFriendsCount.frame;
            frame.origin.y = self.lbl_FALocation.frame.origin.y+self.lbl_FALocation.frame.size.height+5;
            self.btnFriendsCount.frame = frame;
            frame = self.btn_PostCount.frame;
            frame.origin.y = self.lbl_FALocation.frame.origin.y+self.lbl_FALocation.frame.size.height+5;
            self.btn_PostCount.frame = frame;
        }
        
        /*CGRect frame = self.view_secondary.frame;
        frame.origin.y = self.lbl_FALocation.frame.origin.y+self.lbl_FALocation.frame.size.height;
        self.view_secondary.frame = frame;*/
    }
    else
    {
        self.btnFriendRequest.hidden = NO;
        CGRect frame;
        if (currUser.userOccupation.length) {
            frame = self.btnFriendRequest.frame;
            frame.origin.y = self.lbl_FAOccupation.frame.origin.y+self.lbl_FAOccupation.frame.size.height;
            self.btnFriendRequest.frame = frame;
        }
        else
        {
            self.lbl_FAOccupation.hidden = YES;
            frame = self.btnFriendRequest.frame;
            frame.origin.y = self.lbl_FALocation.frame.origin.y+self.lbl_FALocation.frame.size.height;
            self.btnFriendRequest.frame = frame;
        }
        
        frame = self.btnFriendsCount.frame;
        frame.origin.y = self.btnFriendRequest.frame.origin.y+self.btnFriendRequest.frame.size.height+5;
        self.btnFriendsCount.frame = frame;
        frame = self.btn_PostCount.frame;
        frame.origin.y = self.btnFriendRequest.frame.origin.y+self.btnFriendRequest.frame.size.height+5;
        self.btn_PostCount.frame = frame;
        self.btnLogOut.hidden = YES;
        
        if ([currUser.userFriendStatus isEqualToString:@"0"]) {
            [self.btnFriendRequest setTitle:@"Add as Friend" forState:UIControlStateNormal];
            self.btnFriendRequest.tag = 1;
        }
        if ([currUser.userFriendStatus isEqualToString:@"1"]) {
            [self.btnFriendRequest setTitle:@"Unfriend" forState:UIControlStateNormal];
            self.btnFriendRequest.tag = 2;
            self.btnLogOut.tag = 2;
            [self.btnLogOut setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment-o"] forState:UIControlStateNormal];
            self.btnLogOut.hidden = NO;
        }
        if ([currUser.userFriendStatus isEqualToString:@"2"]) {
            [self.btnFriendRequest setTitle:@"Accept Friend Request" forState:UIControlStateNormal];
            self.btnFriendRequest.tag = 3;
        }
        if ([currUser.userFriendStatus isEqualToString:@"3"]) {
            [self.btnFriendRequest setTitle:@"Friend Request Sent" forState:UIControlStateNormal];
            self.btnFriendRequest.tag = 4;
        }
    }
    
    CGRect frame = self.lbl_Interests.frame;
    frame.origin.y = self.btnFriendsCount.frame.origin.y+self.btnFriendsCount.frame.size.height+5;
    self.lbl_Interests.frame = frame;
    frame = self.lbl_Interests.frame;
    frame.origin.y = self.btnFriendsCount.frame.origin.y+self.btnFriendsCount.frame.size.height+5;
    self.lbl_Interests.frame = frame;
    frame = self.lblInterestsValue.frame;
    frame.origin.y = self.lbl_Interests.frame.origin.y+self.lbl_Interests.frame.size.height+5;
    self.lblInterestsValue.frame = frame;
    frame = self.lbl_RecentActivity.frame;
    frame.origin.y = self.lblInterestsValue.frame.origin.y+self.lblInterestsValue.frame.size.height+5;
    self.lbl_RecentActivity.frame = frame;
    
    if (!self.lblInterestsValue.text.length) {
        CGRect frame = self.lbl_RecentActivity.frame;
        frame.origin.y = self.lbl_Interests.frame.origin.y;
        self.lbl_RecentActivity.frame = frame;
        /*frame = self.tableViewRefresh.frame;
         frame.origin.y = self.lbl_RecentActivity.frame.origin.y + self.lbl_RecentActivity.frame.size.height;
         self.tableViewRefresh.frame = frame;*/
        self.lbl_Interests.hidden = YES;
    }
    
    [self reloadData:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions methods

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
    [sharedConnect RecentActivityForUserID:currUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            loading = NO;
            self.posts = posts;
            [self.btn_PostCount setTitle:[NSString stringWithFormat:@"%lu Posts",(unsigned long)self.posts.count] forState:UIControlStateNormal];
            loadMore = posts.count == kDefaultPageSize;
            [self.tableViewRefresh reloadData];
            [refreshManager tableViewReloadFinishedAnimated:YES];
        }/*else
        self.tableViewRefresh.hidden = YES;*/
    }];
}

- (IBAction)AddRemoveFriend:(id)sender {
    [self.btnFriendRequest setTitleColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0] forState:UIControlStateNormal];
    [self.btnFriendRequest setBackgroundColor:[UIColor whiteColor]];
    if ([sender tag]==1) {
        [sharedConnect sendFriendRequestOnUserID:currUser.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self.btnFriendRequest setTitle:@"Friend Request Sent" forState:UIControlStateNormal];
                self.btnFriendRequest.tag = 4;
                [self.btnFriendRequest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.btnFriendRequest setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
            }
        }];
    }
    else if ([sender tag]==2 || [sender tag]==4)
    {
        [sharedConnect UnfriendRequestOnUserID:currUser.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self.btnFriendRequest setTitle:@"Add as Friend" forState:UIControlStateNormal];
                self.btnFriendRequest.tag = 1;
                [self.btnFriendRequest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.btnFriendRequest setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
            }
        }];
    }
    else if ([sender tag]==3)
    {
        [sharedConnect ResponseFriendRequestOnUserID:currUser.userID Approved:@"1" onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occured, please try again later"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            else
            {
                [self viewWillAppear:YES];
               /* [self.btnFriendRequest setTitle:@"Unfriend" forState:UIControlStateNormal];
                self.btnFriendRequest.tag = 2;
                [self.btnLogOut setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-comment-o"] forState:UIControlStateNormal];
                //self.btnLogOut.hidden = NO;*/
            }
        }];
    }
}

- (IBAction)LogOutButtonPressed:(id)sender {
    if ([sender tag] == 1) {
        [[WLIConnect sharedConnect] logout];
        WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate createViewHierarchy];
    }
    else if ([sender tag] == 2) {
        NSLog(@"Go to chat view");
        
         WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil];
         ChattingViewController.channelID = currUser.userChannelID;
         ChattingViewController.toUserID = currUser;
         UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
         ChattingNavigationController.navigationBar.translucent = NO;
         [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
        
       /* [hud show:YES];
        
        [[DatabaseManager getInstance] getResultDataForQuery:[NSString stringWithFormat:@"SELECT server_date FROM tbl_chat_detail WHERE (to_user_id = %d AND from_user_id = %d) OR (to_user_id = %d AND from_user_id = %d) ORDER BY chat_detail_id DESC LIMIT 1;",sharedConnect.currentUser.userID,currUser.userID,currUser.userID,sharedConnect.currentUser.userID] onCompletion:^(NSMutableArray *results) {
            NSString *lastSyncDate;
            if (results.count != 0) {
                lastSyncDate=[[results objectAtIndex:0] objectForKey:@"server_date"];
            }
            
            [sharedConnect getChatDetailDataUserID:sharedConnect.currentUser.userID toUser:currUser.userID lastSyncDate:lastSyncDate onCompletion:^(NSMutableArray *chatDetail, ServerResponse serverResponseCode) {
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
                    ChattingViewController.toUserID = currUser;
                    UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
                    ChattingNavigationController.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
                }
                else
                {
                    [hud hide:YES];
                    WLIChattingViewController *ChattingViewController = [[WLIChattingViewController alloc] initWithNibName:@"WLIChattingViewController" bundle:nil];
                    ChattingViewController.channelID = sender.restorationIdentifier;
                    ChattingViewController.toUserID = currUser;
                    UINavigationController *ChattingNavigationController = [[UINavigationController alloc] initWithRootViewController:ChattingViewController];
                    ChattingNavigationController.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:ChattingNavigationController animated:YES completion:nil];
                }
            }];
        }];*/
    }
}

- (IBAction)FriendsButtonPressed:(id)sender {
    [self.btnFriendsCount setTitleColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0] forState:UIControlStateNormal];
    [self.btnFriendsCount setBackgroundColor:[UIColor whiteColor]];
    WLIFollowingViewController *followingViewController = [[WLIFollowingViewController alloc] initWithNibName:@"WLIFollowingViewController" bundle:nil];
    followingViewController.user = currUser;
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (void)barButtonItemEditTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
    UINavigationController *editProfileNavigationController = [[UINavigationController alloc] initWithRootViewController:editProfileViewController];
    editProfileNavigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:editProfileNavigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        if (self.posts.count) {
            static NSString *CellIdentifier = @"WLIPostCell";
            WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
                cell.delegate = self;
            }
            cell.post = self.posts[indexPath.row];
            return cell;
        }else{
            static NSString *simpleTableIdentifier = @"SimpleTableItem";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            }
            cell.textLabel.text = @"You don't have any post.";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor colorWithRed:128./255. green:1./255. blue:14./255. alpha:1.0];
            return cell;
        }
        
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
        /*CGRect frame = self.tableViewRefresh.frame;
        frame.size.height = self.tableViewRefresh.frame.size.height+cell.frame.size.height;
        self.tableViewRefresh.frame = frame;*/
        /*CGSize Size = self.scrollView.contentSize;
        Size.height = self.scrollView.contentSize.height + cell.frame.size.height;
        self.scrollView.contentSize = Size;*/
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        if (self.posts.count) {
            return self.posts.count;
        }else
        return 1;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        if (self.posts.count) {
            return [WLIPostCell sizeWithPost:self.posts[indexPath.row]].height;
        }else
            return 30;
    } else if (indexPath.section == 0){
        return 44 * loading * self.posts.count == 0;
    } else {
        return 0 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    /*UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,30)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, headerView.frame.size.width-120.0, headerView.frame.size.height)];
    
    headerLabel.textAlignment = NSTextAlignmentRight;
    headerLabel.text = @"Test";
    headerLabel.backgroundColor = [UIColor clearColor];
    
    [headerView addSubview:headerLabel];*/
    if (section == 1) {
        UIView *headerView;
        return headerView = self.view_secondary;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        return  self.lbl_RecentActivity.frame.origin.y+self.lbl_RecentActivity.frame.size.height;
    }
    return 0;
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

@end
