//
//  POSServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceImpl.h"
#import "SessionInfo.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "ASIHTTPRequest.h"

@implementation iPOSServiceImpl

@synthesize baseUrl, posSessionMgmtUri;

#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Get user preference for demo mode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL demoEnabled = [defaults boolForKey:@"enableDemoMode"];
    
#if DEMO_MODE
    demoEnabled = YES;
#endif

    if (demoEnabled) {
        [self setToDemoMode];
    } else {
        [self setToReleaseMode];
    }
    
    return self;
}

-(void) dealloc {
    [baseUrl release];
    [posSessionMgmtUri release];
    
    [super dealloc];
}

-(void) setToDemoMode {
    self.baseUrl = @"http://ipad.demo.objectpartners.com:8080/ipos-demo-services-0.1/webservices";
    self.posSessionMgmtUri = @"ipos/SessionService";
}

-(void) setToReleaseMode {
    self.baseUrl = @"https://tsipos01/webservices";
    self.posSessionMgmtUri = @"ipos/SessionService";
}

#pragma mark -
#pragma mark iPOS Session Mgmt
-(SessionInfo *) login: (NSString *) employeeNumber withPassword: (NSString *) password {
    SessionInfo *sessionInfo = [[[SessionInfo alloc] init] autorelease];
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/login", baseUrl, posSessionMgmtUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    // We will be posting the login as an XML Request
    NSString *loginXML = [NSString stringWithFormat:@"<Login><UserName>%@</UserName><Password>%@</Password><DeviceID>%@</DeviceID></Login>", employeeNumber, password, sessionInfo.deviceId];
    [request appendPostData:[loginXML dataUsingEncoding:NSUTF8StringEncoding]];

    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:response options:0 error:nil] autorelease];
    
    // Extract the Success element
    CXMLElement *root = [xmlParser rootElement];
    NSArray *successNodes = [root elementsForName:@"Success"];
    CXMLDocument *successElement = [successNodes lastObject];
    BOOL isSuccessful = NO;
    
    if (successElement != nil) {
        isSuccessful = [[successElement stringValue] boolValue];
    }
    
    // if successful bind to a session info object
    if (isSuccessful) {
        NSArray *nodes = nil;
        CXMLDocument *element = nil;
        
        nodes = [root elementsForName:@"EmployeeID"];
        element = [nodes lastObject];
        sessionInfo.employeeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        sessionInfo.storeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"SessionID"];
        element = [nodes lastObject];
        sessionInfo.serverSessionId = [element stringValue];
        
        // Store the valid password for verification when app wakes up from the background/sleep
        sessionInfo.passwordForVerification = [password copy];
        
    } else {
        return nil;
    }
    
    return sessionInfo;
}

-(BOOL) verifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password {

    if (password && [password isEqualToString:sessionInfo.passwordForVerification]) {
        return YES;
    }

    return NO;
}

-(BOOL) logout: (SessionInfo *) sessionInfo {
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/logout", baseUrl, posSessionMgmtUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    
    NSError *error = [request error];
    
    if (error) {
        return NO;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:response options:0 error:nil] autorelease];
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
