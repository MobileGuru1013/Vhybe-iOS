//
//  WLIEditProfileViewController.m
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIEditProfileViewController.h"
#import "WLIAppDelegate.h"
#import "NSString+FontAwesome.h"
#import <QuartzCore/QuartzCore.h>
#import "WLISettingViewController.h"

#define kGoogleAutocompleteLink @"https://maps.googleapis.com/maps/api/place/autocomplete/json"

@interface WLIEditProfileViewController ()

@end

@implementation WLIEditProfileViewController
{
    WLIUser *currUser;
    BOOL imageReplaced;
    BOOL isOccupation;
    BOOL isOccupationSelected;
    UIButton *doneButton;
    UIButton *cancelButton;
    float locationLatitude;
    float locationLongitude;
    NSDate *selectedDate;
    
    CGFloat mainView_Y;
    NSMutableArray *arryLocationsValue;
    NSMutableArray *arryLocationsID;
    NSArray *arry_Occupation;
    
    BOOL isInterests;
    CGRect tbl_Frame;
    NSArray *arry_Interests;
    NSMutableArray *arry_InterestsSearch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = @"Edit Profile";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    currUser = [WLIConnect sharedConnect].currentUser;
    imageReplaced = NO;
    mainView_Y = self.scrlvEditProfile.frame.origin.y;
    self.tblvLocations.frame = CGRectMake(self.txtLocation.frame.origin.x, mainView_Y+self.txtLocation.frame.size.height, self.txtLocation.frame.size.width, 160);
    self.tblvLocations.hidden = YES;
    [self.view addSubview:self.tblvLocations];
    
    self.names = [NSMutableArray array];
    self.ven_Interests.delegate = self;
    self.ven_Interests.dataSource = self;
    self.ven_Interests.placeholderText = NSLocalizedString(@"Interests", nil);
    self.ven_Interests.toLabelText = NSLocalizedString(@"", nil);
    [self.ven_Interests setColorScheme:[UIColor colorWithRed:53./255.0f green:53./255.0f blue:53./255.0f alpha:1.0f]];
    //[self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    //ilself.tokenField.delimiters = @[@",", @";", @"--"];
    //[self.tokenField becomeFirstResponder];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserInterests"]) {
        arry_Interests = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInterests"]];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserOccupation"]) {
        arry_Occupation = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserOccupation"]];
    }
    tbl_Frame = self.tblvLocations.frame;
    isInterests = NO;
    isOccupation = NO;
    isOccupationSelected = NO;
    
    [self.scrlvEditProfile addSubview:self.editProfileContentView];
    self.scrlvEditProfile.contentSize = self.editProfileContentView.frame.size;
    toolbar.mainScrollView = self.scrlvEditProfile;
    toolbar.textFields = @[self.txtFullName, self.txtLocation];
    self.scrlvEditProfile.delegate = self;
    
    [self.imgvUserImage setImageWithURL:[NSURL URLWithString:currUser.userAvatarPath]];
    [self.txtEMail setText:currUser.userEmail];
    [self.txtFullName setText:currUser.userFullName];
    if ([currUser.userGender isEqualToString:@"male"])
        self.sgmtGender.selectedSegmentIndex = 0;
    else if([currUser.userGender isEqualToString:@"female"])
        self.sgmtGender.selectedSegmentIndex = 1;
    if ([currUser.userMaritalStatus isEqualToString:@"single"])
        self.sgmtStatus.selectedSegmentIndex = 0;
    else if ([currUser.userMaritalStatus isEqualToString:@"married"])
        self.sgmtStatus.selectedSegmentIndex = 1;
    
    if (![currUser.userBirthDate isEqualToString:@"0000-00-00"] && currUser.userBirthDate)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        //[dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *formattedDate = [dateFormatter dateFromString:currUser.userBirthDate];
        selectedDate = formattedDate;
        [dateFormatter setDateFormat:@"MMM dd, YYYY"];
        NSString  *formattedDateString = [dateFormatter stringFromDate:formattedDate];
        self.txtDOB.text = formattedDateString;
    }
    
    [self.txtInterests setText:currUser.userInterests];
    if (currUser.userOccupation.length) {
        [self.txt_Occupation setText:currUser.userOccupation];
        isOccupationSelected=YES;
    }
    
    if (currUser.userInterests.length) {
        NSString *str = currUser.userInterests;
        NSArray *str_arry = [str componentsSeparatedByString:@","];
        for (int i=0; i<[str_arry count]-1; i++) {
            [self.names addObject:[str_arry objectAtIndex:i]];
        }
        [self.ven_Interests reloadData];
        [self.ven_Interests collapse];
    }
    
    locationLatitude = [currUser.userLatitude floatValue];
    locationLongitude = [currUser.userLongitude floatValue];
    [self.txtLocation setText:currUser.userLocation];
    
    // Done button for pickers
    doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake(0,self.datePickerView.frame.origin.y-34,60,34);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTintColor:[UIColor whiteColor]];
    [doneButton setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
    [doneButton addTarget:self action:@selector(doneMethod) forControlEvents:UIControlEventTouchUpInside];
    
    // Close button for picker
    cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(self.view.frame.size.width-60,self.datePickerView.frame.origin.y-34,60,34);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTintColor:[UIColor whiteColor]];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]];
    [cancelButton addTarget:self action:@selector(cancelMethod) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrlvEditProfile addSubview:doneButton];
    [self.scrlvEditProfile addSubview:cancelButton];
    [self.scrlvEditProfile addSubview:self.btn_save];
    
    self.lbl_FullName.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_FullName.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-user"];
    self.lbl_FullName.textColor = [UIColor whiteColor];
    self.lbl_FullName.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtFullName.layer.masksToBounds=YES;
    self.txtFullName.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtFullName.layer.borderWidth= 1.0f;
    self.txtFullName.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtFullName.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Email.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Email.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-envelope-o"];
    self.lbl_Email.textColor = [UIColor whiteColor];
    self.lbl_Email.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
