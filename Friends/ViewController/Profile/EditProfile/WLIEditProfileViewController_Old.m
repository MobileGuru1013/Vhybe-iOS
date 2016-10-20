//
//  WLIEditProfileViewController.m
//  Friends
//
//  Created by Planet 1107 on 21/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIEditProfileViewController.h"
#import "WLIAppDelegate.h"

@implementation WLIEditProfileViewController

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
    // Do any additional setup after loading the view from its nib.
    self.title = @"Edit Profile";
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.adjustsImageWhenHighlighted = NO;
    saveButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    [saveButton setImage:[UIImage imageNamed:@"nav-btn-save.png"] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(barButtonItemSaveTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    
    [self.scrollViewEditProfile addSubview:self.viewContentEditProfile];
    toolbar.mainScrollView = self.scrollViewEditProfile;
    
    if (sharedConnect.currentUser.userType == WLIUserTypeCompany) {
        self.viewCompany.hidden = NO;
        self.viewContentEditProfile.frame = CGRectMake(self.viewContentEditProfile.frame.origin.x, self.viewContentEditProfile.frame.origin.y, self.viewContentEditProfile.frame.size.width, CGRectGetMaxY(self.viewCompany.frame));
        toolbar.textFields = @[self.textFieldUsername, self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldFullName, self.textFieldPhone, self.textFieldWeb];
        [self.mapViewLocation addAnnotation:sharedConnect.currentUser];
    } else if (sharedConnect.currentUser.userType == WLIUserTypePerson) {
        self.viewCompany.hidden = YES;
        self.viewContentEditProfile.frame = CGRectMake(self.viewContentEditProfile.frame.origin.x, self.viewContentEditProfile.frame.origin.y, self.viewContentEditProfile.frame.size.width, CGRectGetMaxY(self.textFieldFullName.frame) +20.0f);
        toolbar.textFields = @[self.textFieldUsername, self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldFullName];
    } else {
        NSLog(@"unknown user type");
    }
    
    self.scrollViewEditProfile.contentSize = self.viewContentEditProfile.frame.size;
    
    //self.imageViewAvatar.layer.cornerRadius = 3.0f;
    self.imageViewAvatar.layer.masksToBounds = YES;
    NSURL *avatarURL = [NSURL URLWithString:sharedConnect.currentUser.userAvatarPath];
    [self.imageViewAvatar setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:@"avatar-empty.png"]];
    
    self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    self.textFieldEmail.text = sharedConnect.currentUser.userEmail;
    self.textFieldFullName.text = sharedConnect.currentUser.userFullName;
    self.textFieldUsername.text = sharedConnect.currentUser.userUsername;
    self.textFieldWeb.text = sharedConnect.currentUser.companyWeb;
    self.textFieldPhone.text = sharedConnect.currentUser.companyPhone;
    self.textFieldAddress.text = sharedConnect.currentUser.companyAddress;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions methods

- (void)barButtonItemSaveTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    
    if (!self.textFieldEmail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password and repassword doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldFullName.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Full Name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.imageViewAvatar.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Avatar image is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
        NSString *password;
        if (self.textFieldPassword.text.length) {
            if (self.textFieldPassword.text.length < 4) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your password needs to be at least 4 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            } else {
                password = self.textFieldPassword.text;
            }
        }
        
        if (sharedConnect.currentUser.userType == WLIUserTypeCompany) {
            if (!self.textFieldPhone.text.length) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Phone is required for companies." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (!self.textFieldWeb.text.length) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Website is required for companies" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else {
                CLLocationCoordinate2D coordinate;
                NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:self.mapViewLocation.annotations.count];
                if (self.mapViewLocation.annotations.count) {
                    [annotations addObjectsFromArray:self.mapViewLocation.annotations];
                    for (int i = 0; i < annotations.count; i++) {
                        id <MKAnnotation> annotation = annotations[i];
                        if ([annotation isKindOfClass:[MKUserLocation class]]) {
                            [annotations removeObjectAtIndex:i];
                            break;
                        }
                    }
                    if (annotations.count) {
                        coordinate = [annotations[0] coordinate];
                        
                        [hud show:YES];
                        UIImage *image;
                        if (imageReplaced) {
                            image = self.imageViewAvatar.image;
                        }
                        
                        [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypeCompany userEmail:self.textFieldEmail.text password:password userAvatar:image userFullName:self.textFieldFullName.text userInfo:@"" latitude:coordinate.latitude longitude:coordinate.longitude companyAddress:self.textFieldAddress.text companyPhone:self.textFieldPhone.text companyWeb:self.textFieldWeb.text onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
                            [hud hide:YES];
                            self.mapViewLocation.delegate = nil;
                            [self.mapViewLocation setUserTrackingMode:MKUserTrackingModeNone];
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please drop pin on map to mark location of your company." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }
            }
        } else {
            [hud show:YES];
            UIImage *image;
            if (imageReplaced) {
                image = self.imageViewAvatar.image;
            }
            
            [sharedConnect updateUserWithUserID:sharedConnect.currentUser.userID userType:WLIUserTypePerson userEmail:self.textFieldEmail.text password:password userAvatar:image userFullName:self.textFieldFullName.text userInfo:@"" latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
                [hud hide:YES];
                self.mapViewLocation.delegate = nil;
                [self.mapViewLocation setUserTrackingMode:MKUserTrackingModeNone];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }
}

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender {
    
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showFromTabBar:appDelegate.tabBarController.tabBar];
}

- (IBAction)handleLongTapGesture:(UILongPressGestureRecognizer *)sender {
    
    CGPoint touchPoint = [sender locationInView:self.mapViewLocation];
    CLLocationCoordinate2D coordinate = [self.mapViewLocation convertPoint:touchPoint toCoordinateFromView:self.mapViewLocation];
    
    if (CLLocationCoordinate2DIsValid(coordinate)) {
        if (self.mapViewLocation.annotations.count) {
            NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapViewLocation.annotations];
            for (int i = 0; i < annotations.count; i++) {
                id <MKAnnotation> annotation = annotations[i];
                if ([annotation isKindOfClass:[MKUserLocation class]]) {
                    [annotations removeObjectAtIndex:i];
                    break;
                }
            }
            [self.mapViewLocation removeAnnotations:annotations];
        }
        sharedConnect.currentUser.coordinate = coordinate;
        if (sharedConnect.currentUser.userFullName.length) {
            sharedConnect.currentUser.title = sharedConnect.currentUser.userFullName;
        } else if (sharedConnect.currentUser.userUsername.length) {
            sharedConnect.currentUser.title = sharedConnect.currentUser.userUsername;
        } else {
            sharedConnect.currentUser.title = @"Please add Full Name";
        }
        sharedConnect.currentUser.subtitle = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
        [self.mapViewLocation addAnnotation:sharedConnect.currentUser];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count) {
                CLPlacemark *placemark = placemarks[0];
                
                NSMutableString *address = [NSMutableString string];
                if (placemark.thoroughfare.length) {
                    [address appendString:placemark.thoroughfare];
                }
                if (placemark.subThoroughfare.length) {
                    [address appendFormat:@" %@", placemark.subThoroughfare];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.locality.length) {
                    [address appendString:placemark.locality];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.administrativeArea.length) {
                    [address appendString:placemark.administrativeArea];
                }
                if (address.length) {
                    [address appendFormat:@", "];
                }
                if (placemark.country.length) {
                    [address appendString:placemark.country];
                }
                
                if (address.length) {
                    self.textFieldAddress.text = address;
                } else {
                    self.textFieldAddress.text = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
                }
                
            } else {
                self.textFieldAddress.text = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
            }
        }];
    }
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    imageReplaced = YES;
    self.imageViewAvatar.image = info[UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    if (!locatedUser) {
        MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1));
        [self.mapViewLocation setRegion:region animated:YES];
        locatedUser = YES;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    NSString *annotationIdentifier = @"CompanyPin";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        annotationView.image = [UIImage imageNamed:@"map-pin.png"];
        annotationView.canShowCallout = YES;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    //view.selected = NO;
    //id < MKAnnotation > annotation = view.annotation;
}

- (void)dealloc {
    
    self.mapViewLocation.delegate = nil;
    self.mapViewLocation.userTrackingMode = MKUserTrackingModeNone;
}


@end
