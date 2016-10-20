//
//  WLIPost.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIUser.h"

@interface WLIPost : WLIObject

@property (nonatomic) int postID;
@property (nonatomic, strong) NSString *postTitle;
@property (nonatomic, strong) NSString *postImagePath;
@property (nonatomic, strong) NSDate *postDate;
@property (nonatomic, strong) NSString *postTimeAgo;
@property (nonatomic, strong) NSMutableArray *postKeywords;
@property (nonatomic, strong) WLIUser *user;
@property (nonatomic) int postLikesCount;
@property (nonatomic) int postCommentsCount;
@property (nonatomic) BOOL likedThisPost;
@property (nonatomic) BOOL commentedThisPost;

- (id)initWithDictionary:(NSDictionary*)postWithInfo;

@end
