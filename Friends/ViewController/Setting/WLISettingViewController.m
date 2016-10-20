//
//  WLISettingViewController.m
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLISettingViewController.h"
#import "NSString+FontAwesome.h"

@interface WLISettingViewController ()

@end

@implementation WLISettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Settings";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lbl_OldPassword.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_OldPassword.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_OldPassword.textColor = [UIColor whiteColor];
    self.lbl_OldPassword.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtOldPassword.layer.masksToBounds=YES;
    self.txtOldPassword.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtOldPassword.layer.borderWidth= 1.0f;
    self.txtOldPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtOldPassword.leftViewMode = UITextFieldViewModeAlways;

    self.lbl_NewPassword.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_NewPassword.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_NewPassword.textColor = [UIColor whiteColor];
    self.lbl_NewPassword.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtNewPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtNewPassword.leftViewMode = UITextFieldViewModeAlways;
    CALayer *PasswordRightBorder = [CALayer layer];
    PasswordRightBorder.frame = CGRectMake(self.txtNewPassword.frame.size.width-1, 0.0f, 1.0f, self.txtNewPassword.frame.size.height);
    PasswordRightBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.txtNewPassword.layer addSublayer:PasswordRightBorder];

    self.lbl_ConfirmPassword.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_ConfirmPassword.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_ConfirmPassword.textColor = [UIColor whiteColor];
    self.lbl_ConfirmPassword.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtConfirmPassword.layer.masksToBounds=YES;
    self.txtConfirmPassword.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtConfirmPassword.layer.borderWidth= 1.0f;
    self.txtConfirmPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtConfirmPassword.leftViewMode = UITextFieldViewModeAlways;

    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"MessageSwitchFlag"]) {
        [self.switch_notifications setOn:YES];
    }else
        [self.switch_notifications setOn:NO];
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

- (IBAction)ChangePasswordClicked:(id)sender {
    if (self.txtNewPassword.text.length && self.txtOldPassword.text.length && self.txtConfirmPassword.text.length) {
        if (![self.txtConfirmPassword.text isEqualToString:self.txtNewPassword.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"New password and confirm password doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            //WebService
            [sharedConnect changePasswordforEmailID:[sharedConnect currentUser].userEmail oldPassword:self.txtOldPassword.text newPassword:self.txtNewPassword.text onCompletion:^(ServerResponse serverResponseCode) {
                if (serverResponseCode == OK) {
                    [[[UIAlertView alloc] initWithTitle:@"Message" message:@"Password changed successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
                else if (serverResponseCode == UNAUTHORIZED){
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Old password is wrong, Please enter correct old password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Something went wrong, Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                }
            }];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please fill all the details." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)NotificationSwitchValueChanged:(id)sender {
    if ([sender isOn]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"MessageSwitchFlag"];
        
        //Push Notification
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            // Register for Push Notitications
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                            UIUserNotificationTypeBadge |
                                                            UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
             (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        }
        
    }else{
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MessageSwitchFlag"];
    }

}
@end
