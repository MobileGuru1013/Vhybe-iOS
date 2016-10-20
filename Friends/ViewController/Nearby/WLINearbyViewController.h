//
//  WLINearbyViewController.h
//  Friends
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WLIViewController.h"
#import "UIImageView+AFNetworking.h"

@interface WLINearbyViewController : WLIViewController <MKMapViewDelegate> {
    
    CLLocation *lastLocation;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapViewNearby;
@property (strong, nonatomic) NSArray *users;

@end
