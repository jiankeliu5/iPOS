//
//  POSServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceImpl.h"
#import "SessionInfo.h"
#import "ASIHTTPRequest.h"

#import "SessionMgmtMarshalling.h"
#import "CustomerMarshalling.h"
#import "OrderMarshalling.h"
#import "Customer.h"
#import "Order.h"
#import "Error.h"

// Private interface
@interface iPOSServiceImpl()
    - (ASIHTTPRequest *) initRequestForSession:(SessionInfo *) sessionInfo serviceDomainUri: (NSString *) serviceDomainUri serviceUri: (NSString *) serviceUri;

    - (void) mergeCustomer: (Customer *) targetCustomer withCustomer: (Customer *) sourceCustomer;
    
    - (BOOL) isNewOrderValid: (Order *) order; 
    - (void) mergeOrder: (Order *) targetOrder withOrder: (Order *) sourceOrder;
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
    
    NSString *loginXML = [SessionMgmtMarshalling toLoginRequestXmlWith:employeeNumber password:password deviceId:sessionInfo.deviceId];
    [request appendPostData:[loginXML dataUsingEncoding:NSUTF8StringEncoding]];

    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    [SessionMgmtMarshalling bindSessionInfo:sessionInfo fromXml:response];
    
    // If an employee Id is populated we have a valid session info
    if (sessionInfo.employeeId && ![sessionInfo.employeeId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        // Store the valid password for verification when app wakes up from the background/sleep
        sessionInfo.passwordForVerification = [[password copy] autorelease];
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
        
        BOOL isSuccessful = [SessionMgmtMarshalling isSuccessful:[request responseString]];
        
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
    
    BOOL isSuccessful = [SessionMgmtMarshalling isSuccessful:[request responseString]];

        
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
    
    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    // Parse the XML response for the customer details
    Customer *customer = [CustomerMarshalling toObject:[request responseString]];
            
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
    
    NSString *customerXml = [CustomerMarshalling toXml:customer];    
    [request appendPostData:[customerXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    if ([request error]) {
        return;
    }
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [CustomerMarshalling toObject:[request responseString]];
    [self mergeCustomer: customer withCustomer:resultCustomer];
}

-(void) updateCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {

    if (sessionInfo == nil || customer == nil || ![customer isValidCustomer:NO]) {
        return;
    } 
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"update"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *customerXml = [CustomerMarshalling toXml:customer];
    [request appendPostData:[customerXml dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    
    if ([request error]) {
        return;
    }
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [CustomerMarshalling toObject:[request responseString]];
    [self mergeCustomer: customer withCustomer:resultCustomer];
}

#pragma mark -
#pragma mark Order Mgmt APIs
-(void) newOrder:(Order *)order withSession:(SessionInfo *)sessionInfo {
    // If a customer has an ID already we would add an error
    if (sessionInfo == nil || order == nil || ![self isNewOrderValid:order]) {
        return;
    } 
    
    // Make sure the store Id is set on the customer
    if (order.store == nil) {
        order.store = [[[Store alloc] init] autorelease];
    }
    order.store.storeId = sessionInfo.storeId;
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"new"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *orderXml = [OrderMarshalling toXml:order];    
    [request appendPostData:[orderXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    if ([request error]) {
        return;
    }
    
    // Parse the XML response for the customer details
    Order *orderReturned = [OrderMarshalling toObjectFromOrderReturn:[request responseString]];
    [self mergeOrder:order withOrder:orderReturned];
}

#pragma mark -
#pragma mark Private interface
-(ASIHTTPRequest *) initRequestForSession:(SessionInfo *)sessionInfo serviceDomainUri:(NSString *)serviceDomainUri serviceUri:(NSString *)serviceUri {
    // Make Synchronous HTTP request to verify the login session
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, serviceDomainUri, serviceUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    return request;
}

- (void) mergeCustomer: (Customer *) targetCustomer withCustomer: (Customer *) sourceCustomer {
    // If there are errors just merge the errors, otherwise merge everything else
    if (sourceCustomer.errorList && [sourceCustomer.errorList count] > 0) {
        targetCustomer.errorList = [NSArray arrayWithArray: sourceCustomer.errorList];
        return;
    }
    
    // Merge other fields if customer ID is not 0.  This implies an "empty not found customer from the service.
    if (sourceCustomer.customerId && ![sourceCustomer.customerId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        targetCustomer.customerId = sourceCustomer.customerId;
        
        if (sourceCustomer.firstName && ![sourceCustomer.firstName isEqualToString:targetCustomer.firstName]) {
            targetCustomer.firstName = sourceCustomer.firstName;
        }
        if (sourceCustomer.lastName && ![sourceCustomer.lastName isEqualToString:targetCustomer.lastName]) {
            targetCustomer.lastName = sourceCustomer.lastName;
        }
        if (sourceCustomer.emailAddress && ![sourceCustomer.emailAddress isEqualToString:targetCustomer.emailAddress]) {
            targetCustomer.emailAddress = sourceCustomer.emailAddress;
        }
        if (sourceCustomer.phoneNumber && ![sourceCustomer.phoneNumber isEqualToString:targetCustomer.phoneNumber]) {
            targetCustomer.phoneNumber = sourceCustomer.phoneNumber;
        }
		if (sourceCustomer.customerType && ![sourceCustomer.customerType isEqualToString:targetCustomer.customerType]) {
			targetCustomer.customerType = sourceCustomer.customerType;
		}
		if (sourceCustomer.customerTypeId && ![sourceCustomer.customerTypeId isEqualToNumber:[NSNumber numberWithInt:0]]) {
			targetCustomer.customerTypeId = sourceCustomer.customerTypeId;
		}
		targetCustomer.taxExempt = sourceCustomer.taxExempt;
        
        // Merge Address information
        if (sourceCustomer.address) {
            if (targetCustomer.address == nil) {
                targetCustomer.address = [[[Address alloc] init] autorelease];
            }
            
            if (sourceCustomer.address.line1 && ![sourceCustomer.address.line1 isEqualToString:targetCustomer.address.line1]) {
                targetCustomer.address.line1 = sourceCustomer.address.line1;
            }
            if (sourceCustomer.address.line2 && ![sourceCustomer.address.line2 isEqualToString:targetCustomer.address.line2]) {
                targetCustomer.address.line2 = sourceCustomer.address.line2;            
            }
            if (sourceCustomer.address.city && ![sourceCustomer.address.city isEqualToString:targetCustomer.address.city]) {
                targetCustomer.address.city = sourceCustomer.address.city;            
            }
            if (sourceCustomer.address.stateProv && ![sourceCustomer.address.stateProv isEqualToString:targetCustomer.address.stateProv]) {
                targetCustomer.address.stateProv = sourceCustomer.address.stateProv;
            }
            if (sourceCustomer.address.zipPostalCode && ![sourceCustomer.address.zipPostalCode isEqualToString:targetCustomer.address.zipPostalCode]) {
                targetCustomer.address.zipPostalCode = sourceCustomer.address.zipPostalCode;
            }
        }
        
        // Merge Store information
        if (sourceCustomer.store) {
            if (targetCustomer.store == nil) {
                targetCustomer.store = [[[Store alloc] init] autorelease];
            }
            
            if (sourceCustomer.store.storeId && ![sourceCustomer.store.storeId isEqualToNumber: [NSNumber numberWithInt:0]]) {
                targetCustomer.store.storeId = sourceCustomer.store.storeId;
            }
        }
    }
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

-(void) mergeOrder:(Order *)targetOrder withOrder:(Order *)sourceOrder {
    // If there are errors just merge the errors, otherwise merge everything else
    if (sourceOrder.errorList && [sourceOrder.errorList count] > 0) {
        targetOrder.errorList = [NSArray arrayWithArray: sourceOrder.errorList];
        return;
    }
    
    if (sourceOrder.orderId && ![sourceOrder.orderId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        targetOrder.orderId = sourceOrder.orderId;
    }
}

@end
