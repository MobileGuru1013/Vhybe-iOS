//
//  DatabaseManager.m
//  Cena
//
//  Created by Sandeep Mahajan on 03/09/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//

#import "DatabaseManager.h"
#import "NSFileManager+DirectoryLocations.h"
#import "WLIConnect.h"

@implementation DatabaseManager

@synthesize db, isDBUpdatingInProgress;

+ (DatabaseManager*)getInstance {
    static dispatch_once_t once;
    static DatabaseManager *databaseManager;
    dispatch_once(&once, ^{ databaseManager = [[self alloc] init]; });
    return databaseManager;
}

- (id)init{
    self = [super init];
    if (self) {
        // Allocate memory
    }
    return self;
}

- (void)setupDatabase {
#if TARGET_IPHONE_SIMULATOR
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Chat.db"];
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"isTblCreated"];
#else
    NSString *path = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *dbPath = [NSString stringWithFormat:@"%@/Chat.db", path];
#endif
    db = [FMDatabase databaseWithPath:dbPath];
    NSLog(@"%@", dbPath);
    if([db open]) {
        NSLog(@"Database Successfully Created and Opened...");
    }
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isTblCreated"]) {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isTblCreated"];
        [self createStructure];
    }
}

- (BOOL)createStructure {
    NSArray *tables = @[@"tbl_chat.sql"];
    //NSString *dbStructurePath = NULL;
    if([db open]) {
        for(NSString *tblName in tables) {
            NSString *dbStructureStr = @"CREATE TABLE `tbl_chat_detail` (            `chat_detail_id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,            `to_user_id`	NUMERIC NOT NULL,            `from_user_id`	NUMERIC NOT NULL,            `message`	TEXT NOT NULL,            `isImage`	INTEGER DEFAULT 0,            `unread`	INTEGER NOT NULL DEFAULT 0,            `userid1_isDeleted`	INTEGER NOT NULL DEFAULT 0,            `userid2_isDeleted`	INTEGER NOT NULL DEFAULT 0,            `isDeleted_user1`	INTEGER NOT NULL DEFAULT 0,            `isDeleted_user2`	INTEGER NOT NULL DEFAULT 0,            `created_date`	timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,            `server_date`	timestamp            );";
            dbStructureStr = [dbStructureStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if(dbStructureStr) {
                BOOL isExecuted = [db executeUpdate:dbStructureStr];
                NSLog(@"%@ is created. %i", tblName, isExecuted);
            }
        }
    }
    return YES;
}
// one to one
- (NSMutableArray*)getchatdetail :(NSString *)fromid withoffset:(NSString *)offset {
    
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_chat where chat_id in (select chat_id  from tbl_chat where(( to_id='%d' and from_id= '%@' ) or (to_id='%@' and from_id= '%d' ))order by chat_id desc limit 10 offset %@ )order by chat_id",[WLIConnect sharedConnect].currentUser.userID,fromid,fromid,[WLIConnect sharedConnect].currentUser.userID,offset];
    
    return [self getResultDataForQuery:sql];
}


// for group
- (NSMutableArray*)getgrpchatdetail :(NSString *)group_id withoffset:(NSString *)offset
{
    NSString *sql = [NSString stringWithFormat:@"select * from tbl_chat where chat_id in (select chat_id  from tbl_chat where( group_id='%@' )order by chat_id desc limit 10 offset %@ )order by chat_id",group_id,offset];
    return [self getResultDataForQuery:sql];
    
}


- (void)saveChat:(NSDictionary*)parameter {
    self.isDBUpdatingInProgress = YES;
    if([db open]) {
        
        //NSString *sql = @"INSERT INTO tbl_chat_detail (to_user_id, from_user_id, message, created_date, unread, isImage, server_date) VALUES (:to_user_id, :from_user_id, :message, :created_date, :unread, :isImage, :server_date)";
        NSString *message = [[parameter valueForKey:@"message"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        NSString *sql =[NSString stringWithFormat:@"INSERT INTO tbl_chat_detail (to_user_id, from_user_id, message, created_date, unread, isImage, server_date) VALUES (%@,%@,'%@','%@',%@,%@,'%@');",[parameter valueForKey:@"to_user_id"],[parameter valueForKey:@"from_user_id"],message,[parameter valueForKey:@"created_date"],[parameter valueForKey:@"unread"],[parameter valueForKey:@"isImage"],[parameter valueForKey:@"server_date"]];
        BOOL success = [db executeUpdate:sql];
        //BOOL success = [db executeUpdate:sql withParameterDictionary:parameter];
        if(!success)
            NSLog(@"Unable to save chat");
    }
    self.isDBUpdatingInProgress = NO;
}

#pragma mark - Select Statement

- (NSMutableArray*)getResultDataForQuery:(NSString*)query withParameter:(NSString*)parameter {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if(parameter != nil)
        query = [NSString stringWithFormat:@"%@(%@)", query, parameter];
    if([db open]) {
        FMResultSet *rs = [db executeQuery:query];
        while ([rs next]) {
            [list addObject:[rs resultDictionary]];
        }
    }
    return list;
}

- (NSMutableArray*)getResultDataForQuery:(NSString*)query {
    NSLog(@"Query: %@", query);
    return [self getResultDataForQuery:query withParameter:nil];
}

-(void)getResultDataForQuery:(NSString *)query onCompletion:(void (^)(NSMutableArray *results))completion
{
    NSLog(@"Query: %@", query);
    completion([self getResultDataForQuery:query withParameter:nil]);
}

- (NSMutableArray*)selectChat:(int)to_id from_id:(int)from_id {
    
//    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_chat WHERE to_id = %i AND from_id = %i OR to_id = %i AND from_id = %i", to_id, from_id, from_id, to_id];
    
     NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_chat "];
    
    NSLog(@"Query: %@", sql);
    return [self getResultDataForQuery:sql];
}



- (int)getUnreadCount:(int)to_id from_id:(int)from_id {
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(chat_id) as COUNTS FROM tbl_chat WHERE to_id = %i AND from_id = %i AND unreadmsgflag = 1", to_id, from_id];
    NSLog(@"Query: %@", sql);
    NSMutableArray *tempArray = [self getResultDataForQuery:sql];
    if(tempArray && [tempArray count] > 0)
        return [[tempArray objectAtIndex:0] intValue];
    return 0;
}

- (BOOL)markAsRead:(int)to_id from_id:(int)from_id {
    NSString *sql = [NSString stringWithFormat:@"UPDATE tbl_chat SET unreadmsgflag = 0 WHERE to_id = %i AND from_id = %i", to_id, from_id];
    BOOL success = FALSE;
    NSLog(@"Query: %@", sql);
    if([db open]) {
        success = [db executeUpdate:sql];
        if(!success)
            NSLog(@"Unable to update count");
    }
    return success;
}

- (NSMutableArray*)getLastMessage:(int)to_id from_id:(int)from_id {
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM tbl_chat WHERE chat_id = \"(SELECT MAX(chat_id) FROM tbl_chat WHERE to_id = %i AND from_id = %i OR to_id = %i AND from_id = %i)\"", to_id, from_id, from_id, to_id];
    NSLog(@"Query: %@", sql);
    return [self getResultDataForQuery:sql];
}

@end
