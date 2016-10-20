//
//  WLIFollow.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIFollow.h"

@implementation WLIFollow

//Initializes WLIFollow object from NSDictionary that was created by JSON parsing.
- (id)initWithDictionary:(NSDictionary*)followWithInfo {
    self = [self init];
    if (self) {
        
        _followID = [self integerFromDictionary:followWithInfo forKey:@"followID"];
        _followDate = [self dateFromDictionary:followWithInfo forKey:@"followDate"];
        NSDictionary *rawFollower = [self dictionaryFromDictionary:followWithInfo forKey:@"follower"];
        _follower = [[WLIUser alloc] initWithDictionary:rawFollower];
        NSDictionary *rawFollowing = [self dictionaryFromDictionary:followWithInfo forKey:@"following"];
        _following = [[WLIUser alloc] initWithDictionary:rawFollowing];
    }
    
    return self;
}

@end
