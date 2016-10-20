//
//  WLIForgotPasswordViewController.h
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIViewController.h"

@interface WLIForgotPasswordViewController : WLIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Email;

//Methods
- (IBAction)SendButtonPressed:(id)sender;


@end
