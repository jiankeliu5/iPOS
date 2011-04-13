//
//  SampleUnitTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SampleUnitTestCase.h"

#import "NSString+StringFormatters.h"

@implementation SampleUnitTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testMath {    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}

-(void) testBankersRounding {
    NSDecimalNumber *value = [NSDecimalNumber decimalNumberWithString:@"343.205"];
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *bankersRoundedNumber = [value decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior];
    
    STAssertTrue([[bankersRoundedNumber stringValue] isEqualToString:@"343.2"], [NSString stringWithFormat:@"Value was: %@", [bankersRoundedNumber stringValue]]);
    STAssertTrue([[NSString formatDecimalNumberAsMoney:value] isEqualToString:@"$343.20"], [NSString stringWithFormat:@"Value was: %@", [bankersRoundedNumber stringValue]]);

}

- (void) testDecimalCompare {
    NSDecimalNumber *value = [NSDecimalNumber decimalNumberWithString:@"1.00000"];
    
    NSComparisonResult result = [value compare: [NSDecimalNumber decimalNumberWithString:@"1.0"]];
    
    STAssertEquals(result, NSOrderedSame, @"The values should be equal");

}



#endif


@end
