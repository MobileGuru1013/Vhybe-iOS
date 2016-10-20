//
//  WLILike.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLILike : WLIObject

@property (nonatomic) int likeID;
@property (nonatomic, strong) WLIUser *user;

- (id)initWithDictionary:(NSDictionary*)likeWithInfo;

@end
