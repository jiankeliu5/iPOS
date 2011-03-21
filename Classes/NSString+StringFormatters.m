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

@end
