//
//  WLIProfileViewController.h
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIViewController.h"

@interface WLIProfileViewController : WLIViewController <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) IBOutlet UIImageView *imgvProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendRequest;
@property (weak, nonatomic) IBOutlet UILabel *lblInterestsValue;
@property (weak, nonatomic) IBOutlet UILabel *lblLocationValue;
@property (weak, nonatomic) IBOutlet UIButton *btnLogOut;
@property (weak, nonatomic) IBOutlet UILabel *lblAgeValue;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendsCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Gender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_RelationshipStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Interests;
@property (weak, nonatomic) IBOutlet UILabel *lbl_RecentActivity;
@property (weak, nonatomic) IBOutlet UIButton *btn_PostCount;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *view_MainProfile;
@property (strong, nonatomic) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FALocation;
@property (strong, nonatomic) IBOutlet UIView *view_secondary;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FAOccupation;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Occupation;
@property (weak, nonatomic) IBOutlet UIButton *btn_Avatar;

//Methods
- (IBAction)AddRemoveFriend:(id)sender;
- (IBAction)LogOutButtonPressed:(id)sender;
- (IBAction)FriendsButtonPressed:(id)sender;

@end
