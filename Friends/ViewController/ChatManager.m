//
//  ChatManager.m
//  Cena
//
//  Created by Sandeep Mahajan on 27/08/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//

#import "ChatManager.h"
#import "UIImageView+AFNetworking.h"
#import "WLIConnect.h"

// Chat Server Configuration
//#define kChatServerHost @"10.10.1.100"
#define kChatServerHost @"173.245.72.50"
#define kChatServerPort 1337


@implementation ChatManager

@synthesize isConnected, isSubscribed;

+ (ChatManager*)getInstance {
    static dispatch_once_t once;
    static ChatManager *chatManager;
    dispatch_once(&once, ^{ chatManager = [[self alloc] init]; });
    return chatManager;
}

-(id)init{
    self = [super init];
    if (self) {
        // Allocate memory
    }
    return self;
}

#pragma mark - Setup and Close

- (void)chatServerSetup {
    CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)kChatServerHost, kChatServerPort, &readStream, &writeStream);
   // CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.10.10.128", kChatServerPort, &readStream, &writeStream);
	
	inputStream = (__bridge NSInputStream *)readStream;
	outputStream = (__bridge NSOutputStream *)writeStream;
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	[outputStream open];
}

- (void)chatServerClose {
	[inputStream close];
	[outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream setDelegate:nil];
	[outputStream setDelegate:nil];
    
    isConnected = FALSE;
    isSubscribed = FALSE;
}

#pragma mark - Subscribe 

- (void)subscribe:(NSString *)channelNo {
    NSLog(@"Subscribe to Channel: %@", channelNo);
    NSString *response  = [NSString stringWithFormat:@"__SUBSCRIBE__%@__ENDSUBSCRIBE__", channelNo];
    //NSString *response  = [NSString stringWithFormat:@"__SUBSCRIBE__17_76__ENDSUBSCRIBE__", channelNo];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

#pragma mark - Send and Receive Messages

- (void)sendMessage:(NSString*)message withfromid:(NSString *)fromid isImage:(NSString *)isImage toUser:(WLIUser *)user{
    if([message containsString:@"\""]) {
        message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    }
    if([message containsString:@"\'"]) {
        message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@"\\'"];
    }
    

    NSDate *date = [NSDate date];
    /*NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy HH:mm a"];*/
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [tempDict setObject:message forKey:@"key"];
    [tempDict setObject:@"1" forKey:@"userId"];
    [tempDict setObject:isImage forKey:@"isImage"];
    [tempDict setObject:fromid forKey:@"fromId"];
    [tempDict setObject:[WLIConnect sharedConnect].currentUser.userFullName forKey:@"user_name"];
    [tempDict setObject:[NSString stringWithFormat:@"%d",user.userID] forKey:@"toId"];
    [tempDict setObject:user.userDeviceToken forKey:@"devicetoken"];
    [tempDict setObject:user.userDeviceType forKey:@"isdevice"];
    
    //[tempDict setObject:[dateFormat stringFromDate:date] forKey:@"date"];
    [tempDict setObject:[NSString stringWithFormat:@"%@",date] forKey:@"date"];
    
    NSError *error;
    NSString *jsonStr = [tempDict JSONStringWithOptions:0 error:&error];
    if(error) NSLog(@"ERROR: %@", error);
    NSLog(@"Message to send: %@", jsonStr);
    
    NSString *msgToSend = [NSString stringWithFormat:@"__JSON__START__%@__JSON__END__", jsonStr];
	NSData *data = [msgToSend dataUsingEncoding:NSUTF8StringEncoding];
	[outputStream write:[data bytes] maxLength:[data length]];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
	NSLog(@"stream event %i", streamEvent);
	switch (streamEvent) {
		case NSStreamEventOpenCompleted:
			//NSLog(@"Stream opened");
            isConnected = TRUE;
			break;
            
		case NSStreamEventHasBytesAvailable:
			if (theStream == inputStream) {
				uint8_t buffer[1024];
				NSUInteger len;
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						if (nil != output) {
							[self messageReceived:output];
						}
					}
				}
			}
			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
            [self chatServerClose];
			break;
            
		case NSStreamEventEndEncountered:
            [self chatServerClose];
			break;
        
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Listening...");
            break;
            
		default:
			NSLog(@"Unknown event");
	}
}

- (void)messageReceived:(NSString *)message {
    NSString *json = NULL;
	if([message containsString:@"You have successfully subscribed."]) {
        NSArray *tempArr = [message componentsSeparatedByString:@":"];
        NSLog(@"Message: %@",message);
        NSLog(@"You have successfully subscribe %@", [tempArr objectAtIndex:0]);
        //NSLog(@"# of online users: %@", [tempArr objectAtIndex:1]);
    } else if([message containsString:@":__CLIENTS__COUNT"]) {
        NSString *noOfUsers = [message substringFromIndex:17];
        NSLog(@"Reset # of online users: %@", noOfUsers);
    }
    else {
        if([message containsString:@"__JSON__START__"]) {
            json = [message substringFrom:15 to:([message length] - 13)];
            NSLog(@"Response JSON: %@", json);
            NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(jsonObj) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"chatmessage" object:nil userInfo:jsonObj];
            }
        }
    }
}

@end
