//
//  ChatManager.h
//  Cena
//
//  Created by Sandeep Mahajan on 27/08/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WLIUser.h"

@interface ChatManager : NSObject <NSStreamDelegate>
{
    NSInputStream *inputStream;
	NSOutputStream *outputStream;
    // Global chat variables
    BOOL isConnected;
    BOOL isSubscribed;
}

+ (ChatManager*)getInstance;

@property (nonatomic, readwrite) BOOL isConnected;
@property (nonatomic, readwrite) BOOL isSubscribed;


- (void)chatServerSetup;
- (void)chatServerClose;
- (void)subscribe:(NSString *)channelNo;
- (void)sendMessage:(NSString*)message withfromid:(NSString *)fromid isImage:(NSString *)isImage toUser:(WLIUser *)user;

@end
