//
//  NSString+StringFormatters.h
//  iPOS
//
//  Created by Steven McCoole on 3/20/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringFormatters)

+ (NSString *) formatAsUSPhone:(NSString *)phone;
+ (NSString *) formatNumberAsMoney:(NSNumber *)value;
+ (NSString *) formatDecimalNumberAsMoney:(NSDecimalNumber *)value;

@end
