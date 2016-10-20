//
//  NSString+Helpers.h
//  Cena
//
//  Created by Sandeep Mahajan on 08/10/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface NSString (Helpers)

- (NSString *) stringByUrlEncoding;
- (NSString *) base64Encoding;
- (NSString *) trim;
- (BOOL) startsWith:(NSString *)s;
- (BOOL) containsString:(NSString * )aString;
- (NSString *)substringFrom:(NSInteger)a to:(NSInteger)b;
- (BOOL)isNumeric;

@end
