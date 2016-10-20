//
//  WLIUser.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIUser.h"

@implementation WLIUser

- (id)initWithDictionary:(NSDictionary*)userWithInfo {
   
    self = [self init];
    if (self) {
        _userID = [self integerFromDictionary:userWithInfo forKey:@"userID"];
        _userType = [self integerFromDictionary:userWithInfo forKey:@"userTypeID"];
        _userPassword = [self stringFromDictionary:userWithInfo forKey:@"password"];
        _userEmail = [self stringFromDictionary:userWithInfo forKey:@"email"];
        _userFullName = [self stringFromDictionary:userWithInfo forKey:@"userFullname"];
        _userUsername = [self stringFromDictionary:userWithInfo forKey:@"username"];
        _userInfo = [self stringFromDictionary:userWithInfo forKey:@"userInfo"];
        _userAvatarPath = [self stringFromDictionary:userWithInfo forKey:@"userAvatar"];
        _followingUser = [self boolFromDictionary:userWithInfo forKey:@"followingUser"];
        _followersCount = [self integerFromDictionary:userWithInfo forKey:@"followersCount"];
        _followingCount = [self integerFromDictionary:userWithInfo forKey:@"followingCount"];
        _userBirthDate = [self stringFromDictionary:userWithInfo forKey:@"birthDate"];
        _userGender = [self stringFromDictionary:userWithInfo forKey:@"gender"];
        _userInterests = [self stringFromDictionary:userWithInfo forKey:@"interests"];
        _userOccupation = [self stringFromDictionary:userWithInfo forKey:@"occupations"];
        _userLocation = [self stringFromDictionary:userWithInfo forKey:@"location"];
        _userMaritalStatus = [self stringFromDictionary:userWithInfo forKey:@"maritalStatus"];
        _userLatitude = [self stringFromDictionary:userWithInfo forKey:@"userLat"];
        _userLongitude = [self stringFromDictionary:userWithInfo forKey:@"userLong"];
        _userFriends = [self stringFromDictionary:userWithInfo forKey:@"friendCount"];
        _userFriendStatus = [self stringFromDictionary:userWithInfo forKey:@"friendshipStatus"];
        _userDeviceToken = [self stringFromDictionary:userWithInfo forKey:@"deviceToken"];
        _userDeviceType = [self stringFromDictionary:userWithInfo forKey:@"isdevice"];
        _userChannelID = [self stringFromDictionary:userWithInfo forKey:@"channnelId"];
        
        _companyAddress = [self stringFromDictionary:userWithInfo forKey:@"userAddress"];
        _companyPhone = [self stringFromDictionary:userWithInfo forKey:@"userPhone"];
        _companyWeb = [self stringFromDictionary:userWithInfo forKey:@"userWeb"];
        _companyEmail = [self stringFromDictionary:userWithInfo forKey:@"userEmail"];
    
        float latitude = [self floatFromDictionary:userWithInfo forKey:@"userLat"];
        float longitude = [self floatFromDictionary:userWithInfo forKey:@"userLong"];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        if (_userFullName.length) {
            _title = _userFullName;
        } else if (_userUsername.length) {
            _title = _userUsername;
        } else {
            _title = @"Please add Full Name";
        }
        
        /*if (_companyAddress.length) {
            _subtitle = _companyAddress;
        } else {
            _subtitle = [NSString stringWithFormat:@"%.6f, %.6f", latitude, longitude];
        }*/
    }
    
    return self;
}


