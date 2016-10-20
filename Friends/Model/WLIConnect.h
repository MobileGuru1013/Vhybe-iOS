//
//  WLIConnect.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"
#import "AFNetworking.h"

#import "WLIUser.h"
#import "WLIPost.h"
#import "WLILike.h"
#import "WLIFollow.h"
#import "WLIComment.h"

enum ServerResponse {
    OK = 200,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    CONFLICT = 409,
    SERVICE_UNAVAILABLE = 503,
    NO_CONNECTION,
    UNKNOWN_ERROR,
    PARTIAL_CONTENT,
    USER_EXISTS,
    USER_CREATED,
    LIKE_CREATED,
    LIKE_EXISTS
};

typedef enum ServerResponse ServerResponse;

@interface WLIConnect : NSObject {
    
    AFHTTPRequestOperationManager *httpClient;
    SBJsonParser *json;
}

@property (readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (readonly, nonatomic) NSDateFormatter *dateOnlyFormatter;
@property (strong, nonatomic) WLIUser *currentUser;

+ (WLIConnect*) sharedConnect;

#pragma mark - user

- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)registerUserWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email userAvatar:(UIImage*)userAvatar userType:(int)userType userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)userWithUserID:(int)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

//- (void)updateUserWithUserID:(int)userID userType:(WLIUserType)userType userEmail:(NSString*)userEmail password:(NSString*)password userAvatar:(UIImage*)userAvatar userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)updateUserWithUserID:(int)userID userEmail:(NSString*)userEmail userAvatar:(UIImage*)userAvatar userFullName:(NSString*)userFullName latitude:(float)latitude longitude:(float)longitude userGender:(NSString*)userGender userDOB:(NSDate*)userDOB userMaritialStatus:(NSString *)userMaritialStatus userLocation:(NSString *)userLocation  userInterests:(NSString *)userInterests userOccupation:(NSString *)userOccupation onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion;

- (void)newUsersWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion;

- (void)usersForSearchString:(NSString*)searchString interests:(NSString *)interests occupation:(NSString *)occupation gender:(NSString *)gender maxage:(NSInteger)maxage minage:(NSInteger)minage maritalstatus:(NSString *)maritalstatus location:(NSString *)location lat:(float)lat longitude:(float)longitude page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion;

- (void)usersAroundLatitude:(float)latitude longitude:(float)longitude distance:(float)distance page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion;

- (void)timelineForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (void)RecentActivityForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (void)ForgotPassword:(NSString *)userEmail onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

#pragma mark - posts

- (void)sendPostWithTitle:(NSString*)postTitle postKeywords:(NSArray*)postKeywords postImage:(UIImage*)postImage onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion;

- (void)recentPostsWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;

- (void)popularPostsOnPage:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion;


#pragma mark - comments

- (void)sendCommentOnPostID:(int)postID withCommentText:(NSString*)commentText onCompletion:(void (^)(WLIComment *comment, ServerResponse serverResponseCode))completion;

- (void)removeCommentWithCommentID:(int)commentID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)commentsForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *comments, ServerResponse serverResponseCode))completion;


#pragma mark - likes

- (void)setLikeOnPostID:(int)postID onCompletion:(void (^)(WLILike *like, ServerResponse serverResponseCode))completion;

- (void)removeLikeWithLikeID:(int)likeID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)likesForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *likes, ServerResponse serverResponseCode))completion;


#pragma mark - follow

- (void)setFollowOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion;

- (void)sendFriendRequestOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion;

- (void)UnfriendRequestOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion;

- (void)ResponseFriendRequestOnUserID:(int)userID Approved:(NSString *)Status onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion;

- (void)friendRequestForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion;

- (void)removeFollowWithFollowID:(int)followID onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)changePasswordforEmailID:(NSString *)emailID oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)followersForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *followers, ServerResponse serverResponseCode))completion;

- (void)followingForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion;

- (void)logout;

#pragma mark - Chat

- (void)getChatDataUserID:(int)userID onCompletion:(void (^)(NSMutableArray *chatData, ServerResponse serverResponseCode))completion;

-(void)sendChatDataUserID:(int)userID toUser:(int)toID message:(NSString *)message onCompletion:(void (^)(ServerResponse serverResponseCode))completion;

-(void)getChatDetailDataUserID:(int)userID toUser:(int)toID lastSyncDate:(NSString *)lastSyncDate onCompletion:(void (^)(NSMutableArray *chatDetail,ServerResponse serverResponseCode))completion;

-(void)getChatDetailDataUserID:(int)userID lastSyncDate:(NSString *)lastSyncDate onCompletion:(void (^)(NSMutableArray *chatDetail,ServerResponse serverResponseCode))completion;

- (void)sendChatImageFromUser:(int)userID toUser:(int)fromID userAvatar:(UIImage*)userAvatar onCompletion:(void (^)(NSString *imageUrl, ServerResponse serverResponseCode))completion;

- (void)getInterestsonCompletion:(void (^)(ServerResponse serverResponseCode))completion;

- (void)getOccupationonCompletion:(void (^)(ServerResponse serverResponseCode))completion;

@end
