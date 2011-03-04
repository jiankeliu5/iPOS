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

#import "Customer.h"
#import "Order.h"
#import "Error.h"

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
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];    self.posSessionMgmtUri = @"SessionService";
}

-(void) setToReleaseMode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.posSessionMgmtUri = @"SessionService";
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
        sessionInfo.employeeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"StoreID"];
        element = [nodes lastObject];
        sessionInfo.storeId = [NSNumber numberWithInt: [[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"SessionID"];
        element = [nodes lastObject];
        sessionInfo.serverSessionId = [element stringValue];
        
        // Store the valid password for verification when app wakes up from the background/sleep
        sessionInfo.passwordForVerification = [[password copy] autorelease];
        
    } else {
        return nil;
    }
    
    return sessionInfo;
}

-(BOOL) verifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password {

    if (sessionInfo == nil) {
        return false;
    }

    if (password && [password isEqualToString:sessionInfo.passwordForVerification]) {
        return YES;
    }

    return NO;
}

-(BOOL) logout: (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return true;
    }
    
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/logout", baseUrl, posSessionMgmtUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
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

#pragma mark -
#pragma mark Customer Mgmt APIs
-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber withSession:(SessionInfo *)sessionInfo {
    if ([phoneNumber isEqualToString:@"612-807-6120"]) {
        Customer *customer = [[[Customer alloc] init] autorelease];
        
        customer.customerId = [NSNumber numberWithInt:1414];
        customer.firstName = @"Torey";
        customer.lastName = @"Lomenda";
        customer.phoneNumber = @"612-807-6120";
        customer.emailAddress = @"tlomenda@email.blackhole.com";
        customer.address = [[[Address alloc] init] autorelease];
        
        customer.address.line1 = @"1414 Street St.";
        customer.address.city = @"Plymouth";
        customer.address.stateProv = @"MN";
        customer.address.zipPostalCode = @"55555";
        customer.address.country = @"US";
        
        return customer;
    }
    
    return nil;
}

-(void) newCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {
    // If a customer has an ID already we would add an error
    if (customer == nil) {
        return;
    } 
    
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:1];
    if (customer.customerId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.errorMsgString = @"Customer is already created.";
        error.reference = customer;
        
        [errors addObject:error];
        
    } 
    
    if (customer.firstName == nil || customer.lastName == nil || customer.phoneNumber == nil || customer.address == nil || customer.address.zipPostalCode == nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.errorMsgString = @"Missing required data.";
        error.reference = customer;
        
        [errors addObject:error];
    }
    
    
    
    if ([errors count] > 0) {
        customer.errorList = [NSArray arrayWithArray:errors];
    } else {
        customer.customerId = [NSNumber numberWithInt:1414];
    }
}

-(void) updateCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {
    // Do nothing
}


@end