//    self.txtEMail.layer.masksToBounds=YES;
//    self.txtEMail.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
//    self.txtEMail.layer.borderWidth= 1.0f;
    CALayer *bottomBorder = [CALayer layer];
     bottomBorder.frame = CGRectMake(self.txtEMail.frame.size.width-1, 0.0f, 1.0f, self.txtEMail.frame.size.height);
     bottomBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
     [self.txtEMail.layer addSublayer:bottomBorder];
    self.txtEMail.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtEMail.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Password.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Password.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-key"];
    self.lbl_Password.textColor = [UIColor whiteColor];
    self.lbl_Password.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txt_ChangePassword.layer.masksToBounds=YES;
    self.txt_ChangePassword.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txt_ChangePassword.layer.borderWidth= 1.0f;
    self.txt_ChangePassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txt_ChangePassword.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_DOB.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_DOB.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-birthday-cake"];
    self.lbl_DOB.textColor = [UIColor whiteColor];
    self.lbl_DOB.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtDOB.layer.masksToBounds=YES;
    self.txtDOB.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtDOB.layer.borderWidth= 1.0f;
    self.txtDOB.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtDOB.leftViewMode = UITextFieldViewModeAlways;
    
    self.lbl_Gender.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Gender.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-circle-thin"];
    self.lbl_Gender.textColor = [UIColor whiteColor];
    self.lbl_Gender.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CGRect Genderframe = self.sgmtGender.frame;
    Genderframe.size.height = self.lbl_Gender.frame.size.height+8;
    self.sgmtGender.frame = Genderframe;
    /*self.view_GenderSgmt.layer.masksToBounds = YES;
    self.view_GenderSgmt.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.view_GenderSgmt.layer.borderWidth= 1.0f;*/
    CALayer *view_GenderSgmtBorder = [CALayer layer];
    view_GenderSgmtBorder.frame = CGRectMake(self.view_GenderSgmt.frame.size.width-1, 0.0f, 1.0f, self.view_GenderSgmt.frame.size.height);
    view_GenderSgmtBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_GenderSgmt.layer addSublayer:view_GenderSgmtBorder];
    CALayer *view_GenderbottomBorder = [CALayer layer];
    view_GenderbottomBorder.frame = CGRectMake(0.0f, self.view_GenderSgmt.frame.size.height - 1, self.view_GenderSgmt.frame.size.width, 1.0f);
    view_GenderbottomBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_GenderSgmt.layer addSublayer:view_GenderbottomBorder];
    
    self.lbl_RelationshipStatus.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_RelationshipStatus.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-venus-mars"];
    self.lbl_RelationshipStatus.textColor = [UIColor whiteColor];
    self.lbl_RelationshipStatus.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    CGRect lbl_RelationshipStatusframe = self.sgmtStatus.frame;
    lbl_RelationshipStatusframe.size.height = self.lbl_RelationshipStatus.frame.size.height+8;
    self.sgmtStatus.frame = lbl_RelationshipStatusframe;
    /*self.view_RelationshipSgmt.layer.masksToBounds = YES;
    self.view_RelationshipSgmt.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.view_RelationshipSgmt.layer.borderWidth= 1.0f;*/
    CALayer *view_RelationshipSgmtBorder = [CALayer layer];
    view_RelationshipSgmtBorder.frame = CGRectMake(self.view_RelationshipSgmt.frame.size.width-1, 0.0f, 1.0f, self.view_RelationshipSgmt.frame.size.height);
    view_RelationshipSgmtBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_RelationshipSgmt.layer addSublayer:view_RelationshipSgmtBorder];
    CALayer *view_RelationshipSgmtbottomBorder = [CALayer layer];
    view_RelationshipSgmtbottomBorder.frame = CGRectMake(0.0f, self.view_RelationshipSgmt.frame.size.height - 1, self.view_RelationshipSgmt.frame.size.width, 1.0f);
    view_RelationshipSgmtbottomBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.view_RelationshipSgmt.layer addSublayer:view_RelationshipSgmtbottomBorder];
    
    self.lbl_Interest.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Interest.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-heart"];
    self.lbl_Interest.textColor = [UIColor whiteColor];
    self.lbl_Interest.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.ven_Interests.layer.masksToBounds=YES;
    self.ven_Interests.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.ven_Interests.layer.borderWidth= 1.0f;
    self.ven_Interests.verticalInset = 2.0;
    self.ven_Interests.placeholderText = @"Interests";
    /*self.txtInterests.layer.masksToBounds=YES;
    self.txtInterests.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtInterests.layer.borderWidth= 1.0f;
    CALayer *txtInterestsBorder = [CALayer layer];
    txtInterestsBorder.frame = CGRectMake(self.txtInterests.frame.size.width-1, 0.0f, 1.0f, self.txtInterests.frame.size.height);
    txtInterestsBorder.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0].CGColor;
    [self.txtInterests.layer addSublayer:txtInterestsBorder];
    self.txtInterests.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtInterests.leftViewMode = UITextFieldViewModeAlways;*/
    
    self.lbl_Location.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Location.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-map-marker"];
    self.lbl_Location.textColor = [UIColor whiteColor];
    self.lbl_Location.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txtLocation.layer.masksToBounds=YES;
    self.txtLocation.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txtLocation.layer.borderWidth= 1.0f;
    self.txtLocation.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtLocation.leftViewMode = UITextFieldViewModeAlways;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Personal" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino" size:18.0]}];
    self.lbl_Personal.attributedText = str;
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Other" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Palatino" size:18.0]}];
    self.lbl_Other.attributedText = str1;
    
    self.lbl_Occupation.font = [UIFont fontWithName:kFontAwesomeFamilyName size:20];
    self.lbl_Occupation.text = [NSString fontAwesomeIconStringForIconIdentifier:@"fa-briefcase"];
    self.lbl_Occupation.textColor = [UIColor whiteColor];
    self.lbl_Occupation.backgroundColor = [UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0];
    self.txt_Occupation.layer.masksToBounds=YES;
    self.txt_Occupation.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.txt_Occupation.layer.borderWidth= 1.0f;
    self.txt_Occupation.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txt_Occupation.leftViewMode = UITextFieldViewModeAlways;
    
    self.tblvLocations.layer.masksToBounds=YES;
    self.tblvLocations.layer.borderColor=[[UIColor colorWithRed:53./255. green:53./255. blue:53./255. alpha:1.0]CGColor];
    self.tblvLocations.layer.borderWidth= 1.0f;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.datePickerView.hidden = YES;
    [self.datePickerView setBackgroundColor:[UIColor whiteColor]];
    doneButton.hidden = YES;
    cancelButton.hidden = YES;
    self.datePickerView.maximumDate = [[NSDate date] dateByAddingTimeInterval:-60*60*24*365*11];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.scrlvEditProfile.exclusiveTouch = YES;
    
    self.imgvUserImage.layer.cornerRadius = self.imgvUserImage.frame.size.width/2;//half of the width
    self.imgvUserImage.layer.borderColor=[UIColor colorWithRed:127./255. green:127./255. blue:127./255. alpha:1.0].CGColor;
    self.imgvUserImage.layer.borderWidth=4.0f;
    self.imgvUserImage.layer.masksToBounds = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while moving to the other screen.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

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

