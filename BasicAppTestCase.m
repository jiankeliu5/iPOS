//
//  BasicAppTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 3/16/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "BasicAppTestCase.h"
#import "iPOSAppDelegate.h"

@implementation BasicAppTestCase

- (void) testAppDelegate {
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    
    STAssertNotNil(appDelegate, @"UIApplication failed to find the AppDelegate");
}


@end
