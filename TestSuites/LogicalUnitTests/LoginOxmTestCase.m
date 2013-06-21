//
//  LoginOxmTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "SessionInfo.h"

@interface LoginOxmTestCase : SenTestCase

-(void) testXmlFromLoginRequest;
-(void) testSessionInfoFromLoginResult;

@end

@implementation LoginOxmTestCase

- (void) testXmlFromLoginRequest {
    SessionInfo *info = [[[SessionInfo alloc] init] autorelease];
    
    info.storeId = [NSNumber numberWithInt: 1200];
    info.deviceId = @"SomeDeviceId";
    info.loginUserName = @"SomeUserNmae";
    info.passwordForVerification = @"SomePassword";
    
    NSString *xml = [info toLoginRequestXml];
    STAssertNotNil(xml, @"Expected xml to not be nil");
}

- (void) testSessionInfoFromLoginResult {
    NSString *xmlString = @"<LoginReturn><EmployeeID>123</EmployeeID><SessionID>1234-test-34</SessionID><StoreID>1200</StoreID><Success>true</Success></LoginReturn>";
    
    SessionInfo *info = [SessionInfo fromXml:xmlString];
    
    STAssertNotNil(info, @"Expected Session Info object");
    STAssertTrue([info.employeeId isEqualToNumber:[NSNumber numberWithInt:123]], @"Expected employee id to be 123");
    STAssertTrue([info.storeId isEqualToNumber:[NSNumber numberWithInt:1200]], @"Expected store id to be 1200");    
}

@end
