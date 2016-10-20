//
//  WLILike.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILike.h"

@implementation WLILike

//Initializes WLILike object from NSDictionary that was created by JSON parsing.
- (id)initWithDictionary:(NSDictionary*)likeWithInfo {
    self = [self init];
    if (self) {
        
        _likeID = [self integerFromDictionary:likeWithInfo forKey:@"likeID"];
        NSDictionary *rawUser = [self dictionaryFromDictionary:likeWithInfo forKey:@"user"];
        _user = [[WLIUser alloc] initWithDictionary:rawUser];
    }
    
    return self;
}

@end
