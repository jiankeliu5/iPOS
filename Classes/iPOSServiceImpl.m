//
//  POSServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceImpl.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+Validate.h"
#import "POSOxmUtils.h"

#import "SessionInfo.h"
#import "Customer.h"
#import "Order.h"
#import "Error.h"

// Private interface
@interface iPOSServiceImpl()
    - (ASIHTTPRequest *) initRequestForSession:(SessionInfo *) sessionInfo serviceDomainUri: (NSString *) serviceDomainUri serviceUri: (NSString *) serviceUri;

    - (void) createOrder: (Order *) order withSession: (SessionInfo *) sessionInfo;
@end

@implementation iPOSServiceImpl

@synthesize baseUrl, posSessionMgmtUri, posCustomerMgmtUri, posOrderMgmtUri;

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
    [posCustomerMgmtUri release];
    [posOrderMgmtUri release];
    
    [super dealloc];
}

-(void) setToDemoMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];    
    self.posSessionMgmtUri = @"SessionService";
    self.posCustomerMgmtUri = @"CustomerService";
    self.posOrderMgmtUri = @"OrderService";
}

-(void) setToReleaseMode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.posSessionMgmtUri = @"SessionService";
    self.posCustomerMgmtUri = @"CustomerService";
    self.posOrderMgmtUri = @"OrderService";
}

#pragma mark -
#pragma mark iPOS Session Mgmt
-(SessionInfo *) login: (NSString *) employeeNumber withPassword: (NSString *) password {
    SessionInfo *sessionInfo = [[[SessionInfo alloc] init] autorelease];
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"login"];
   
    // We will be posting the login as an XML Request
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    sessionInfo.loginUserName = employeeNumber;
    sessionInfo.passwordForVerification = password;
    
    NSString *loginXML = [sessionInfo toLoginRequestXml];
    [request appendPostData:[loginXML dataUsingEncoding:NSUTF8StringEncoding]];

    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    SessionInfo *responseSessionInfo = [SessionInfo fromXml:response];
    
    if (responseSessionInfo.employeeId && ![responseSessionInfo.employeeId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        sessionInfo.employeeId = responseSessionInfo.employeeId;
        sessionInfo.serverSessionId = responseSessionInfo.serverSessionId;
        sessionInfo.storeId = responseSessionInfo.storeId;
        
        return sessionInfo;
    }
    
    return nil;
}

-(BOOL) verifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password {
    if (sessionInfo == nil) {
        return false;
    }

    if (password && [password isEqualToString:sessionInfo.passwordForVerification]) {
        ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"verify"];
        
        [request startSynchronous];
        
        if ([request error]) {
            return NO;
        }
        
        BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
        
        // Return result
        return isSuccessful;
        
    }

    return NO;
}

-(BOOL) logout: (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return true;
    }
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"logout"];
    
    [request startSynchronous];
    
    if ([request error]) {
        return NO;
    }
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];

        
    // Return result
    return isSuccessful;
}

#pragma mark -
#pragma mark Customer Mgmt APIs
-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }

    // Send the lookup request
    NSString *customerlookupUri = [NSString stringWithFormat:@"%@", phoneNumber];
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:customerlookupUri];
    
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    }
    
    // Parse the XML response for the customer details
    Customer *customer =  [Customer fromXml:[request responseString]];
            
    if (customer == nil || (customer.errorList != nil && [customer.errorList count] > 0)) {
        return nil;
    }
    
    return customer;
}

-(void) newCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {
    
    // If a customer has an ID already we would add an error
    if (sessionInfo == nil || customer == nil || ![customer isValidCustomer:YES]) {
        return;
    } 
    
    // Make sure the store Id is set on the customer
    if (customer.store == nil) {
        customer.store = [[[Store alloc] init] autorelease];
    }
    customer.store.storeId = sessionInfo.storeId;
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"new"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *customerXml = [customer toXml];    
    [request appendPostData:[customerXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        for (Error *error in requestErrors) {
            [customer addError:error];
        }
        return;   
    }
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [Customer fromXml:[request responseString]];
    [customer mergeWith:resultCustomer];
}

-(void) updateCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {

    if (sessionInfo == nil || customer == nil || ![customer isValidCustomer:NO]) {
        return;
    } 
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"update"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *customerXml = [customer toXml];
    [request appendPostData:[customerXml dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];

    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        for (Error *error in requestErrors) {
            [customer addError:error];
        }
        return;   
    }
    
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [Customer fromXml:[request responseString]];
    [customer mergeWith:resultCustomer];
}

#pragma mark -
#pragma mark Order Mgmt APIs
-(void) newQuote:(Order *)order withSession:(SessionInfo *)sessionInfo {
    if (order == nil || ![order validateAsNewQuote]) {
        return;
    }
    
    [order setAsQuote];
    [self createOrder:order withSession:sessionInfo];
}

-(void) newOrder:(Order *)order withSession:(SessionInfo *)sessionInfo {
    if (order == nil || ![order validateAsNewOrder]) {
        return;
    }
    
    [order getOrderTypeId];
    [self createOrder:order withSession:sessionInfo];
}

-(void) createOrder:(Order *)order withSession:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    if (sessionInfo == nil || order == nil) {
        return;
    } 
    
    // Make sure the store Id is set on the order
    if (order.store == nil) {
        order.store = [[[Store alloc] init] autorelease];
    }
    order.store.storeId = sessionInfo.storeId;
    
    // Make sure the sales person id is set
    if (order.salesPersonEmployeeId == nil) {
        order.salesPersonEmployeeId = sessionInfo.employeeId;
    }
    // Send the new order request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"new"];
    
    // Post data for order
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *orderXml = [order toXml];    
    [request appendPostData:[orderXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out the order type if it was set and any errors
        order.orderTypeId = nil;
        [order removeAllErrors];
        
        for (Error *error in requestErrors) {
            [order addError:error];
        }
        
        return;   
    }
    
    
    // Parse the XML response for the order details
    Order *orderReturned =  [Order fromXml:[request responseString]];
    [order mergeWith:orderReturned];
}

- (void) emailReceipt:(Order *)order withSession:(SessionInfo *)sessionInfo {
    // TODO: Implement this method
}

#pragma mark -
#pragma mark Private interface
-(ASIHTTPRequest *) initRequestForSession:(SessionInfo *)sessionInfo serviceDomainUri:(NSString *)serviceDomainUri serviceUri:(NSString *)serviceUri {
    // Make Synchronous HTTP request to verify the login session
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, serviceDomainUri, serviceUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    return request;
}

-(BOOL) isNewOrderValid: (Order *) order {
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:1];
    if (order.orderId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = @"Order is already created.";
        error.reference = order;
        
        [errors addObject:error];
        
    } 
    
    
    if ([errors count] > 0) {
        order.errorList = [NSArray arrayWithArray:errors];
        return NO;
    }
    
    return YES;        
}

@end
