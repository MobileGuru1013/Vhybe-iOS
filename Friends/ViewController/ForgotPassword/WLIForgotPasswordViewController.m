//
//  WLIForgotPasswordViewController.m
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIForgotPasswordViewController.h"
#import "NSString+FontAwesome.h"

@interface WLIForgotPasswordViewController ()

@end

@implementation WLIForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Forgot Password";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lbl_Email.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Email.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"];
    self.lbl_Email.textColor = [UIColor whiteColor];
    self.lbl_Email.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtEmail.layer.masksToBounds=YES;
    self.txtEmail.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtEmail.layer.borderWidth= 1.0f;
    self.txtEmail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtEmail.leftViewMode = UITextFieldViewModeAlways;

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

- (IBAction)SendButtonPressed:(id)sender {
    if (self.txtEmail.text.length) {
        if (![self verifyEmailAddress:self.txtEmail.text]) {
            [[[UIAlertView alloc] initWithTitle:@"Oops. Invalid email" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else
        {
            //WebService
        }
    }
    else
        [[[UIAlertView alloc] initWithTitle:@"Message" message:@"Please enter email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (BOOL)verifyEmailAddress:(NSString*)email {
    NSString *emailRegEx =
    @"(?:[A-za-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:email];
}

@end
