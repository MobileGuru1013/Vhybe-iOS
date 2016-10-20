//
//  WLIProfileViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIProfileViewController.h"
#import "WLIEditProfileViewController.h"
#import "GlobalDefines.h"
#import "WLIFollowingViewController.h"
#import "WLIFollowersViewController.h"
#import "WLISearchViewController.h"
#import "WLIWelcomeViewController.h"
#import "WLIAppDelegate.h"

@implementation WLIProfileViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Profile";
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.width/2;
    self.imageViewUser.layer.masksToBounds = YES;
    
    if (self.user.userID == [WLIConnect sharedConnect].currentUser.userID) {
        self.buttonFollow.alpha = 0.0f;
    } else {
        if (self.user.followingUser) {
            [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
        } else {
            [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
        }
    }

    if (self.user == [WLIConnect sharedConnect].currentUser) {
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        editButton.adjustsImageWhenHighlighted = NO;
        editButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
        [editButton setImage:[UIImage imageNamed:@"nav-btn-edit.png"] forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(barButtonItemEditTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.buttonLogout.frame) +20.0f);
    } else {
        self.buttonSearchUsers.alpha = 0.0f;
        self.buttonLogout.alpha = 0.0f;
        self.scrollViewUserProfile.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(self.labelEmail.frame) +20.0f);
    }
    
    if (self.user.userType != WLIUserTypeCompany) {
        self.labelAddress.alpha = 0.0f;
        self.labelPhone.alpha = 0.0f;
        self.labelWeb.alpha = 0.0f;
        self.labelEmail.alpha = 0.0f;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateFramesAndDataWithDownloads:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUser:(WLIUser *)user {
    
    _user = user;
}

- (WLIUser*)user {
    
    if (_user) {
        return _user;
    } else {
        return [WLIConnect sharedConnect].currentUser;
    }
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    self.labelName.text = self.user.userFullName;
    if (self.user.followingUser) {
        [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
    }
    self.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.user.followingCount];
    self.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.user.followersCount];
    
    self.labelAddress.text = self.user.companyAddress;
    self.labelPhone.text = self.user.companyPhone;
    self.labelWeb.text = self.user.companyWeb;
    self.labelEmail.text = self.user.companyEmail;
    
    if (downloads) {
        [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
        
        [sharedConnect userWithUserID:self.user.userID onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            _user = user;
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.user.userAvatarPath]];
            self.labelName.text = self.user.userFullName;
            if (self.user.followingUser) {
                [self.buttonFollow setTitle:@"Following" forState:UIControlStateNormal];
            } else {
                [self.buttonFollow setTitle:@"Follow!" forState:UIControlStateNormal];
            }
            self.labelFollowingCount.text = [NSString stringWithFormat:@"following %d", self.user.followingCount];
            self.labelFollowersCount.text = [NSString stringWithFormat:@"followers %d", self.user.followersCount];
            
            self.labelAddress.text = self.user.companyAddress;
            self.labelPhone.text = self.user.companyPhone;
            self.labelWeb.text = self.user.companyWeb;
            self.labelEmail.text = self.user.companyEmail;
        }];
    }
}


#pragma mark - Buttons methods

- (void)barButtonItemEditTouchUpInside:(UIBarButtonItem*)barButtonItemEditProfile {
    
    WLIEditProfileViewController *editProfileViewController = [[WLIEditProfileViewController alloc] initWithNibName:@"WLIEditProfileViewController" bundle:nil];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (IBAction)buttonFollowToggleTouchUpInside:(id)sender {
    
    if (self.user.followingUser) {
        self.user.followingUser = NO;
        self.user.followersCount--;
        [self updateFramesAndDataWithDownloads:NO];
        [sharedConnect removeFollowWithFollowID:self.user.userID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                self.user.followingUser = YES;
                self.user.followersCount++;
                [self updateFramesAndDataWithDownloads:NO];
                [[[UIAlertView alloc] initWithTitle:@"Following" message:[NSString stringWithFormat:@"An error occured, you are still following %@", self.user.userFullName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    } else {
        self.user.followingUser = YES;
        self.user.followersCount++;
        [self updateFramesAndDataWithDownloads:NO];
        [sharedConnect setFollowOnUserID:self.user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode != OK) {
                self.user.followingUser = NO;
                self.user.followersCount--;
                [self updateFramesAndDataWithDownloads:NO];
                [[[UIAlertView alloc] initWithTitle:@"Not Following" message:[NSString stringWithFormat:@"An error occured, you are still following %@", self.user.userFullName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (IBAction)buttonFollowingTouchUpInside:(id)sender {
    
    WLIFollowingViewController *followingViewController = [[WLIFollowingViewController alloc] initWithNibName:@"WLIFollowingViewController" bundle:nil];
    followingViewController.user = self.user;
    [self.navigationController pushViewController:followingViewController animated:YES];
}

- (IBAction)buttonFollowersTouchUpInside:(id)sender {
    
    WLIFollowersViewController *followersViewController = [[WLIFollowersViewController alloc] initWithNibName:@"WLIFollowersViewController" bundle:nil];
    followersViewController.user = self.user;
    [self.navigationController pushViewController:followersViewController animated:YES];
}

- (IBAction)buttonSearchUsersTouchUpInside:(id)sender {
    
    WLISearchViewController *searchViewController = [[WLISearchViewController alloc] initWithNibName:@"WLISearchViewController" bundle:nil];
    [self.navigationController pushViewController:searchViewController animated:YES];
}

- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender {
    
    [[[UIAlertView alloc] initWithTitle:@"Logout" message:@"Are you sure that you want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([alertView.title isEqualToString:@"Logout"] && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[WLIConnect sharedConnect] logout];
        WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate createViewHierarchy];
    }
}

@end
