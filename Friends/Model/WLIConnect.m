//
//  WLIConnect.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIConnect.h"

//#define kBaseLink @"http://planet1107-solutions.net/wli/"
#define kBaseLink @"http://183.182.84.29:90/welikeapp/"
//#define kBaseLink @"http://173.245.72.50:90/welikeapp/"
#define kAPIKey @"!#wli!sdWQDScxzczFžŽYewQsq_?wdX09612627364[3072∑34260-#"
#define kConnectionTimeout 30
#define kCompressionQuality 1.0f

//Server status responses
#define kOK @"OK"
#define kBAD_REQUEST @"BAD_REQUEST"
#define kNO_CONNECTION @"NO_CONNECTION"
#define kSERVICE_UNAVAILABLE @"SERVICE_UNAVAILABLE"
#define kPARTIAL_CONTENT @"PARTIAL_CONTENT"
#define kCONFLICT @"CONFLICT"
#define kUNAUTHORIZED @"UNAUTHORIZED"
#define kNOT_FOUND @"NOT_FOUND"
#define kUSER_CREATED @"USER_CREATED"
#define kUSER_EXISTS @"USER_EXISTS"
#define kLIKE_CREATED @"LIKE_CREATED"
#define kLIKE_EXISTS @"LIKE_EXISTS"
#define kFORBIDDEN @"FORBIDDEN"
#define kCREATED @"CREATED"


@implementation WLIConnect

static WLIConnect *sharedConnect;

+ (WLIConnect*) sharedConnect {
    
    if (sharedConnect != nil) {
        return sharedConnect;
    }
    sharedConnect = [[WLIConnect alloc] init];
    return sharedConnect;
}

- (id)init {
    self = [super init];
    
    // comment for user persistance
    // [self removeCurrentUser];
    
    if (self) {
        httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseLink]];
        [httpClient.requestSerializer setValue:kAPIKey forHTTPHeaderField:@"api_key"];
        httpClient.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        json = [[SBJsonParser alloc] init];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _dateOnlyFormatter = [[NSDateFormatter alloc] init];
        [_dateOnlyFormatter setDateFormat:@"MM/dd/yyyy"];
        [_dateOnlyFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSData *archivedUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"_currentUser"];
        if (archivedUser) {
            _currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUser];
        }
    }
    return self;
}

- (void)saveCurrentUser {
    
    if (self.currentUser) {
        NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:@"_currentUser"];
    }
}

- (void)removeCurrentUser {
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"_currentUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - User

- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (!username.length || !password.length) {
        completion(nil, BAD_REQUEST);
    } else {
        NSDictionary *parameters;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserDeviceToken"]) {
            parameters = @{@"email": username, @"password": password,@"deviceToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDeviceToken"],@"isdevice":@"ios"};
        }
        else
        parameters = @{@"email": username, @"password": password};
        
        [httpClient POST:@"api/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [[WLIUser alloc] initWithDictionary:rawUser];
            
            [self saveCurrentUser];
            
            [self debugger:parameters.description methodLog:@"api/login" dataLogFormatted:responseObject];
            completion(_currentUser, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/login" dataLog:error.description];
            if (operation.response) {
                completion(nil, operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }];
    }
}

