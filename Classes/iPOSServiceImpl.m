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

// Private interface
@interface iPOSServiceImpl()
- (ASIHTTPRequest *) initRequestForSession:(SessionInfo *) sessionInfo serviceDomainUri: (NSString *) serviceDomainUri serviceUri: (NSString *) serviceUri;

- (BOOL) isNewCustomerValid: (Customer *) customer;
- (void) mergeCustomer: (Customer *) targetCustomer withCustomer: (Customer *) sourceCustomer;

- (BOOL) isSuccessful: (NSString *) xmlBooleanResponse;
- (Customer *) customerFromXmlResponse: (NSString *) xmlResponse;
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
    
    NSString *loginXML = [NSString stringWithFormat:@"<Login><UserName>%@</UserName><Password>%@</Password><DeviceID>%@</DeviceID></Login>", employeeNumber, password, sessionInfo.deviceId];
    [request appendPostData:[loginXML dataUsingEncoding:NSUTF8StringEncoding]];

    [request startSynchronous];
    
    if ([request error]) {
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
        ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"verify"];
        
        [request startSynchronous];
        
        if ([request error]) {
            return NO;
        }
        
        BOOL isSuccessful = [self isSuccessful:[request responseString]];
        
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
    
    BOOL isSuccessful = [self isSuccessful:[request responseString]];
        
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
    Customer *customer = [self customerFromXmlResponse:[request responseString]];
            
    if (customer == nil || (customer.errorList != nil && [customer.errorList count] > 0)) {
        return nil;
    }
    
    return customer;
}

