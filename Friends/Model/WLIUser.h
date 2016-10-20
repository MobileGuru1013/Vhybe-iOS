//
//  WLIUser.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

typedef enum {
    WLIUserTypeUnknown = 0,
    WLIUserTypePerson = 1,
    WLIUserTypeCompany = 2
} WLIUserType;

@interface WLIUser : WLIObject <MKAnnotation>

@property (nonatomic) int userID;
@property (nonatomic) WLIUserType userType;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *userFullName;
@property (nonatomic, strong) NSString *userInfo;
@property (nonatomic, strong) NSString *userAvatarPath;
@property (nonatomic, strong) NSString *userUsername;
@property (nonatomic, strong) NSString *userBirthDate;
@property (nonatomic, strong) NSString *userGender;
@property (nonatomic, strong) NSString *userInterests;
@property (nonatomic, strong) NSString *userOccupation;
@property (nonatomic, strong) NSString *userLocation;
@property (nonatomic, strong) NSString *userMaritalStatus;
@property (nonatomic, strong) NSString *userLatitude;
@property (nonatomic, strong) NSString *userLongitude;
@property (nonatomic, strong) NSString *userFriends;
@property (nonatomic, strong) NSString *userFriendStatus;
@property (nonatomic, strong) NSString *userDeviceToken;
@property (nonatomic, strong) NSString *userDeviceType;
@property (nonatomic, strong) NSString *userChannelID;
@property (nonatomic, assign) BOOL followingUser;

//when userType == WLIUserTypeCompany
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *companyAddress;
@property (nonatomic, strong) NSString *companyPhone;
@property (nonatomic, strong) NSString *companyWeb;
@property (nonatomic, strong) NSString *companyEmail;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic) int followersCount;
@property (nonatomic) int followingCount;

- (id)initWithDictionary:(NSDictionary*)userWithInfo;


@end