- (void)registerUserWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email userAvatar:(UIImage*)userAvatar userType:(int)userType userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (!password.length || !email.length) {
        completion(nil, BAD_REQUEST);
    } else {
        NSDictionary *parameters;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserDeviceToken"]) {
            parameters = @{@"username" : username, @"password" : password, @"email" : email, @"userFullname" : userFullName, @"userTypeID" : @(userType), @"userInfo" : userInfo, @"userLat" : @(latitude), @"userLong" : @(longitude), @"userAddress" : companyAddress, @"userPhone" : companyPhone, @"userWeb" : companyWeb,@"deviceToken":[[NSUserDefaults standardUserDefaults] objectForKey:@"UserDeviceToken"],@"isdevice":@"ios"};
        }
        else
        parameters = @{@"username" : username, @"password" : password, @"email" : email, @"userFullname" : userFullName, @"userTypeID" : @(userType), @"userInfo" : userInfo, @"userLat" : @(latitude), @"userLong" : @(longitude), @"userAddress" : companyAddress, @"userPhone" : companyPhone, @"userWeb" : companyWeb};
        [httpClient POST:@"api/register" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [[WLIUser alloc] initWithDictionary:rawUser];
            [self saveCurrentUser];
            [self debugger:parameters.description methodLog:@"api/register" dataLogFormatted:responseObject];
            completion(_currentUser, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/register" dataLog:error.description];
            if (operation.response) {
                completion(nil, operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }];
    }
}

- (void)userWithUserID:(int)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%d", self.currentUser.userID], @"forUserID": [NSString stringWithFormat:@"%d", userID]};
        [httpClient POST:@"api/getProfile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            if (user.userID == _currentUser.userID) {
                _currentUser = user;
                [self saveCurrentUser];
            }
            [self debugger:parameters.description methodLog:@"api/getProfile" dataLogFormatted:responseObject];
            completion(user, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getProfile" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

-(void)updateUserWithUserID:(int)userID userEmail:(NSString *)userEmail userAvatar:(UIImage *)userAvatar userFullName:(NSString *)userFullName latitude:(float)latitude longitude:(float)longitude userGender:(NSString *)userGender userDOB:(NSDate*)userDOB userMaritialStatus:(NSString *)userMaritialStatus userLocation:(NSString *)userLocation userInterests:(NSString *)userInterests userOccupation:(NSString *)userOccupation onCompletion:(void (^)(WLIUser *, ServerResponse))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"userID"];
//        if (userType) {
//            [parameters setObject:[NSString stringWithFormat:@"%d", userType] forKey:@"userTypeID"];
//        }
        if (userEmail.length) {
            [parameters setObject:userEmail forKey:@"email"];
        }
        if (userGender.length) {
            [parameters setObject:userGender forKey:@"userGender"];
        }
        /*if (userDOB.length) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd, YYYY"];
            NSDate *formattedDate = [dateFormatter dateFromString:userDOB];
            [parameters setObject:formattedDate forKey:@"userDob"];
        }*/
        if (userDOB) {
            [parameters setObject:userDOB forKey:@"userDob"];
        }
        
        if (userMaritialStatus.length) {
            [parameters setObject:userMaritialStatus forKey:@"userStatus"];
        }
        if (userLocation.length) {
            [parameters setObject:userLocation forKey:@"userLocation"];
            [parameters setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"userLat"];
            [parameters setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"userLong"];
        }
        if (userInterests.length) {
            [parameters setObject:userInterests forKey:@"userInterests"];
        }
        if (userOccupation.length) {
            [parameters setObject:userOccupation forKey:@"userOccupation"];
        }
//        if (password.length) {
//            [parameters setObject:password forKey:@"password"];
//        }
        if (userFullName.length) {
            [parameters setObject:userFullName forKey:@"userFullname"];
        }
