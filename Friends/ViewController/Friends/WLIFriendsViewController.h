//
//  WLIFriendsViewController.h
//  Friends
//
//  Created by Kapil on 15/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIViewController.h"
#import "WLIChattingViewController.h"

@interface WLIFriendsViewController : WLIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmt_FriendChat;
@property (weak, nonatomic) IBOutlet UITableView *tblv_Friends;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMutableArray *chatList;
@property (weak, nonatomic) IBOutlet UILabel *lbl_background;
- (IBAction)FriendsSegmentChanged:(id)sender;

@end
