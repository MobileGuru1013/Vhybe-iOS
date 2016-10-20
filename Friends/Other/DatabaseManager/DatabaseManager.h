//
//  DatabaseManager.h
//  Cena
//
//  Created by Sandeep Mahajan on 03/09/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DatabaseManager : NSObject {
    BOOL isDBUpdatingInProgress;
}

@property (strong, nonatomic) FMDatabase *db;
@property (readwrite) BOOL isDBUpdatingInProgress;

+ (DatabaseManager*)getInstance;

- (void)setupDatabase;
- (BOOL)createStructure;
- (void)saveChat:(NSDictionary*)parameter;

- (NSMutableArray*)getResultDataForQuery:(NSString*)query withParameter:(NSString*)parameter;
- (NSMutableArray*)getResultDataForQuery:(NSString*)query;
- (void)getResultDataForQuery:(NSString*)query onCompletion:(void (^)(NSMutableArray* results))completion;

- (NSMutableArray*)selectChat:(int)to_id from_id:(int)from_id;
- (int)getUnreadCount:(int)to_id from_id:(int)from_id;
- (BOOL)markAsRead:(int)to_id from_id:(int)from_id;
- (NSMutableArray*)getLastMessage:(int)to_id from_id:(int)from_id;
- (NSMutableArray*)getchatdetail :(NSString *)fromid withoffset:(NSString *)offset;
- (NSMutableArray*)getgrpchatdetail :(NSString *)group_id withoffset:(NSString *)offset;

@end
