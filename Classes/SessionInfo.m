//
//  SessionInfo.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionInfo.h"
#import "LoginXmlMarshaller.h"

@implementation SessionInfo

@synthesize employeeId, storeId, deviceId, serverSessionId, loginUserName, passwordForVerification;
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
    
    [loginUserName release];
    [passwordForVerification release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark XML Marshalling
+ (SessionInfo *) fromXml:(NSString *)xmlString {
    LoginXmlMarshaller *marshaller = [[[LoginXmlMarshaller alloc] init] autorelease];
    return (SessionInfo *) [marshaller toObject:xmlString];    
}

- (NSString *) toLoginRequestXml {
    LoginXmlMarshaller *marshaller = [[[LoginXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

@end
