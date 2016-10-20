//
//  WLIRegistrationViewController.h
//  Friends
//
//  Created by Kapil on 14/05/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLIRegistrationViewController : WLIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtEMail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Email;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Password;

//Methods
- (IBAction)RegisterButtonPressed:(id)sender;
- (IBAction)LoginButtonPressed:(id)sender;

@end
