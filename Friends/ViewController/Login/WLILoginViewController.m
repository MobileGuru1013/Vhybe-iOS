//
//  WLILoginViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILoginViewController.h"
#import "WLIAppDelegate.h"
#import "WLITimelineViewController.h"
#import "WLIForgotPasswordViewController.h"
#import "NSString+FontAwesome.h"

@implementation WLILoginViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //self.title = @"Login";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];

    [self.scrollViewLogin addSubview:self.viewContentLogin];
    self.scrollViewLogin.contentSize = self.viewContentLogin.frame.size;
    toolbar.mainScrollView = self.scrollViewLogin;
    toolbar.textFields = @[self.textFieldUsername, self.textFieldPassword];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.lbl_Email.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Email.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"];
    self.lbl_Email.textColor = [UIColor whiteColor];
    self.lbl_Email.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.textFieldUsername.layer.masksToBounds=YES;
    self.textFieldUsername.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.textFieldUsername.layer.borderWidth= 1.0f;
    self.textFieldUsername.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.textFieldUsername.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Password.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Password.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_Password.textColor = [UIColor whiteColor];
    self.lbl_Password.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CALayer *PasswordRightBorder = [CALayer layer];
    PasswordRightBorder.frame = CGRectMake(self.textFieldPassword.frame.size.width-1, 0.0f, 1.0f, self.textFieldPassword.frame.size.height);
    PasswordRightBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.textFieldPassword.layer addSublayer:PasswordRightBorder];
    CALayer *PasswordBottomBorder = [CALayer layer];
    PasswordBottomBorder.frame = CGRectMake(0, self.textFieldPassword.frame.size.height-1, self.textFieldPassword.frame.size.width, 1.0f);
    PasswordBottomBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.textFieldPassword.layer addSublayer:PasswordBottomBorder];
    self.textFieldPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.textFieldPassword.leftViewMode = UITextFieldViewModeAlways;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {
    
    if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldPassword.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [self.view endEditing:YES];
        [hud show:YES];
        [sharedConnect loginUserWithUsername:self.textFieldUsername.text andPassword:self.textFieldPassword.text onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
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
            } else if (serverResponseCode == NOT_FOUND) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong E-Mail. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (serverResponseCode == UNAUTHORIZED) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (IBAction)buttonForgotTouchUpInside:(id)sender {
    
    WLIForgotPasswordViewController *commentsViewController = [[WLIForgotPasswordViewController alloc] initWithNibName:@"WLIForgotPasswordViewController" bundle:nil];
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (IBAction)buttonSignUpTouchUpInside:(id)sender {
    WLIRegistrationViewController *registerViewController = [[WLIRegistrationViewController alloc] initWithNibName:@"WLIRegistrationViewController" bundle:nil];
    UINavigationController *registerNavigationViewController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
    registerNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:registerNavigationViewController animated:YES completion:^{ }];
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
            
            [tempController dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