//        if (userInfo.length) {
//            [parameters setObject:userInfo forKey:@"userInfo"];
//        }
//        if (companyAddress.length) {
//            [parameters setObject:companyAddress forKey:@"userAddress"];
//        }
//        if (companyPhone.length) {
//            [parameters setObject:companyPhone forKey:@"userPhone"];
//        }
//        if (companyWeb.length) {
//            [parameters setObject:companyWeb forKey:@"userWeb"];
//        }
        
        [httpClient POST:@"api/setProfile" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            self.currentUser = user;
            [self saveCurrentUser];
            
            [self debugger:parameters.description methodLog:@"api/setProfile" dataLogFormatted:responseObject];
            completion(user, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/setProfile" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

//- (void)updateUserWithUserID:(int)userID userType:(WLIUserType)userType userEmail:(NSString*)userEmail password:(NSString*)password userAvatar:(UIImage*)userAvatar userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
//    
//    
//}

- (void)newUsersWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion {
    
    NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%d", self.currentUser.userID], @"take": [NSString stringWithFormat:@"%d", pageSize]};
    [httpClient POST:@"api/getNewUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            [users addObject:user];
        }
        
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLogFormatted:responseObject];
        completion(users, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

-(void)usersForSearchString:(NSString *)searchString interests:(NSString *)interests occupation:(NSString *)occupation gender:(NSString *)gender maxage:(NSInteger)maxage minage:(NSInteger)minage maritalstatus:(NSString *)maritalstatus location:(NSString *)location lat:(float)lat longitude:(float)longitude page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *, ServerResponse))completion {
    
    /*if (!searchString.length) {
        completion(nil, BAD_REQUEST);
    } else {*/
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (searchString.length) {
        [parameters setObject:[searchString lowercaseString] forKey:@"searchTerm"];
    }
    if (interests.length) {
        [parameters setObject:[interests lowercaseString] forKey:@"interests"];
    }
    if (occupation.length) {
        [parameters setObject:[occupation lowercaseString] forKey:@"occupation"];
    }
    if (gender.length) {
        [parameters setObject:[gender lowercaseString] forKey:@"gender"];
    }
    if (maritalstatus.length) {
        [parameters setObject:[maritalstatus lowercaseString] forKey:@"maritalstatus"];
    }
    if (maxage) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)maxage] forKey:@"maxage"];
    }
    if (minage) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)minage] forKey:@"minage"];
    }
    if (page) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)page] forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"take"];
    }
    if (lat) {
        [parameters setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
    }
    if (longitude) {
        [parameters setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"long"];
    }
    
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        //[parameters setObject:searchString forKey:@"searchTerm"];
//        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
//        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    
        [httpClient POST:@"api/findUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = [responseObject objectForKey:@"items"];
            
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
                [users addObject:user];
            }
            
            [self debugger:parameters.description methodLog:@"api/findUsers" dataLogFormatted:responseObject];
            completion(users, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/findUsers" dataLog:error.description];
            if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
                completion(nil, NOT_FOUND);
            }
            else
                completion(nil, UNKNOWN_ERROR);
        }];
    //}
}

