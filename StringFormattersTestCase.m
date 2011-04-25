//
//  StringFormattersTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 4/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "NSString+StringFormatters.h"

@interface StringFormattersTestCase : SenTestCase 

-(void) testPaddingLeft;

@end

@implementation StringFormattersTestCase

- (void) testPaddingLeft {
    STAssertTrue([[@"2" padLeft:@"0" withMaxSize:2] isEqualToString:@"02"], @"Expected value to be '02'.");
    STAssertTrue([[@"12" padLeft:@"0" withMaxSize:10] isEqualToString:@"0000000012"], @"Expected value to be '02'.");
}

@end
