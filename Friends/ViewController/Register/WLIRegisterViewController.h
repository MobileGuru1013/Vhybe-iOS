//
//  WLIRegisterViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLIRegisterViewController : WLIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, MKMapViewDelegate> {
    
    BOOL locatedUser;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewRegister;
@property (strong, nonatomic) IBOutlet UIView *viewContentRegister;
@property (strong, nonatomic) IBOutlet UIView *viewCompany;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRepassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFullName;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlUserType;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (strong, nonatomic) IBOutlet UITextField *textFieldWeb;
@property (strong, nonatomic) IBOutlet UITextField *textFieldAddress;
@property (strong, nonatomic) IBOutlet MKMapView *mapViewLocation;
@property (strong, nonatomic) IBOutlet UIButton *buttonRegister;

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender;
- (IBAction)segmentedControlUserTypeValueChanged:(UISegmentedControl *)sender;
- (IBAction)buttonRegisterTouchUpInside:(id)sender;

@end
