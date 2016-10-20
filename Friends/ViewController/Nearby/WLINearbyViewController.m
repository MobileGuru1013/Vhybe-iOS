//
//  WLINearbyViewController.m
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLINearbyViewController.h"
#import "WLIProfileViewController.h"
#import "WLIUser.h"
#import "GlobalDefines.h"
#import "NSString+FontAwesome.h"

@implementation WLINearbyViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Nearby";
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon-Small-40"]];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reloadButton.adjustsImageWhenHighlighted = NO;
    reloadButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    //[reloadButton setImage:[UIImage imageNamed:@"nav-btn-reload.png"] forState:UIControlStateNormal];
    [reloadButton.titleLabel setFont:[UIFont fontWithName:kFontAwesomeFamilyName size:20]];
    reloadButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [reloadButton setTitle:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-refresh"] forState:UIControlStateNormal];
    [reloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reloadButton addTarget:self action:@selector(barButtonItemReloadTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reloadButton];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (lastLocation && !loading) {
        MKUserLocation *userLocation = self.mapViewNearby.userLocation;
        if (userLocation) {
            CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
            lastLocation = newLocation;
            
            [self reloadData];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data loading methods

- (void)reloadData {
    
    [hud show:YES];
    loading = YES;
    int page = (self.users.count / kDefaultPageSize) + 1;
    [sharedConnect usersAroundLatitude:lastLocation.coordinate.latitude longitude:lastLocation.coordinate.longitude distance:10000 page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *users, ServerResponse serverResponseCode) {
        [hud hide:YES];
        loading = NO;
        self.users = users;
        loadMore = users.count == kDefaultPageSize;
        [self.mapViewNearby addAnnotations:users];
        [self.mapViewNearby setRegion:MKCoordinateRegionMake(lastLocation.coordinate, MKCoordinateSpanMake(0, 5)) animated:YES];
    }];
}


#pragma mark - Actions methods

- (void)barButtonItemReloadTouchUpInside:(UIBarButtonItem*)barButtonItemSave {
    
    if (!loading) {
        CLLocationCoordinate2D coordinate = self.mapViewNearby.centerCoordinate;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        lastLocation = location;
        [self reloadData];
    }
}


#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    if (!loading && (!lastLocation || [newLocation distanceFromLocation:lastLocation] > 1000)) {
        lastLocation = newLocation;
        [self reloadData];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    WLIUser *company = (WLIUser*)annotation;
    
    NSString *annotationIdentifier = @"CompanyPin";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        annotationView.image = [UIImage imageNamed:@"map-pin.png"];
        annotationView.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        annotationView.leftCalloutAccessoryView = imageView;
        
        UIImageView *overlay = [[UIImageView alloc] initWithFrame:imageView.frame];
        overlay.image = [UIImage imageNamed:@"avatar-overlay.png"];
        [imageView addSubview:overlay];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        button.tintColor = [UIColor colorWithRed:255.0f/255.0f green:80.0f/255.0f blue:70.0f/255.0f alpha:1.0f];
        annotationView.rightCalloutAccessoryView = button;
    }
    NSURL *url = [NSURL URLWithString:company.userAvatarPath];
    [(UIImageView*)annotationView.leftCalloutAccessoryView setImageWithURL:url placeholderImage:nil];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    WLIUser *company = (WLIUser*)view.annotation;
    WLIProfileViewController *profileViewController = [[WLIProfileViewController alloc] initWithNibName:@"WLIProfileViewController" bundle:nil];
    profileViewController.user = company;
    [self.navigationController pushViewController:profileViewController animated:YES];
}


@end
