//
//  ChatModel.h
//  UUChatTableView
//
//  Created by shake on 15/1/6.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIUser.h"

@interface ChatModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) WLIUser *toUser;

- (void)populateRandomDataSource;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addOtherSpecifiedItem:(NSDictionary *)dic;
- (void)addMYSpecifiedItem:(NSDictionary *)dic;
- (void)loadPreviousChat:(NSDictionary *)dic;
- (void)loadPreviousImage:(NSDictionary *)dic;

@end
