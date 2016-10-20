//
//  NSString+Helpers.h
//  Cena
//
//  Created by Sandeep Mahajan on 08/10/14.
//  Copyright (c) 2014 Systematix Infotech. All rights reserved.
//

#import "NSString+Helpers.h"
#import "NSData+Base64.h"

@implementation NSString (Helpers)

#pragma mark Helpers
- (NSString *) stringByUrlEncoding
{
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)CFBridgingRetain(self),  NULL,  (CFStringRef)@"!*'();:@&=+$,/?%#[]",  kCFStringEncodingUTF8));
}

- (NSString *)base64Encoding
{
	NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodedString = [stringData base64EncodedString];

	return encodedString;
}

- (NSString*)trim 
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet
												  whitespaceAndNewlineCharacterSet]];
	
}

- (BOOL)startsWith:(NSString*)s {
	if([self length] < [s length]) return NO;
	return [s isEqualToString:[self substringFrom:0 to:[s length]]];
	
}

- (NSString*)substringFrom:(NSInteger)a to:(NSInteger)b
{
	NSRange r;
	r.location = a;
	r.length = b - a;
	return [self substringWithRange:r];
	
}

- (BOOL)containsString:(NSString *)aString {
	NSRange range = [[self lowercaseString] rangeOfString:[aString
														   lowercaseString]];
	return range.location != NSNotFound;
}

- (BOOL)isNumeric
{
    const char *s = [self UTF8String];
	for (size_t i=0;i<strlen(s);i++) {
		if (s[i]<'0' || s[i]>'9') {
			return NO;
		}
	}
	return YES;
}

@end