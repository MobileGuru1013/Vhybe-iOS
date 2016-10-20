//
//  WLIEditProfileViewController.h
//  Friends
//
//  Created by Kapil on 19/05/15.
//  Copyright (c) 2015 SIPL. All rights reserved.
//

#import "WLIViewController.h"
#import "VENTokenField.h"

@interface WLIEditProfileViewController : WLIViewController <UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,VENTokenFieldDataSource,VENTokenFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrlvEditProfile;
@property (strong, nonatomic) IBOutlet UIView *editProfileContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgvUserImage;
@property (weak, nonatomic) IBOutlet UITextField *txtFullName;
@property (weak, nonatomic) IBOutlet UITextField *txtEMail;
@property (weak, nonatomic) IBOutlet UITextField *txtDOB;
@property (weak, nonatomic) IBOutlet UITextField *txtInterests;
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UITableView *tblvLocations;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmtGender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sgmtStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FullName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Email;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Password;
@property (weak, nonatomic) IBOutlet UITextField *txt_ChangePassword;
@property (weak, nonatomic) IBOutlet UILabel *lbl_DOB;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Gender;
@property (weak, nonatomic) IBOutlet UILabel *lbl_RelationshipStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Location;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Interest;
@property (weak, nonatomic) IBOutlet UIView *view_GenderSgmt;
@property (weak, nonatomic) IBOutlet UIView *view_RelationshipSgmt;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Personal;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Other;
@property (weak, nonatomic) IBOutlet UIButton *btn_save;
@property (weak, nonatomic) IBOutlet VENTokenField *ven_Interests;
@property (strong, nonatomic) NSMutableArray *names;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Occupation;
@property (weak, nonatomic) IBOutlet UITextField *txt_Occupation;

//Methods
- (IBAction)UserImageClicked:(id)sender;
- (IBAction)DOBClicked:(id)sender;
- (IBAction)saveClicked:(id)sender;
-(void)GoogleAutoCompleteResponse:(NSData *)response;
-(void)GoogleAutoCompleteFailed:(NSError *)error;
- (IBAction)ChangePasswordClicked:(id)sender;

@end
