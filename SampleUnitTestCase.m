//
//  SampleUnitTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SampleUnitTestCase.h"

@implementation SampleUnitTestCase

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testMath {    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
