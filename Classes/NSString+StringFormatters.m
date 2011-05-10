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
    NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease];
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    [numberFormatter setLocale:usLocale];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    return [numberFormatter stringFromNumber:value];
}

+ (NSString *) formatDecimalNumber:(NSDecimalNumber *) value toScale: (int) scale {
    NSNumberFormatter * nf = [[[NSNumberFormatter alloc] init] autorelease];
    [nf setMinimumFractionDigits:scale];
    [nf setMaximumFractionDigits:scale];
    
    return [nf stringFromNumber:value];
}


- (NSString *) padLeft:(NSString *) padString withMaxSize: (NSUInteger) maxSize {
    if ([self length] + [padString length] <= maxSize) {
        NSString *paddedString = [padString stringByAppendingString:self];
        
        while ([paddedString length] < maxSize) {
            paddedString = [padString stringByAppendingString:paddedString];
        }

        return paddedString;

    } else {
        return [[self copy] autorelease];
    }
}

@end
