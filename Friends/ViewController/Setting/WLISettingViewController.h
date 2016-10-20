//
//  WLISettingViewController.h
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIViewController.h"

@interface WLISettingViewController : WLIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbl_OldPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbl_NewPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ConfirmPassword;
@property (weak, nonatomic) IBOutlet UISwitch *switch_notifications;

//Methods
- (IBAction)ChangePasswordClicked:(id)sender;
- (IBAction)NotificationSwitchValueChanged:(id)sender;

@end
