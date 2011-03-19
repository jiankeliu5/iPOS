//
//  SessionInfo.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionInfo.h"


@implementation SessionInfo

@synthesize employeeId, storeId, deviceId, serverSessionId, passwordForVerification;
@synthesize currentCustomer;

#pragma mark -
#pragma mark Initializing and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Set the device id based on the current device's unique identifer
    deviceId = [[[UIDevice currentDevice] uniqueIdentifier] copy];

    return self;
}

-(void) dealloc {
	[currentCustomer release];
	
    [storeId release];
    [employeeId release];
    [deviceId release];
    [serverSessionId release];
    
    [super dealloc];
}

@end