- (void)timelineForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        
        [httpClient POST:@"api/getTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            
            NSMutableArray *posts = [NSMutableArray arrayWithCapacity:rawPosts.count];
            for (NSDictionary *rawPost in rawPosts) {
                WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
                [posts addObject:post];
            }
            
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLogFormatted:responseObject];
            completion(posts, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

-(void)RecentActivityForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion
{
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        
        [httpClient POST:@"api/getRecentActivity" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            
            NSMutableArray *posts = [NSMutableArray arrayWithCapacity:rawPosts.count];
            for (NSDictionary *rawPost in rawPosts) {
                WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
                [posts addObject:post];
            }
            
            [self debugger:parameters.description methodLog:@"api/getRecentActivity" dataLogFormatted:responseObject];
            completion(posts, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getRecentActivity" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

- (void)usersAroundLatitude:(float)latitude longitude:(float)longitude distance:(float)distance page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", distance] forKey:@"distance"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    
    [httpClient POST:@"api/getLocationsForLatLong" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            [users addObject:user];
        }
        
        [self debugger:parameters.description methodLog:@"api/getLocationsForLatLong" dataLogFormatted:responseObject];
        completion(users, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLocationsForLatLong" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - posts

- (void)sendPostWithTitle:(NSString*)postTitle postKeywords:(NSArray*)postKeywords postImage:(UIImage*)postImage onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion {
    
    if (!postTitle.length && !postImage) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:postTitle forKey:@"postTitle"];
        
        [httpClient POST:@"api/sendPost" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (postImage) {
                NSData *imageData = UIImageJPEGRepresentation(postImage, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"postImage" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawPost = [responseObject objectForKey:@"item"];
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLogFormatted:responseObject];
            completion(post, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
        
        /*
        [httpClient POST:@"api/sendPost" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawPost = [responseObject objectForKey:@"item"];
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLogFormatted:responseObject];
            completion(post, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
         */
    }
}

- (void)recentPostsWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    
    [httpClient POST:@"api/getRecentPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        
        NSMutableArray *posts = [NSMutableArray arrayWithCapacity:rawPosts.count];
        for (NSDictionary *rawPost in rawPosts) {
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            [posts addObject:post];
        }
        
        [self debugger:parameters.description methodLog:@"api/getRecentPosts" dataLogFormatted:responseObject];
        completion(posts, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getRecentPosts" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)popularPostsOnPage:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    [httpClient POST:@"api/getPopularPosts" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawPosts = [responseObject objectForKey:@"items"];
        
        NSMutableArray *posts = [NSMutableArray arrayWithCapacity:rawPosts.count];
        for (NSDictionary *rawPost in rawPosts) {
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            [posts addObject:post];
        }
        
        [self debugger:parameters.description methodLog:@"api/getPopularPosts" dataLogFormatted:responseObject];
        completion(posts, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getPopularPosts" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - comments

- (void)sendCommentOnPostID:(int)postID withCommentText:(NSString*)commentText onCompletion:(void (^)(WLIComment *comment, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [parameters setObject:commentText forKey:@"commentText"];
    [httpClient POST:@"api/setComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawComment = [responseObject objectForKey:@"item"];
        WLIComment *comment = [[WLIComment alloc] initWithDictionary:rawComment];
        
        [self debugger:parameters.description methodLog:@"api/setComment" dataLogFormatted:responseObject];
        completion(comment, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setComment" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)removeCommentWithCommentID:(int)commentID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", commentID] forKey:@"commentID"];
    [httpClient POST:@"api/removeComment" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *rawComment = [responseObject objectForKey:@"item"];
        //WLIComment *comment = [[WLIComment alloc] initWithDictionary:rawComment];
        
        [self debugger:parameters.description methodLog:@"api/removeComment" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeComment" dataLog:error.description];
        completion(UNKNOWN_ERROR);
    }];
}

- (void)commentsForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *comments, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    [httpClient POST:@"api/getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawComments = [responseObject objectForKey:@"items"];
        
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:rawComments.count];
        for (NSDictionary *rawComment in rawComments) {
            WLIComment *comment = [[WLIComment alloc] initWithDictionary:rawComment];
            [comments addObject:comment];
        }
        
        [self debugger:parameters.description methodLog:@"api/getComments" dataLogFormatted:responseObject];
        completion(comments, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getComments" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - likes

- (void)setLikeOnPostID:(int)postID onCompletion:(void (^)(WLILike *like, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [httpClient POST:@"api/setLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawLike = [responseObject objectForKey:@"item"];
        WLILike *like = [[WLILike alloc] initWithDictionary:rawLike];
        
        [self debugger:parameters.description methodLog:@"api/setLike" dataLogFormatted:responseObject];
        completion(like, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setLike" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)removeLikeWithLikeID:(int)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [httpClient POST:@"api/removeLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLog:error.description];
        completion(UNKNOWN_ERROR);
    }];
}

- (void)likesForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *likes, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    [httpClient POST:@"api/getLikes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawLikes = [responseObject objectForKey:@"items"];
        
        NSMutableArray *likes = [NSMutableArray arrayWithCapacity:rawLikes.count];
        for (NSDictionary *rawLike in rawLikes) {
            WLILike *like = [[WLILike alloc] initWithDictionary:rawLike];
            [likes addObject:like];
        }
        
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLogFormatted:responseObject];
        completion(likes, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - follow

- (void)setFollowOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"followingID"];
    [httpClient POST:@"api/setFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount++;
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLogFormatted:responseObject];
        completion(follow, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

-(void)sendFriendRequestOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"friendID"];
    
    [httpClient POST:@"api/addFriend" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount++;
        [self debugger:parameters.description methodLog:@"api/addFriend" dataLogFormatted:responseObject];
        completion(follow, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/addFriend" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];

}

-(void)UnfriendRequestOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"friendID"];
    [httpClient POST:@"api/removeFriend" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount--;
        [self debugger:parameters.description methodLog:@"api/removeFriend" dataLogFormatted:responseObject];
        completion(follow, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeFriend" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
    
}

-(void)ResponseFriendRequestOnUserID:(int)userID Approved:(NSString *)Status onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"responderID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"requesterID"];
    [parameters setObject:Status forKey:@"approvalFlag"];
    [httpClient POST:@"api/friendRequestResponse" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount++;
        [self debugger:parameters.description methodLog:@"api/friendRequestResponse" dataLogFormatted:responseObject];
        completion(follow, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/friendRequestResponse" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
    
}

- (void)removeFollowWithFollowID:(int)followID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", followID] forKey:@"followingID"];
    [httpClient POST:@"api/removeFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        //WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount--;
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLog:error.description];
        completion(UNKNOWN_ERROR);
    }];
}

- (void)changePasswordforEmailID:(NSString *)emailID oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //[parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:emailID forKey:@"email"];
    [parameters setObject:oldPassword forKey:@"oldpassword"];
    [parameters setObject:newPassword forKey:@"newpassword"];
    [httpClient POST:@"api/changePassword" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        //WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        //self.currentUser.followingCount--;
        [self debugger:parameters.description methodLog:@"api/changePassword" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/changePassword" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: unauthorized (401)"]) {
            completion(UNAUTHORIZED);
        }
        else
            completion(UNKNOWN_ERROR);
    }];
}

- (void)followersForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *followers, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [httpClient POST:@"api/getFollowers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
                [users addObject:user];
            }
            
            [self debugger:parameters.description methodLog:@"api/getFollowers" dataLogFormatted:responseObject];
            completion(users, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFollowers" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

- (void)followingForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [httpClient POST:@"api/getFriends" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
                [users addObject:user];
            }
            
            [self debugger:parameters.description methodLog:@"api/getFriends" dataLogFormatted:responseObject];
            completion(users, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFriends" dataLog:error.description];
            if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
                completion(nil, NOT_FOUND);
            }
            else
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

- (void)friendRequestForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        //[parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [httpClient POST:@"api/getFriendInvitations" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"items"];
            
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
                [users addObject:user];
            }
            [self debugger:parameters.description methodLog:@"api/getFriendInvitations" dataLogFormatted:responseObject];
            completion(users, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getFriendInvitations" dataLog:error.description];
            if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
                completion(nil, NOT_FOUND);
            }
            else
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}


- (void)logout {
    
    _currentUser = nil;
    [self removeCurrentUser];
}

#pragma mark - chat

-(void)getChatDataUserID:(int)userID onCompletion:(void (^)(NSMutableArray *chatData, ServerResponse serverResponseCode))completion
{
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"userID"];
        [httpClient POST:@"api/getchatData" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawUsers = responseObject[@"item"];
            
            NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
            for (NSDictionary *rawUser in rawUsers) {
                //WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
                [users addObject:rawUser];
            }
            
            [self debugger:parameters.description methodLog:@"api/getchatData" dataLogFormatted:responseObject];
            completion(users, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getchatData" dataLog:error.description];
            if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
                completion(nil, NOT_FOUND);
            }
            else
                completion(nil, UNKNOWN_ERROR);
        }];
}

-(void)sendChatDataUserID:(int)userID toUser:(int)toID message:(NSString *)message onCompletion:(void (^)(ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", toID] forKey:@"toId"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"fromId"];
    [parameters setObject:message forKey:@"text"];
    [httpClient POST:@"api/addchat" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self debugger:parameters.description methodLog:@"api/addchat" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/addchat" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(NOT_FOUND);
        }
        else
            completion(UNKNOWN_ERROR);
    }];
}

-(void)getChatDetailDataUserID:(int)userID toUser:(int)toID lastSyncDate:(NSString *)lastSyncDate onCompletion:(void (^)(NSMutableArray *chatDetail,ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", toID] forKey:@"toId"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"fromId"];
    
    if (lastSyncDate.length) {
        [parameters setObject:lastSyncDate forKey:@"lastSyncDate"];
    }
    
    [httpClient POST:@"api/getchatDetail" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = responseObject[@"item"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            //WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
            [users addObject:rawUser];
        }
        [self debugger:parameters.description methodLog:@"api/getchatDetail" dataLogFormatted:responseObject];
        completion(users,OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getchatDetail" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(nil,NOT_FOUND);
        }
        else
            completion(nil,UNKNOWN_ERROR);
    }];
}

-(void)getChatDetailDataUserID:(int)userID lastSyncDate:(NSString *)lastSyncDate onCompletion:(void (^)(NSMutableArray *chatDetail,ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"userId"];
    
    if (lastSyncDate.length) {
        [parameters setObject:lastSyncDate forKey:@"lastSyncDate"];
    }
    
    [httpClient POST:@"api/getchatDetail" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = responseObject[@"item"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            //WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser[@"user"]];
            [users addObject:rawUser];
        }
        [self debugger:parameters.description methodLog:@"api/getchatDetail" dataLogFormatted:responseObject];
        completion(users,OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getchatDetail" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(nil,NOT_FOUND);
        }
        else
            completion(nil,UNKNOWN_ERROR);
    }];
}

-(void)sendChatImageFromUser:(int)userID toUser:(int)fromID userAvatar:(UIImage *)userAvatar onCompletion:(void (^)(NSString *imageUrl, ServerResponse serverResponseCode))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"toId"];
    [parameters setObject:[NSString stringWithFormat:@"%d", fromID] forKey:@"fromId"];
    [parameters setObject:@"Image" forKey:@"text"];
    [httpClient POST:@"api/addchat" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (userAvatar) {
            NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
            if (imageData) {
                [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = responseObject[@"item"];
        NSString *imagePath = responseObject[@"image"];
        
        
        [self debugger:parameters.description methodLog:@"api/addchat" dataLogFormatted:responseObject];
        completion(imagePath, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/addchat" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(nil, NOT_FOUND);
        }
        else
            completion(nil, UNKNOWN_ERROR);
    }];
}

-(void)getInterestsonCompletion:(void (^)(ServerResponse))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [httpClient POST:@"api/getInterest" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = responseObject[@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            [users addObject:[rawUser objectForKey:@"interests_name"]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:users forKey:@"UserInterests"];
        [self debugger:parameters.description methodLog:@"api/getInterest" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getInterest" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(NOT_FOUND);
        }
        else
            completion(UNKNOWN_ERROR);
    }];
}

-(void)getOccupationonCompletion:(void (^)(ServerResponse))completion
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [httpClient POST:@"api/getOccupations" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = responseObject[@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            [users addObject:[rawUser objectForKey:@"occupation"]];
        }
        [[NSUserDefaults standardUserDefaults] setObject:users forKey:@"UserOccupation"];
        [self debugger:parameters.description methodLog:@"api/getOccupations" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getOccupations" dataLog:error.description];
        if ([[error.userInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]) {
            completion(NOT_FOUND);
        }
        else
            completion(UNKNOWN_ERROR);
    }];
}

#pragma mark - debugger

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLog:(NSString *)data {
    
    #ifdef DEBUG
        NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, (NSDictionary *) [json objectWithString:data]);
    #else
    #endif
}

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLogFormatted:(NSString *)data {
    
    #ifdef DEBUG
        NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, data);
    #else
#endif
}

@end
