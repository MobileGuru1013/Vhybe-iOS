//
//  WLIPost.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPost.h"

@implementation WLIPost

- (id)initWithDictionary:(NSDictionary*)postWithInfo {

    self = [self init];
    if (self) {
        _postID = [self integerFromDictionary:postWithInfo forKey:@"postID"];
        _postTitle = [self stringFromDictionary:postWithInfo forKey:@"postTitle"];
        _postImagePath = [self stringFromDictionary:postWithInfo forKey:@"postImage"];
        _postDate = [self dateFromDictionary:postWithInfo forKey:@"postDate"];
        _postTimeAgo = [self stringFromDictionary:postWithInfo forKey:@"timeAgo"];
        NSDictionary *rawUser = [self dictionaryFromDictionary:postWithInfo forKey:@"user"];
        _user = [[WLIUser alloc] initWithDictionary:rawUser];
        _postLikesCount = [self integerFromDictionary:postWithInfo forKey:@"totalLikes"];
        _postCommentsCount = [self integerFromDictionary:postWithInfo forKey:@"totalComments"];
        _likedThisPost = [self boolFromDictionary:postWithInfo forKey:@"isLiked"];
        _commentedThisPost = [self boolFromDictionary:postWithInfo forKey:@"isCommented"];
    }
    
    return self;
}

@end
