//
//  ExtUITextField.m
//  iPOS
//
//  Created by Steven McCoole on 2/13/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "ExtUITextField.h"

#pragma mark -
#pragma mark Private Interface
@interface ExtUITextField ()
@end

#pragma mark -
@implementation ExtUITextField

@synthesize tagName;

#pragma mark Constructors

- (void) dealloc
{
	[tagName release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods

@end