#pragma mark - Action Methods


- (IBAction)ChangePasswordClicked:(id)sender {
    WLISettingViewController *settingViewController = [[WLISettingViewController alloc] initWithNibName:@"WLISettingViewController" bundle:nil];
    UINavigationController *settingNavigationController = [[UINavigationController alloc] initWithRootViewController:settingViewController];
    settingNavigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:settingNavigationController animated:YES completion:nil];
}

- (IBAction)UserImageClicked:(id)sender {
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showFromTabBar:appDelegate.tabBarController.tabBar];
}

- (IBAction)DOBClicked:(id)sender {
    self.datePickerView.hidden = NO;
    [self.scrlvEditProfile bringSubviewToFront:self.datePickerView];
    doneButton.hidden = NO;
    cancelButton.hidden = NO;
    
}

- (IBAction)saveClicked:(id)sender {
    
            UIImage *image;
            NSString *locationText;
            NSString *Gender;
            NSString *Status;
            NSString *Occupation;
            NSMutableString *str;
    
    if (self.names) {
        str = [[NSMutableString alloc] initWithString:@""];
        for (NSString *interests in self.names) {
            [str appendString:[NSString stringWithFormat:@"%@,",interests]];
        }
    }
    if (isOccupationSelected) {
        Occupation = self.txt_Occupation.text;
    }
    if (imageReplaced) {
           image = self.imgvUserImage.image;
     }
     if (locationLatitude && locationLongitude) {
           locationText = self.txtLocation.text;
     }
    if (self.sgmtGender.selectedSegmentIndex == 0)
        Gender = @"male";
    else if (self.sgmtGender.selectedSegmentIndex == 1)
        Gender = @"female";
    if (self.sgmtStatus.selectedSegmentIndex == 0)
        Status = @"single";
    else if (self.sgmtStatus.selectedSegmentIndex == 1)
        Status = @"married";
    if (self.txtDOB.text.length) {
        if (![self verifyFullName:self.txtFullName.text]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Please enter valid full name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            [hud show:YES];
            [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userEmail:self.txtEMail.text userAvatar:image userFullName:self.txtFullName.text latitude:locationLatitude longitude:locationLongitude userGender:Gender userDOB:selectedDate userMaritialStatus:Status userLocation:locationText userInterests:str userOccupation:Occupation onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
                [hud hide:YES];
                if (serverResponseCode != OK)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Network Error, Please Try Again Later" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                    [alert show];
                }
                else
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
        }
    }else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Please enter valid BirthDate." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    
}