#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInt:self.userID forKey:@"userID"];
    [encoder encodeInt:self.userType forKey:@"userType"];
    [encoder encodeObject:self.userPassword forKey:@"userPassword"];
    [encoder encodeObject:self.userEmail forKey:@"userEmail"];
    [encoder encodeObject:self.userFullName forKey:@"userFullName"];
    [encoder encodeObject:self.userInfo forKey:@"userInfo"];
    [encoder encodeObject:self.userAvatarPath forKey:@"userAvatarPath"];
    [encoder encodeFloat:self.coordinate.latitude forKey:@"latitude"];
    [encoder encodeFloat:self.coordinate.longitude forKey:@"longitude"];
    [encoder encodeObject:self.companyAddress forKey:@"companyAddress"];
    [encoder encodeObject:self.companyPhone forKey:@"companyPhone"];
    [encoder encodeObject:self.companyWeb forKey:@"companyWeb"];
    [encoder encodeObject:self.companyEmail forKey:@"companyEmail"];
    [encoder encodeInt:self.followersCount forKey:@"followersCount"];
    [encoder encodeInt:self.followingCount forKey:@"followingCount"];
    [encoder encodeObject:self.userBirthDate forKey:@"birthDate"];
    [encoder encodeObject:self.userGender forKey:@"gender"];
    [encoder encodeObject:self.userInterests forKey:@"interests"];
    [encoder encodeObject:self.userOccupation forKey:@"occupations"];
    [encoder encodeObject:self.userLocation forKey:@"location"];
    [encoder encodeObject:self.userMaritalStatus forKey:@"maritalStatus"];
    [encoder encodeObject:self.userLatitude forKey:@"userLat"];
    [encoder encodeObject:self.userLongitude forKey:@"userLong"];
    [encoder encodeObject:self.userFriends forKey:@"friendCount"];
    [encoder encodeObject:self.userFriendStatus forKey:@"friendshipStatus"];
    [encoder encodeObject:self.userDeviceToken forKey:@"deviceToken"];
    [encoder encodeObject:self.userDeviceType forKey:@"isdevice"];
    [encoder encodeObject:self.userChannelID forKey:@"ChannelID"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    self = [super init];
    if (self) {
        self.userID = [decoder decodeIntForKey:@"userID"];
        self.userType = [decoder decodeIntForKey:@"userType"];
        self.userPassword = [decoder decodeObjectForKey:@"userPassword"];
        self.userEmail = [decoder decodeObjectForKey:@"userEmail"];
        self.userFullName = [decoder decodeObjectForKey:@"userFullName"];
        self.userInfo = [decoder decodeObjectForKey:@"userInfo"];
        self.userAvatarPath = [decoder decodeObjectForKey:@"userAvatarPath"];
        float latitude = [decoder decodeFloatForKey:@"latitude"];
        float longitude = [decoder decodeFloatForKey:@"longitude"];
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        self.companyAddress = [decoder decodeObjectForKey:@"companyAddress"];
        self.companyPhone = [decoder decodeObjectForKey:@"companyPhone"];
        self.companyWeb = [decoder decodeObjectForKey:@"companyWeb"];
        self.companyEmail = [decoder decodeObjectForKey:@"companyEmail"];
        self.followersCount = [decoder decodeIntegerForKey:@"followersCount"];
        self.followingCount = [decoder decodeIntegerForKey:@"followingCount"];
        self.userBirthDate = [decoder decodeObjectForKey:@"birthDate"];
        self.userGender = [decoder decodeObjectForKey:@"gender"];
        self.userInterests = [decoder decodeObjectForKey:@"interests"];
        self.userOccupation = [decoder decodeObjectForKey:@"occupations"];
        self.userLocation = [decoder decodeObjectForKey:@"location"];
        self.userMaritalStatus = [decoder decodeObjectForKey:@"maritalStatus"];
        self.userLatitude = [decoder decodeObjectForKey:@"userLat"];
        self.userLongitude = [decoder decodeObjectForKey:@"userLong"];
        self.userFriends = [decoder decodeObjectForKey:@"friendCount"];
        self.userFriendStatus = [decoder decodeObjectForKey:@"friendshipStatus"];
        self.userDeviceToken = [decoder decodeObjectForKey:@"deviceToken"];
        self.userDeviceType = [decoder decodeObjectForKey:@"isdevice"];
        self.userChannelID = [decoder decodeObjectForKey:@"ChannelID"];
    }
    return self;
}


@end
