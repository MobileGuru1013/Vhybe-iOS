//
//  WLIRegisterViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIRegisterViewController.h"


@implementation WLIRegisterViewController


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
    //self.title = @"Register";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];

    [self.scrollViewRegister addSubview:self.viewContentRegister];
    [self adjustViewFrames];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Button methods

- (IBAction)buttonSelectAvatarTouchUpInside:(UIButton *)sender {
    
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Gallery", @"Camera", nil] showInView:self.view];
}

- (IBAction)buttonRegisterTouchUpInside:(id)sender {

    if (!self.textFieldEmail.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (self.textFieldPassword.text.length < 4 || self.textFieldRepassword.text.length < 4) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password is required. Your password should be at least 4 characters long." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldUsername.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Username is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (![self.textFieldPassword.text isEqualToString:self.textFieldRepassword.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Password and repassword doesn't match." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.textFieldFullName.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Full Name is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.imageViewAvatar.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Avatar image is required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        
        if (self.segmentedControlUserType.selectedSegmentIndex == 1) {
            if (!self.textFieldPhone.text.length) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Phone is required for companies." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            } else if (!self.textFieldWeb.text.length || !self.textFieldRepassword.text.length) {
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
                        
                        [self.view endEditing:YES];
                        [hud show:YES];
                        
                        [sharedConnect registerUserWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text email:self.textFieldEmail.text userAvatar:self.imageViewAvatar.image userType:WLIUserTypeCompany userFullName:self.textFieldFullName.text userInfo:@"" latitude:coordinate.latitude longitude:coordinate.longitude companyAddress:self.textFieldAddress.text companyPhone:self.textFieldPhone.text companyWeb:self.textFieldWeb.text onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
                            [hud hide:YES];
                            if (serverResponseCode == OK) {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            } else if (serverResponseCode == NO_CONNECTION) {
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            } else if (serverResponseCode == CONFLICT) {
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"User already exists. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            } else {
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                            }
                        }];
                    } else {
                        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please drop pin on map to mark location of your company." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    }
                }
            }
        } else {
            [self.view endEditing:YES];
            [hud show:YES];
            
            [sharedConnect registerUserWithUsername:self.textFieldUsername.text password:self.textFieldPassword.text email:self.textFieldEmail.text userAvatar:self.imageViewAvatar.image userType:WLIUserTypePerson userFullName:self.textFieldFullName.text userInfo:@"" latitude:0 longitude:0 companyAddress:@"" companyPhone:@"" companyWeb:@"" onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
                [hud hide:YES];
                if (serverResponseCode == OK) {
                    [self dismissViewControllerAnimated:YES completion:nil];
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
}

- (IBAction)segmentedControlUserTypeValueChanged:(UISegmentedControl *)sender {
    
    [self adjustViewFrames];
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
        WLIUser *companyUser = [[WLIUser alloc] init];
        companyUser.coordinate = coordinate;
        if (companyUser.userFullName.length) {
            companyUser.title = self.textFieldFullName.text;
        } else if (companyUser.userUsername.length) {
            companyUser.title = self.textFieldUsername.text;
        } else {
            companyUser.title = @"Please add Full Name";
        }
        companyUser.subtitle = [NSString stringWithFormat:@"%.6f, %.6f", coordinate.latitude, coordinate.longitude];
        [self.mapViewLocation addAnnotation:companyUser];
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
        annotationView.canShowCallout = NO;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    //view.selected = NO;
    //id < MKAnnotation > annotation = view.annotation;
}


#pragma mark - Other methods

- (void)adjustViewFrames {
    
    if (self.segmentedControlUserType.selectedSegmentIndex == 1) {
        self.viewCompany.hidden = NO;
        self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.viewCompany.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
        self.viewContentRegister.frame = CGRectMake(self.viewContentRegister.frame.origin.x, self.viewContentRegister.frame.origin.y, self.viewContentRegister.frame.size.width, CGRectGetMaxY(self.buttonRegister.frame) +20.0f);
        PNTToolbar *newToolbar = [PNTToolbar defaultToolbar];
        newToolbar.mainScrollView = self.scrollViewRegister;
        newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName, self.textFieldPhone, self.textFieldWeb];
    } else  {
        self.viewCompany.hidden = YES;
        self.buttonRegister.frame = CGRectMake(self.buttonRegister.frame.origin.x, CGRectGetMaxY(self.textFieldFullName.frame) +20.0f, self.buttonRegister.frame.size.width, self.buttonRegister.frame.size.height);
        self.viewContentRegister.frame = CGRectMake(self.viewContentRegister.frame.origin.x, self.viewContentRegister.frame.origin.y, self.viewContentRegister.frame.size.width, CGRectGetMaxY(self.buttonRegister.frame) +20.0f);
        PNTToolbar *newToolbar = [PNTToolbar defaultToolbar];
        newToolbar.mainScrollView = self.scrollViewRegister;
        newToolbar.textFields = @[self.textFieldEmail, self.textFieldPassword, self.textFieldRepassword, self.textFieldUsername, self.textFieldFullName];
    }
    self.scrollViewRegister.contentSize = self.viewContentRegister.frame.size;
}


- (void)dealloc {
    
    self.mapViewLocation.delegate = nil;
    self.mapViewLocation.userTrackingMode = MKUserTrackingModeNone;
}

@end
