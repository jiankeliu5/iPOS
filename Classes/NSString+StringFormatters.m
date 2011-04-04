//
//  NSString+StringFormatters
//  iPOS
//
//  Created by Steven McCoole on 3/20/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "NSString+StringFormatters.h"

@implementation NSString (StringFormatters)

+ (NSString *) formatAsUSPhone:(NSString *)phone {
	NSRange range;
	range.length = 3;
	range.location = 3;
	return [NSString stringWithFormat:@"%@-%@-%@", [phone substringToIndex:3], [phone substringWithRange:range], [phone substringFromIndex:6]];
}

+ (NSString *) formatNumberAsMoney:(NSNumber *)value {
    NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease];
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setLocale:usLocale];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    return [numberFormatter stringFromNumber:value];
}

+ (NSString *) formatDecimalNumberAsMoney:(NSDecimalNumber *)value {
    // Ensure we use banker's rounding algorithm
  //  NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
  //  NSDecimalNumber *bankersRoundedNumber = [value decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease];
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setLocale:usLocale];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    return [numberFormatter stringFromNumber:value];
}

@end
