//
//  WLIObject.m
//  Friends
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIObject.h"
#import "WLIConnect.h"

@implementation WLIObject

- (NSString*)stringFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(stringValue)]) {
                newObject = [newObject stringValue];
            }
            return newObject;
        }
    }
    
    return @"";
}

- (double)doubleFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(doubleValue)]) {
                return [newObject doubleValue];
            }
        }
    }
    
    return 0.0;
}

- (float)floatFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(floatValue)]) {
                return [newObject floatValue];
            }
        }
    }
    
    return 0.0f;
}

- (NSDate*)dateFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            
            return [[[WLIConnect sharedConnect] dateFormatter] dateFromString:newObject];
        }
    }
    
    return nil;
}

- (int)integerFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(intValue)]) {
                return [newObject intValue];
            }
        }
    }
    
    return 0;
}

- (BOOL)boolFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(boolValue)]) {
                return [newObject boolValue];
            }
        }
    }
    
    return NO;
}

- (long)longFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(longValue)]) {
                return [newObject longValue];
            }
            else{
                if ([newObject respondsToSelector:@selector(integerValue)]) {
                    return [newObject integerValue];
                }
                //return [[NSString stringWithFormat:@"%@", newObject] integerValue];
            }
        }
    }
    
    return 0;
}

- (long long)longLongFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject respondsToSelector:@selector(longLongValue)]) {
                return [newObject longLongValue];
            }
        }
    }
    
    return 0;
}

- (NSDictionary*)dictionaryFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject isKindOfClass:[NSDictionary class]]) {
                return newObject;
            }
        }
    }
    return [NSDictionary dictionary];
}

- (NSArray*)arrayFromDictionary:(NSDictionary*)newDictionary forKey:(NSString*)newKey {
    
    if ((NSNull*)newDictionary != [NSNull null] && [newDictionary isKindOfClass:[NSDictionary class]] && newKey &&
        [newKey isKindOfClass:[NSString class]] && [newKey length] > 0) {
        
        id newObject = [newDictionary objectForKey:newKey];
        if (newObject && (NSNull*)newObject != [NSNull null]) {
            if ([newObject isKindOfClass:[NSArray class]]) {
                return newObject;
            }
        }
    }
    return [NSArray array];
}

@end
