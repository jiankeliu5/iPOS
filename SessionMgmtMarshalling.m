//
//  SessionMgmtMarshalling.m
//  iPOS
//
//  Created by Torey Lomenda on 3/16/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionMgmtMarshalling.h"
#import "CXMLElement.h"
#import "CXMLDocument.h"

@implementation SessionMgmtMarshalling

+(NSString *) toLoginRequestXmlWith:(NSString *)employeeNumber password:(NSString *)password deviceId:(NSString *)deviceId {    
    NSString *loginRequestXml = [NSString stringWithFormat:@"<Login><UserName>%@</UserName><Password>%@</Password><DeviceID>%@</DeviceID></Login>", employeeNumber, password, deviceId];
    
    return loginRequestXml;
}

+ (void) bindSessionInfo:(SessionInfo *) sessionInfo fromXml:(NSString *) xmlLoginResult {
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlLoginResult options:0 error:nil] autorelease];
    
    // Extract the Success element
    CXMLElement *root = [xmlParser rootElement];
    NSArray *successNodes = [root elementsForName:@"Success"];
    CXMLElement *successElement = [successNodes lastObject];
    BOOL isSuccessful = NO;
    
    if (successElement != nil) {
        isSuccessful = [[successElement stringValue] boolValue];
    }
    
    // if successful bind to a session info object
    if (isSuccessful) {
        NSArray *nodes = nil;
        CXMLElement *element = nil;
        
        nodes = [root elementsForName:@"EmployeeID"];
        element = [nodes lastObject];
        
        if (element) {
            sessionInfo.employeeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        }
        
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        
        if (element) {
            sessionInfo.storeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        }
        
        nodes = [root elementsForName:@"SessionID"];
        element = [nodes lastObject];
        
        if (element) {
            sessionInfo.serverSessionId = [element stringValue];
        }
    }
}

+(BOOL) isSuccessful:(NSString *)xmlResponse {
    // Create an XML document parser
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlResponse options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    BOOL isSuccessful = NO;
    
    // Parse the response to fetch the boolean result
    if (root != nil) {
        isSuccessful = [[root stringValue] boolValue];
    }
    
    // Return resul
    return isSuccessful;
}

@end
