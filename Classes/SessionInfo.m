//
//  SessionInfo.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionInfo.h"
#import "LoginXmlMarshaller.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+MD5Addition.h"

@implementation SessionInfo

@synthesize employeeId, storeId, deviceId, serverSessionId, loginUserName, passwordForVerification;
//@synthesize currentCustomer;
//@synthesize currentOrder;

#pragma mark -
#pragma mark Initializing and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Set the device id based on the current device's unique identifer
    deviceId = [[[UIDevice currentDevice] uniqueIdentifier] copy]; //-- deprecated iOS 5
    
    //Enning Tang Change deviceId to new function 11/12/2012
    //deviceId = [[[UIDevice currentDevice] uniqueDeviceIdentifier] copy]; //use mac address
    
    //Enning Tang Fix the uniqueIdentifier issue (we cannot use MacAddress for now)
    NSLog(@"DeviceID: %@", deviceId);
    //NSLog(@"New ID: %@", [[UIDevice currentDevice] uniqueDeviceIdentifier]);
    //NSLog(@"New Global ID: %@", [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier]);
    
    return self;
}

-(void) dealloc {
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