- (BOOL)verifyFullName:(NSString*)FullName {
    NSString *FullNameRegEx = @"^[a-zA-Z]+[\\s]+[a-zA-Z]+$";
    NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", FullNameRegEx];
    return [regExPredicate evaluateWithObject:FullName];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Camera"]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera Not Available!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    imageReplaced = YES;
    self.imgvUserImage.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DatePicker methods

-(void)doneMethod
{
    selectedDate = self.datePickerView.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY"];
    NSString  *formattedDateString = [dateFormatter stringFromDate:self.datePickerView.date];
    self.txtDOB.text = formattedDateString;
    doneButton.hidden = YES;
    cancelButton.hidden = YES;
    self.datePickerView.hidden = YES;
}

-(void)cancelMethod
{
    doneButton.hidden = YES;
    cancelButton.hidden = YES;
    self.datePickerView.hidden = YES;
}

#pragma mark - TextView Delegate methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 2) {
        isOccupation = YES;
        isOccupationSelected = NO;
        [self.txt_Occupation setText:@""];
    }else
    {
        isOccupation = NO;
        [self.txtLocation setText:@""];
        locationLatitude = 0.0;
        locationLongitude = 0.0;
    }
    
        [self.scrlvEditProfile setContentOffset:CGPointMake(0, (textField.frame.origin.y-mainView_Y) - mainView_Y) animated:YES];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 2)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",textField.text];
        arry_InterestsSearch = [NSMutableArray arrayWithArray:[arry_Occupation filteredArrayUsingPredicate:predicate]];
        [self.tblvLocations reloadData];
        self.tblvLocations.hidden = NO;
    }
    else
    {
        if (![textField.text isEqualToString:@""]) {
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@?input=%@&types=%@&key=%@",kGoogleAutocompleteLink, textField.text, @"(cities)", @"AIzaSyBAXCzXn17NxPOpVHUQIn-ZmfbdPswOipI"];
            NSURL *url = [[NSURL alloc] initWithString:urlAsString];
            NSLog(@"%@", urlAsString);
            [hud show:YES];
            [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if (error) {
                    [self GoogleAutoCompleteFailed:error];
                } else {
                    [self GoogleAutoCompleteResponse:data];
                }
            }];
        }

    }
        return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.tblvLocations.hidden = YES;
}

