//
//  WLIFollow.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLIFollow : WLIObject

@property (nonatomic) int followID;
@property (nonatomic, strong) NSDate *followDate;
@property (nonatomic, strong) WLIUser *follower;
@property (nonatomic, strong) WLIUser *following;

- (id)initWithDictionary:(NSDictionary*)followWithInfo;

@end
