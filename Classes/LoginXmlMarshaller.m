//
//  LoginXmlMarshaller.m
//  iPOS
//
//  Created by Torey Lomenda on 3/24/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "LoginXmlMarshaller.h"

#import "SessionInfo.h"

static NSString * const LOGIN_REQUEST_XML = @""
        "<Login>"
            "<UserName>%@</UserName>"
            "<Password>%@</Password>"
            "<DeviceID>%@</DeviceID>"
        "</Login>";


@implementation LoginXmlMarshaller

- (NSString *) toXml:(id)marshalObj {
    NSString *loginXml = @"<Login />";
    
    if (marshalObj && [marshalObj isMemberOfClass: [SessionInfo class]]) {
        SessionInfo *sessionInfo = (SessionInfo *) marshalObj;
        
        loginXml = [NSString stringWithFormat:LOGIN_REQUEST_XML, sessionInfo.loginUserName, sessionInfo.passwordForVerification, sessionInfo.deviceId];
    }
    
    return loginXml;
}

- (id) toObject:(NSString *)xmlString {
    if (xmlString == nil) {
        return nil;
    }
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    
    CXMLElement *root = [xmlParser rootElement];
    
    if ([root elementBoolValue:@"Success"]) {
        SessionInfo *sessionInfo = [[[SessionInfo alloc] init] autorelease];
        
        sessionInfo.employeeId = [root elementNumberValue:@"EmployeeID"];
        sessionInfo.storeId = [root elementNumberValue:@"StoreID"];
        sessionInfo.serverSessionId = [root elementStringValue:@"SessionID"];
        
        return sessionInfo;
    }
    
    return nil;        
}



@end
