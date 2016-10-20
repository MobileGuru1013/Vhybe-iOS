//
//  WLIObject.h
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLIObject : NSObject

- (NSString*)stringFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (double)doubleFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (float)floatFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (int)integerFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (long)longFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (long long)longLongFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (NSDate*)dateFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (BOOL)boolFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;
- (NSDictionary*)dictionaryFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey ;
- (NSArray*)arrayFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey;

@end
