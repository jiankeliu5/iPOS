//
//  Address.m
//  iPOS
//
//  Created by Torey Lomenda on 2/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Address.h"


@implementation Address

@synthesize line1, line2, line3, city, stateProv, zipPostalCode, country;

#pragma mark Initializer and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    return self;
}

-(void) dealloc {
    [line1 release];
    [line2 release];
    [line3 release];
    [city release];
    [stateProv release];
    [zipPostalCode release];
    [country release];
    
    [super dealloc];
}

+ (NSArray *) usStateCodes {
	return [NSArray arrayWithObjects:@"AL",
			@"AK",
			@"AZ",
			@"AR",
			@"CA",
			@"CO",
			@"CT",
			@"DE",
			@"DC",
			@"FL",
			@"GA",
			@"HI",
			@"ID",
			@"IL",
			@"IN",
			@"IA",
			@"KS",
			@"KY",
			@"LA",
			@"ME",
			@"MD",
			@"MA",
			@"MI",
			@"MN",
			@"MS",
			@"MO",
			@"MT",
			@"NE",
			@"NV",
			@"NH",
			@"NJ",
			@"NM",
			@"NY",
			@"NC",
			@"ND",
			@"OH",
			@"OK",
			@"OR",
			@"PA",
			@"RI",
			@"SC",
			@"SD",
			@"TN",
			@"TX",
			@"UT",
			@"VT",
			@"VA",
			@"WA",
			@"WV",
			@"WI",
			@"WY",
			nil];
}
@end
