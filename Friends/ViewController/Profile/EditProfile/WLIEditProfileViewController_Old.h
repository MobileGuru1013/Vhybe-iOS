//
//  WLIEditProfileViewController.h
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIViewController.h"
#import "UIImageView+AFNetworking.h"

@interface WLIEditProfileViewController : WLIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, UIActionSheetDelegate> {
    BOOL imageReplaced;
    BOOL locatedUser;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewEditProfile;
@property (strong, nonatomic) IBOutlet UIView *viewContentEditProfile;
@property (strong, nonatomic) IBOutlet UIView *viewCompany;

@property (strong, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRepassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldFullName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPhone;
@property (strong, nonatomic) IBOutlet UITextField *textFieldWeb;
@property (strong, nonatomic) IBOutlet UITextField *textFieldAddress;
@property (strong, nonatomic) IBOutlet MKMapView *mapViewLocation;

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender;
- (IBAction)handleLongTapGesture:(UILongPressGestureRecognizer *)sender;

@end
