//
//  WLIRegistrationViewController.m
//  Friends
//
//  Created by Kapil on 14/05/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "WLIRegistrationViewController.h"
#import "WLIAppDelegate.h"
#import "WLIProfileViewController.h"
#import "WLIEditProfileViewController.h"
#import "WLITimelineViewController.h"
#import "UIImage+FontAwesome.h"
#import "NSString+FontAwesome.h"

@interface WLIRegistrationViewController ()

@end

@implementation WLIRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Registration";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
//    UIBarButtonItem *submitBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(barButtonItemSubmitTouchUpInside:)];
//    self.navigationItem.rightBarButtonItem = submitBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lbl_Email.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Email.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"];
    self.lbl_Email.textColor = [UIColor whiteColor];
    self.lbl_Email.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtEMail.layer.masksToBounds=YES;
    self.txtEMail.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtEMail.layer.borderWidth= 1.0f;
    self.txtEMail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtEMail.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Password.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Password.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_Password.textColor = [UIColor whiteColor];
    self.lbl_Password.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CALayer *PasswordRightBorder = [CALayer layer];
    PasswordRightBorder.frame = CGRectMake(self.txtPassword.frame.size.width-1, 0.0f, 1.0f, self.txtPassword.frame.size.height);
    PasswordRightBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.txtPassword.layer addSublayer:PasswordRightBorder];
    CALayer *PasswordBottomBorder = [CALayer layer];
    PasswordBottomBorder.frame = CGRectMake(0, self.txtPassword.frame.size.height-1, self.txtPassword.frame.size.width, 1.0f);
    PasswordBottomBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.txtPassword.layer addSublayer:PasswordBottomBorder];
    self.txtPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtPassword.leftViewMode = UITextFieldViewModeAlways;
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
//
//- (void)barButtonItemSubmitTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
//    
//}


- (IBAction)RegisterButtonPressed:(id)sender {
    
    if (!self.txtEMail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (self.txtPassword.text.length < 6 || self.txtPassword.text.length < 6) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required. Your password should be at least 6 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }else if(![self verifyEmailAddress:self.txtEMail.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops. Invalid email" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }else{
        UIImage *avatar = [UIImage imageWithIcon:@"fa-picture-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:255] fontSize:320];
        [sharedConnect registerUserWithUsername:@"" password:self.txtPassword.text email:self.txtEMail.text userAvatar:avatar userType:WLIUserTypePerson userFullName:@"" userInfo:@"" latitude:0.0 longitude:0.0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
            [hud hide:YES];
            if (serverResponseCode == OK) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self removeAllViewController];
                    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
                    WLITimelineViewController *timelineViewController = (WLITimelineViewController *)[appDelegate.tabBarController.viewControllers[0] topViewController];
                    [timelineViewController reloadData:YES];
                }];
            } else if (serverResponseCode == NO_CONNECTION) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (serverResponseCode == CONFLICT) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"User already exists. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (IBAction)LoginButtonPressed:(id)sender {
    WLILoginViewController *loginViewController = [[WLILoginViewController alloc] initWithNibName:@"WLILoginViewController" bundle:nil];
    UINavigationController *loginNavigationViewController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:loginNavigationViewController animated:YES completion:^{ }];
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

-(void)removeAllViewController
{
    NSMutableArray *array_controllers = [[NSMutableArray alloc] init];
    
    // Check which view controller is presented on window.
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
        [array_controllers addObject:topController];
        
    }
    
    
    for (NSInteger i=[array_controllers count]-1; i>=0; i--) {
        
        UIViewController *tempController = [array_controllers objectAtIndex:i];
        
        if ([tempController isKindOfClass:[WLIProfileViewController class]] || [tempController isKindOfClass:[WLIEditProfileViewController class]])
            NSLog(@"Profile view is presenting");
        else{
            
            [tempController dismissViewControllerAnimated:NO completion:nil];
        }
    }
}


@end