-(void) newCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {
   // If a customer has an ID already we would add an error
    if (customer == nil || ![self isNewCustomerValid:customer]) {
        return;
    } 
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"new"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *addrLine1 = @"";
    NSString *addrLine2 = @"";
    NSString *addrCity = @"";
    NSString *addrState = @"";
    NSString *addrZip = @"";
    NSString *name = @"";
    NSString *email = @"";
    NSString *phone = @"";
    
    
    
    if (customer.address && customer.address.line1) {
        addrLine1 = customer.address.line1;
    }
    if (customer.address && customer.address.line2) {
        addrLine2 = customer.address.line2;
    }
    if (customer.address && customer.address.city) {
        addrCity = customer.address.city;
    }
    if (customer.address && customer.address.stateProv) {
        addrState = customer.address.stateProv;
    }
    if (customer.address && customer.address.zipPostalCode) {
        addrZip = customer.address.zipPostalCode;
    }
    if (customer.firstName && customer.lastName) {
        name = [NSString stringWithFormat:@"%@, %@", customer.lastName, customer.firstName];
    } else if (customer.lastName) {
        name = customer.lastName;
    } else if (customer.firstName) {
        name = customer.firstName;
    }
    if (customer.emailAddress) {
        email = customer.emailAddress;
    }
    if (customer.phoneNumber) {
        phone = customer.phoneNumber;
    }
    
    NSString *newCustomerXML = [NSString stringWithFormat:@"<CustomerClass>"
                                "<Address><CustomerAddress><Address1>%@</Address1><Address2>%@</Address2><City>%@</City><State>%@</State><ZipCode>%@</ZipCode></CustomerAddress></Address>"
                                "<CustomerName>%@</CustomerName>"
                                "<Email>%@</Email>"
                                "<Phone1>%@</Phone1>"
                                "</CustomerClass>", addrLine1, addrLine2, addrCity, addrState, addrZip, name, email, phone];
    [request appendPostData:[newCustomerXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    if ([request error]) {
        return;
    }
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [self customerFromXmlResponse:[request responseString]];
    [self mergeCustomer: customer withCustomer:resultCustomer];
}

-(void) updateCustomer:(Customer *)customer withSession:(SessionInfo *)sessionInfo {
    // If a customer has an ID already we would add an error
    if (customer == nil) {
        return;
    } 
    
    // Send the lookup request
    ASIHTTPRequest *request = [self initRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"update"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *addrLine1 = nil;
    NSString *addrLine2 = nil;
    NSString *addrCity = nil;
    NSString *addrState = nil;
    NSString *addrZip = nil;
    NSString *name = nil;
    NSString *email = nil;
    NSString *phone = nil;
    
    if (customer.address && customer.address.line1) {
        addrLine1 = customer.address.line1;
    }
    if (customer.address && customer.address.line2) {
        addrLine2 = customer.address.line2;
    }
    if (customer.address && customer.address.city) {
        addrCity = customer.address.city;
    }
    if (customer.address && customer.address.stateProv) {
        addrState = customer.address.stateProv;
    }
    if (customer.address && customer.address.zipPostalCode) {
        addrZip = customer.address.zipPostalCode;
    }
    if (customer.firstName && customer.lastName) {
        name = [NSString stringWithFormat:@"%@, %@", customer.lastName, customer.firstName];
    } else if (customer.lastName) {
        name = customer.lastName;
    } else if (customer.firstName) {
        name = customer.firstName;
    }
    if (customer.emailAddress) {
        email = customer.emailAddress;
    }
    if (customer.phoneNumber) {
        phone = customer.phoneNumber;
    }
    
    // Build the XML
    NSString *updateCustomerXML = @"<CustomerClass>";
    
    // Add address information
    if (addrLine1 || addrLine2 || addrCity || addrState || addrZip) {
        updateCustomerXML = [updateCustomerXML stringByAppendingString:@"<Address><CustomerAddress>"];
        
        if (addrLine1) {
            updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<Address1>%@</Address1>", addrLine1];
        }
        if (addrLine2) {
            updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<Address2>%@</Address2>", addrLine2];
        }
        if (addrCity) {
            updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<City>%@</City>", addrCity];
        }
        if (addrState) {
            updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<State>%@</State>", addrState];
        }
        if (addrZip) {
            updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<ZipCode>%@</ZipCode>", addrZip];
        }
        updateCustomerXML = [updateCustomerXML stringByAppendingString:@"</CustomerAddress></Address>"];
    }
    
    // Add other information
    if (customer.customerId) {
        updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<CustomerID>%@</CustomerID>", customer.customerId];
    }
    if (name) {
        updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<CustomerName>%@</CustomerName>", name];
    }
    if (email) {
        updateCustomerXML = [updateCustomerXML stringByAppendingFormat:@"<Email>%@</Email>", email];
    }
    // Not allowed to modify phone number.  Do not send it.
    
    updateCustomerXML = [updateCustomerXML stringByAppendingString:@"</CustomerClass>"];
    
    [request appendPostData:[updateCustomerXML dataUsingEncoding:NSUTF8StringEncoding]];
    [request startSynchronous];
    
    if ([request error]) {
        return;
    }
    
    // Parse the XML response for the customer details
    Customer *resultCustomer = [self customerFromXmlResponse:[request responseString]];
    [self mergeCustomer: customer withCustomer:resultCustomer];
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

-(BOOL) isNewCustomerValid: (Customer *) customer {
    NSMutableArray *errors = [NSMutableArray arrayWithCapacity:1];
    if (customer.customerId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = @"Customer is already created.";
        error.reference = customer;
        
        [errors addObject:error];
        
    } 
    
    if ((customer.firstName == nil && customer.lastName == nil) || customer.phoneNumber == nil || customer.address == nil || customer.address.zipPostalCode == nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = @"Missing required data.";
        error.reference = customer;
        
        [errors addObject:error];
    }
    
    
    
    if ([errors count] > 0) {
        customer.errorList = [NSArray arrayWithArray:errors];
        return NO;
    }
    
    return YES;
}

- (void) mergeCustomer: (Customer *) targetCustomer withCustomer: (Customer *) sourceCustomer {
    // If there are errors just merge the errors, otherwise merge everything else
    if (sourceCustomer.errorList && [sourceCustomer.errorList count] > 0) {
        targetCustomer.errorList = [NSArray arrayWithArray: sourceCustomer.errorList];
        return;
    }
    
    // Merge other fields
    if (sourceCustomer.customerId && (targetCustomer.customerId == nil || ![sourceCustomer.customerId isEqualToNumber:targetCustomer.customerId])) {
        targetCustomer.customerId = sourceCustomer.customerId;
    }
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
    
    // Merge Address information
    if (sourceCustomer.address) {
        if (targetCustomer.address == nil) {
            targetCustomer.address = [[[Address alloc] init] autorelease];
        }
        
        if (sourceCustomer.address.line1 && ![sourceCustomer.address.line1 isEqualToString:sourceCustomer.address.line1]) {
            targetCustomer.address.line1 = sourceCustomer.address.line1;
        }
        if (sourceCustomer.address.line2 && ![sourceCustomer.address.line2 isEqualToString:sourceCustomer.address.line2]) {
            targetCustomer.address.line2 = sourceCustomer.address.line2;            
        }
        if (sourceCustomer.address.city && ![sourceCustomer.address.city isEqualToString:sourceCustomer.address.city]) {
            targetCustomer.address.city = sourceCustomer.address.city;            
        }
        if (sourceCustomer.address.stateProv && ![sourceCustomer.address.stateProv isEqualToString:sourceCustomer.address.stateProv]) {
            targetCustomer.address.stateProv = sourceCustomer.address.stateProv;
        }
        if (sourceCustomer.address.zipPostalCode && ![sourceCustomer.address.zipPostalCode isEqualToString:sourceCustomer.address.zipPostalCode]) {
            targetCustomer.address.zipPostalCode = sourceCustomer.address.zipPostalCode;
        }
    }
}


-(BOOL) isSuccessful:(NSString *) xmlBooleanResponse {
    // Create an XML document parser
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlBooleanResponse options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    BOOL isSuccessful = NO;
    
    // Parse the response to fetch the boolean result
    if (root != nil) {
        isSuccessful = [[root stringValue] boolValue];
    }
    
    // Return resul
    return isSuccessful;
}

-(Customer *) customerFromXmlResponse:(NSString *)xmlResponse {
    Customer *customer = nil;
    Address *address = nil;
    Error *error = nil;
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlResponse options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Extract the itemID.  If it 0 return nil;
    NSArray *nodes = nil;
    NSArray *errorNodes = nil;
    CXMLElement *element = nil;
    CXMLElement *errorElement = nil;
    CXMLElement *addressElement = nil;
    
    nodes = [root elementsForName:@"CustomerID"];
    element = [nodes lastObject];
    
    errorNodes = [root elementsForName:@"Error"];
    errorElement = [errorNodes lastObject];
    
    // If error return customer with error
    if (![[errorElement stringValue] isEqualToString:@""]) {
        NSMutableArray *errorList = [[[NSMutableArray alloc] init] autorelease];
        
        customer = [[[Customer alloc] init] autorelease];
        error = [[[Error alloc] init] autorelease];
        
        error.message = [errorElement stringValue];
        
        [errorList addObject:error];
        customer.errorList = [NSArray arrayWithArray:errorList];
    } else if (![[[nodes lastObject] stringValue] isEqualToString:@"0"]) {
        // Return fully "mapped" customer If no error and customerID is not
        customer = [[[Customer alloc] init] autorelease];
        
        customer.customerId = [NSNumber numberWithInt:[[element stringValue] intValue]];
        
        nodes = [root elementsForName:@"CustomerType"];
        element = [nodes lastObject];
        customer.customerType = [element stringValue];
        
        nodes = [root elementsForName:@"CustomerName"];
        element = [nodes lastObject];
        
        // Split into first and last name
        NSArray *names = [[element stringValue] componentsSeparatedByString:@","];
        
        if ([names count] == 2) {
            customer.lastName = [(NSString *) [names objectAtIndex:0] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
            customer.firstName = [(NSString *) [names objectAtIndex:1] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        } else {
            customer.firstName = [element stringValue];
        }
        
        nodes = [root elementsForName:@"Phone1"];
        element = [nodes lastObject];
        customer.phoneNumber = [element stringValue];
        
        nodes = [root elementsForName:@"Email"];
        element = [nodes lastObject];
        customer.emailAddress = [element stringValue];
        
        nodes = [root elementsForName:@"TaxExempt"];
        element = [nodes lastObject];
        if ([[element stringValue] isEqualToString: @"true"]) {
            customer.taxExempt = YES;
        } else {
            customer.taxExempt = NO;
        }
        
        nodes = [root elementsForName:@"Address"];
        element = [nodes lastObject];
        
        // Now get the Customer Address
        nodes = [element elementsForName:@"CustomerAddress"];
        addressElement = [nodes lastObject];

        address = [[[Address alloc] init] autorelease];
        
        nodes = [addressElement elementsForName:@"Address1"];
        element = [nodes lastObject];
        address.line1 = [element stringValue];

        nodes = [addressElement elementsForName:@"Address2"];
        element = [nodes lastObject];
        address.line2 = [element stringValue];

        nodes = [addressElement elementsForName:@"City"];
        element = [nodes lastObject];
        address.city = [element stringValue];

        nodes = [addressElement elementsForName:@"State"];
        element = [nodes lastObject];
        address.stateProv = [element stringValue];

        nodes = [addressElement elementsForName:@"ZipCode"];
        element = [nodes lastObject];
        address.zipPostalCode = [element stringValue];
        
        
        customer.address = address;
    } 
    
    element = nil;
    errorElement = nil;
    addressElement = nil;
    
    return customer;
    
}

@end