#pragma mark - Keyboard Notification

- (void)keyboardWillDisappear:(NSNotification *)n
{
    NSLog(@"SCRL: %f",self.scrlvEditProfile.contentOffset.y);
    if(self.scrlvEditProfile.contentOffset.y!=mainView_Y)
    {
        CGRect frame = self.scrlvEditProfile.frame;
        frame.origin.y = mainView_Y;
        self.scrlvEditProfile.frame = frame;
    }
}

#pragma mark - Google Autocomplete

-(void)GoogleAutoCompleteResponse:(NSData *)response
{
    NSError *error;
    [hud hide:YES];
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    NSLog(@"Response: %@",parsedObject);
    if([[parsedObject valueForKey:@"status"] isEqualToString:@"OK"])
    {
        arryLocationsValue = [[NSMutableArray alloc] init];
        arryLocationsID = [[NSMutableArray alloc] init];
        self.tblvLocations.hidden = NO;
        for (NSDictionary *objects in [parsedObject valueForKey:@"predictions"]) {
            [arryLocationsValue addObject:[objects valueForKey:@"description"]];
            [arryLocationsID addObject:[objects valueForKey:@"place_id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblvLocations reloadData];
        });
        
    }
    else
    {
        NSLog(@"Status:%@, Error: %@",[parsedObject valueForKey:@"status"],[parsedObject valueForKey:@"error_message"]);
    }
    
}

-(void)GoogleAutoCompleteFailed:(NSError *)error
{
    NSLog(@"Error: %@",error);
}

-(void)GooglePlacesResponse:(NSData *)response
{
    NSError *error;
    
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:response options:0 error:&error];
    NSLog(@"Response: %@",parsedObject);
    if([[parsedObject valueForKey:@"status"] isEqualToString:@"OK"])
    {
       locationLatitude = [[[[[parsedObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] floatValue];
        locationLongitude = [[[[[parsedObject objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] floatValue];
    }
    else
    {
        NSLog(@"Status:%@, Error: %@",[parsedObject valueForKey:@"status"],[parsedObject valueForKey:@"error_message"]);
    }
    
}

-(void)GooglePlacesFailed:(NSError *)error
{
    NSLog(@"Error: %@",error);
}

#pragma mark - TableView Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isInterests || isOccupation)
        return [arry_InterestsSearch count];
    else
    return [arryLocationsValue count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [hud hide:YES];
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (isInterests || isOccupation)
        cell.textLabel.text = [arry_InterestsSearch objectAtIndex:indexPath.row];
    else
    cell.textLabel.text = [arryLocationsValue objectAtIndex:indexPath.row];
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tblvLocations.hidden = YES;
    
    if (isInterests) {
        [self.names addObject:[arry_InterestsSearch objectAtIndex:indexPath.row]];
        [self.ven_Interests reloadData];
        [self.ven_Interests collapse];
        [self.ven_Interests resignFirstResponder];
        isInterests = NO;
        self.tblvLocations.frame = tbl_Frame;
        if(self.scrlvEditProfile.contentOffset.y!=mainView_Y)
        {
            CGRect frame = self.scrlvEditProfile.frame;
            frame.origin.y = mainView_Y;
            self.scrlvEditProfile.frame = frame;
        }
    }
    else if (isOccupation)  {
        self.txt_Occupation.text = [arry_InterestsSearch objectAtIndex:indexPath.row];
        [self.txt_Occupation resignFirstResponder];
        [self keyboardWillDisappear:nil];
        isOccupation = NO;
        isOccupationSelected = YES;
        self.tblvLocations.frame = tbl_Frame;
    }

    else
    {
        self.txtLocation.text = [arryLocationsValue objectAtIndex:indexPath.row];
        [self.txtLocation resignFirstResponder];
        NSString *urlAsString = [NSString stringWithFormat:@"%@?placeid=%@&key=%@",@"https://maps.googleapis.com/maps/api/place/details/json", [arryLocationsID objectAtIndex:[indexPath row]], @"AIzaSyBAXCzXn17NxPOpVHUQIn-ZmfbdPswOipI"];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        NSLog(@"%@", urlAsString);
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (error) {
                [self GooglePlacesFailed:error];
            } else {
                [self GooglePlacesResponse:data];
            }
        }];
    }
    
}

#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    //[self.names addObject:text];
    //[self.ven_Interests reloadData];
    [tokenField collapse];
    [tokenField resignFirstResponder];
    self.tblvLocations.hidden = YES;
    isInterests = NO;
    self.tblvLocations.frame = tbl_Frame;
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.names removeObjectAtIndex:index];
    [self.ven_Interests reloadData];
}

-(void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text
{
    isInterests = YES;
    CGRect frame = self.tblvLocations.frame;
    frame.origin.y = 35+self.ven_Interests.frame.size.height;
    self.tblvLocations.frame = frame;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",text];
    arry_InterestsSearch = [NSMutableArray arrayWithArray:[arry_Interests filteredArrayUsingPredicate:predicate]];
    [self.tblvLocations reloadData];
    self.tblvLocations.hidden = NO;
}

-(void)tokenFieldDidBeginEditing:(VENTokenField *)tokenField
{
    [self.scrlvEditProfile setContentOffset:CGPointMake(0, (self.ven_Interests.frame.origin.y-mainView_Y) - mainView_Y-50) animated:YES];
}

#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.names[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.names count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu Interests", [self.names count]];
}

#pragma mark - ScrollView Delegates

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1) {
        self.tblvLocations.hidden = YES;
        isInterests = NO;
        isOccupation = NO;
        self.tblvLocations.frame = tbl_Frame;
        [self.ven_Interests collapse];
        [self.ven_Interests resignFirstResponder];
        [self.txtInterests resignFirstResponder];
        [self.txt_Occupation resignFirstResponder];
        [self.txtLocation resignFirstResponder];
        [self keyboardWillDisappear:nil];

    }
}

@end
