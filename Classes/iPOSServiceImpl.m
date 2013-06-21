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
#import "Room.h"

#import "OrderDiscountApprovalRequest.h"
#import "OrderDiscountApprovalResponse.h"

#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "CXMLElement+CustomExtensions.h"

#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"
#import "RIButtonItem.h"
#import "iPOSFacade.h"

// Private interface
@interface iPOSServiceImpl()
- (NSString *) escapeXMLForParsing: (NSString *) xmlString;

- (ASIHTTPRequest *) getRequestForSession:(SessionInfo *) sessionInfo serviceDomainUri: (NSString *) serviceDomainUri serviceUri: (NSString *) serviceUri;
- (ASIHTTPRequest *) getRequestForSession:(SessionInfo *) sessionInfo url: (NSString *) urlString;

- (void) saveOrder: (Order *) order withSession: (SessionInfo *) sessionInfo;

- (void) saveSheet: (SelectionSheet *) sheet withSession: (SessionInfo *) sessionInfo;
-(void) sendEmail:(SelectionSheet *)sheet withSession:(SessionInfo *)sessionInfo;
-(NSArray *) listOfStringsFromXml:(NSString *)xmlString;

@end

@implementation iPOSServiceImpl

@synthesize baseUrl, ssbaseUrl, posSessionMgmtUri, posCustomerMgmtUri, posOrderMgmtUri, posReportMgmtUri, selSheetMgmtUri, posInventoryMgmtUri, selSheetLookupUri, selSheetProjectUri, selSheetReportUri;;

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
    [ssbaseUrl release];
    [posSessionMgmtUri release];
    [posCustomerMgmtUri release];
    [posOrderMgmtUri release];
    [posReportMgmtUri release];
    [selSheetMgmtUri release];
    
    
    [super dealloc];
}

-(void) setToDemoMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];    
    self.ssbaseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"selsheet.service.demo.baseurl"]; 
    self.posSessionMgmtUri = @"SessionService";
    self.posCustomerMgmtUri = @"CustomerService";
    self.posOrderMgmtUri = @"OrderService";
    self.posReportMgmtUri = @"ReportService";
    self.posInventoryMgmtUri = @"ItemService";
    self.selSheetMgmtUri = @"LookupService";
    self.selSheetLookupUri = @"LookupService";
    self.selSheetProjectUri = @"ProjectService";
    self.selSheetReportUri = @"ReportService";
}

-(void) setToReleaseMode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.ssbaseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"selsheet.service.baseurl"];
    self.posSessionMgmtUri = @"SessionService";
    self.posCustomerMgmtUri = @"CustomerService";
    self.posOrderMgmtUri = @"OrderService";
    self.posReportMgmtUri = @"ReportService";
    self.posInventoryMgmtUri = @"ItemService";
    self.selSheetMgmtUri = @"LookupService";
    self.selSheetLookupUri = @"LookupService";
    self.selSheetProjectUri = @"ProjectService";
    self.selSheetReportUri = @"ReportService";
}

#pragma mark -
#pragma mark iPOS Session Mgmt
-(SessionInfo *) login: (NSString *) employeeNumber withPassword: (NSString *) password {
    SessionInfo *sessionInfo = [[[SessionInfo alloc] init] autorelease];
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"login"];
    
    // We will be posting the login as an XML Request
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    sessionInfo.loginUserName = employeeNumber;
    sessionInfo.passwordForVerification = password;
    
    NSString *loginXML = [self escapeXMLForParsing:[sessionInfo toLoginRequestXml]];
    NSLog(@"Login req string: %@", loginXML);
    [request appendPostData:[loginXML dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    if ([request error]) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    NSLog(@"Login Response string: %@", response);
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
        return NO;
    }
    
    if (password && [password isEqualToString:sessionInfo.passwordForVerification]) {
        ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"verify"];
        
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
        return NO;
    }
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"logout"];
    
    [request startSynchronous];
    
    if ([request error]) {
        return NO;
    }
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    
    // Return result
    return isSuccessful;
}

//==================sssession mgmt
#pragma mark -
#pragma mark iPOS Session Mgmt
-(SessionInfo *) sslogin: (NSString *) employeeNumber withPassword: (NSString *) password {
    SessionInfo *sessionInfo = [[[SessionInfo alloc] init] autorelease];
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"login"];
    
    // We will be posting the login as an XML Request
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    sessionInfo.loginUserName = employeeNumber;
    sessionInfo.passwordForVerification = password;
    
    NSString *loginXML = [self escapeXMLForParsing:[sessionInfo toLoginRequestXml]];
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

-(BOOL) ssverifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password {
    if (sessionInfo == nil) {
        return NO;
    }
    
    if (password && [password isEqualToString:sessionInfo.passwordForVerification]) {
        ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"verify"];
        
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

-(BOOL) sslogout: (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return NO;
    }
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:posSessionMgmtUri serviceUri:@"logout"];
    
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
- (NSArray *) lookupCustomerByName:(NSString *) customerName withSession:(SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSString *customerlookupUri = @"customerlookup";
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:customerlookupUri];
    
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<CustomerSearch>%@</CustomerSearch>", customerName]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSArray *items = [Customer listFromXml:[request responseString]];
    NSLog(@"Success!!!!");
    
    return items;
}

-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Send the lookup request
    NSString *customerlookupUri = [NSString stringWithFormat:@"%@", phoneNumber];
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:customerlookupUri];
    
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    }
    
    //Enning Tang Check Response String
    NSLog(@"Lookup Customer Response String: %@", [request responseString]);
    
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
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"new"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *customerXml = [self escapeXMLForParsing:[customer toXml]];    
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
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posCustomerMgmtUri serviceUri:@"update"];
    
    // Post data for customer
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *customerXml = [self escapeXMLForParsing:[customer toXml]];
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
- (void) save:(Order *)order withSession:(SessionInfo *)sessionInfo {
    if (order == nil) {
        NSLog(@"No order to save.");
        return;
    }
    
    // Basic Validation
    [order removeAllErrors];
    
    if (order.isNewOrder) {
        NSLog(@"Saving order as new quote or order");
        
        // Wipe out the order id for new
        order.orderId = nil;
        
        if ([order isQuote] && ![order validateAsNewQuote]) {
            return;
        } else if (![order validateAsNewOrder]) {
            return;
        }
    } 
    
    // Save the order or quote
    [self saveOrder:order withSession:sessionInfo];
}

-(void) saveOrder:(Order *)order withSession:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    
    NSLog(@"Save Order called");
    
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
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"save"];
    
    // Post data for order
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    //Enning Tang pass version string to webservice 3/20/2013
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *currentVersion = [NSString stringWithFormat:@"%@%@", @"ver.", (NSString *) [bundle objectForInfoDictionaryKey:@"currentVersion"]];
    order.currentVersion = currentVersion;
    
    NSString *orderXml = [self escapeXMLForParsing:[order toXml]];
    
    NSLog(@"Save Order XML:");
    NSLog(@"%@", orderXml);
    
    
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
    
    // Merge the order from the result and mark the order as current (not modified)
    [order mergeWith:orderReturned];
    
    //Enning Tang if existing order, release order lock after saved order 3/22/2013
    //if (!order.isNewOrder)
    //{
    //    iPOSFacade *facade = [iPOSFacade sharedInstance];
    //    [facade releaseTransactionLock:order.orderId.stringValue];
    //}
    //================================================
}

- (BOOL) orderDiscountFor:(Order *)order withDiscountAmount:(NSDecimalNumber *)discountAmount 
          managerApproval:(ManagerInfo *)managerApprover withSession:(SessionInfo *)sessionInfo {
    
    // Determine if we can actually apply the discount
    if (![order canApplyDiscount:discountAmount]) {
        return NO;
    }
    
    BOOL allowAdjustment = NO;
    OrderDiscountApprovalRequest *discountApprovalRequest = [[OrderDiscountApprovalRequest alloc] 
                                                             initWithOrder:order 
                                                             managerInfo:managerApprover 
                                                             withOrderDiscount:discountAmount]; 
    
    @try {
        // Send the request
        ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"changePriceApproval"];
        
        NSString *orderDiscountRequestXml = [self escapeXMLForParsing:[discountApprovalRequest toXml]];
        
        [request appendPostData:[orderDiscountRequestXml dataUsingEncoding:NSUTF8StringEncoding]];
        [request startSynchronous];
        
        NSArray *requestErrors = [request validateAsXmlContent];
        if ([requestErrors count] > 0) {
            return NO;   
        } 
        
        // Parse the response, set the authorizer ID and selling price
        OrderDiscountApprovalResponse *approvalResponse = [OrderDiscountApprovalResponse fromXml:[request responseString]];
        
        // Need to loop through all the approvals and set the matching items selling price
        if ([approvalResponse isApproved]) {
            NSArray *openItems = [order getOrderItems:LINE_ORDERSTATUS_OPEN];
            
            if (openItems && [openItems count] == [approvalResponse.itemSellingPriceApprovalList count]) {
                ItemSellingPriceApprovalResponse *approval = nil;
                OrderItem *item = nil;
                
                // Distribute the discount amount evenly across order items
                NSLog(@"3");
                NSDecimalNumber *discountPercent = [discountAmount decimalNumberByDividingBy:[order calcOpenItemsSubTotal]];
                NSDecimalNumber *discountForItem = nil;
                
                for (int i=0; i < [openItems count]; i++) {
                    approval = [approvalResponse.itemSellingPriceApprovalList objectAtIndex:i];
                    item = [openItems objectAtIndex:i];
                    discountForItem = [[item calcLineSubTotal] decimalNumberByMultiplyingBy:discountPercent];
                    
                    if ([approval.authorizationId compare: [NSDecimalNumber zero]] != NSOrderedSame) {
                        item.priceAuthorizationId = approval.authorizationId;
                    }
                    
                    // Divide the discount amount evenly across order items
                    [item setSellingPriceFrom:discountForItem];
                    
                    approval = nil;
                    item = nil;
                    discountForItem = nil;
                }
            }
            
            allowAdjustment = YES;
            return allowAdjustment;
        }
    } @finally {
        [discountApprovalRequest release];
        discountApprovalRequest = nil;
    }
}

//Enning Tang Add Lookup Stores 10/24/2012
-(NSArray *) storelookup:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    
    NSLog(@"lookup stores called");
    
    if (sessionInfo == nil) {
        NSLog(@"session is null");
    }

    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"storelookup"];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        
        for (Error *error in requestErrors) {
            
        }
        
        //return;
    }
    
    NSString *resp = [request responseString];
    resp = [resp stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    resp = [resp stringByReplacingOccurrencesOfString:@"||</string>" withString:@""];
    NSArray *stores = [resp componentsSeparatedByString:@"||"];

    //for(NSString *currentNumberString in stores) {
      //  NSLog(@"Number: %@", currentNumberString);
    //}
    NSLog(@"length %@", [NSString stringWithFormat:@"%d", [stores count]]);
    
    return stores;
}

//Enning Tang Add Lookup Stores 10/24/2012
-(NSString *) storelookupbysalesperson:(SessionInfo *)sessionInfo salesperson:(NSString *)salesperson{
	// Make sure that we have a valid session and order
    
    NSLog(@"lookup store by salesperson called");
    
    if (sessionInfo == nil) {
        NSLog(@"session is null");
    }
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"storelookupbysalesperson"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<Salesperson>%@</Salesperson>", salesperson]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        
        for (Error *error in requestErrors) {
            
        }
        
        //return;
    }
    
    NSString *resp = [request responseString];
    resp = [resp stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    resp = [resp stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
    //NSArray *stores = [resp componentsSeparatedByString:@"||"];
    
    //for(NSString *currentNumberString in stores) {
    //    NSLog(@"Number: %@", currentNumberString);
    //}
    //NSLog(@"length %@", [NSString stringWithFormat:@"%d", [stores count]]);
    NSLog(@"%@", resp);
    
    return resp;
}

//Enning Tang Add Lookup Stores 10/24/2012
-(NSDecimalNumber *) taxratelookupbystoreid:(SessionInfo *)sessionInfo shiptostoreid:(NSString *)shiptostoreid{
	// Make sure that we have a valid session and order
    
    NSLog(@"lookup taxrate by shiptostoreid called");
    
    if (sessionInfo == nil) {
        NSLog(@"session is null");
    }
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"taxratelookupbystoreid"];
    
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<ShipToStoreID>%@</ShipToStoreID>", shiptostoreid]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        
        for (Error *error in requestErrors) {
            
        }
        
        //return;
    }
    
    NSString *resp = [request responseString];
    resp = [resp stringByReplacingOccurrencesOfString:@"<decimal xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    resp = [resp stringByReplacingOccurrencesOfString:@"</decimal>" withString:@""];
    //NSArray *stores = [resp componentsSeparatedByString:@"||"];
    
    //for(NSString *currentNumberString in stores) {
    //    NSLog(@"Number: %@", currentNumberString);
    //}
    //NSLog(@"length %@", [NSString stringWithFormat:@"%d", [stores count]]);
    NSLog(@"%@", resp);
    
    /*
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setGeneratesDecimalNumbers:TRUE];
    
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    
    NSDecimalNumber *resdes = [formatter numberFromString:resp];
    NSDecimalNumber *resdesrounding = [resdes decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    */
    NSDecimalNumber *resdesrounding = [NSDecimalNumber decimalNumberWithString:resp];
    
    return resdesrounding;
}

#pragma mark -
#pragma mark Order Mgmt APIs
/*- (void) save:(SelectionSheet *)sheet withSession:(SessionInfo *)sessionInfo {
    if (sheet == nil) {
        NSLog(@"No sheet to save.");
        return;
    }
    
    // Basic Validation
    // [order removeAllErrors];
    
    if (sheet.newSheet) {
        NSLog(@"Saving order as new quote or order");
        
        // Wipe out the order id for new
        //     order.orderId = nil;
        sheet.storeId = sessionInfo.storeId;
        sheet.salesPersonId = sessionInfo.employeeId;
        
    } 
    
    // Save the order or quote
    [self saveSheet:sheet withSession:sessionInfo];
}*/

-(void) saveSheet:(SelectionSheet *)sheet withSession:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    if (sessionInfo == nil || sheet == nil) {
        return;
    } 
    
    // Send the new order request
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:selSheetProjectUri serviceUri:@"save"];
    
    // Post data for order
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *sheetXml = [[sheet toXml] stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];  
    
    NSLog(@"Request is : \n %@", sheetXml);
    
    [request appendPostData:[sheetXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    NSLog(@"response is : \n %@", request.responseString);
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        
    }
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:request.responseString options:0 error:nil] autorelease];
    CXMLElement *node = [xmlParser rootElement];
    
    // CXMLElement *errorList = [node firstElementNamed:@"ErrorList"];
    
    // NSString *errorId = [errorList elementStringValue:@"ErrorID"];
    NSString *projectUid = [node elementStringValue:@"ProjectUID"];
    
    
    if (projectUid != nil && ![projectUid isEqualToString:@""] && sheet.customer.emailAddress != nil && ![sheet.customer.emailAddress isEqualToString:@""]) {
        
        sheet.projectUid = projectUid;
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        
        RIButtonItem *sendItem = [RIButtonItem itemWithLabel:@"Email"];
        sendItem.action = ^
        {
            // DO some service to send
            [self sendEmail:sheet withSession:sessionInfo];
        };
        
        UIAlertView *emailAlert = [[UIAlertView alloc] initWithTitle:@"Send Email?" 
                                                             message:@"Sheet Saved, would you also like to email a copy to the customer?" 
                                                    cancelButtonItem:cancelItem 
                                                    otherButtonItems:sendItem, nil];
        
        [emailAlert show];
        [emailAlert release];
        
        
        // Clear out the order type if it was set and any errors
        /*  order.orderTypeId = nil;
         [order removeAllErrors];
         
         for (Error *error in requestErrors) {
         [order addError:error];
         }
         
         return;  */ 
    }
    
    return;
}


-(void) sendEmail:(SelectionSheet *)sheet withSession:(SessionInfo *)sessionInfo {
    
    if (sessionInfo == nil || sheet == nil) {
        return;
    } 
    
    NSLog(@"Email attempt to %@/%@/report/%@/%@",ssbaseUrl, selSheetReportUri, sheet.projectUid, sheet.customer.emailAddress );
    
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/report/%@/%@", ssbaseUrl, selSheetReportUri, sheet.projectUid, sheet.customer.emailAddress] withSession:sessionInfo];
    
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"ERRORS");
        
    }
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:request.responseString options:0 error:nil] autorelease];
    CXMLElement *node = [xmlParser rootElement];
    
    NSString *result = [node stringValue];
    
    NSLog(@"Email result %@",result);
    
    // Create an XML document parser
    // NSString *response = [request responseString];
    
}

-(NSArray *) lookupRoomsWithSession:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    if (sessionInfo == nil ) {
        return nil;
    } 
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:self.selSheetMgmtUri serviceUri:@"room"];
    
    NSLog(@"Rooms attempt to %@",self.selSheetMgmtUri);
    
    // We will be posting the login as an XML Request
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    [request startSynchronous];
    NSLog(@"XML response %@",[request responseString]);
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSLog(@"XML response %@",[request responseString]);
    NSArray *rooms = [self listOfStringsFromXml:[request responseString]];
    
    return rooms;
    
}

-(NSArray *) lookupAreasWithSession:(SessionInfo *)sessionInfo {
	// Make sure that we have a valid session and order
    if (sessionInfo == nil ) {
        return nil;
    } 
    
    // Make Synchronous HTTP request
    ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:self.selSheetMgmtUri serviceUri:@"area"];
    
    // We will be posting the login as an XML Request
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    [request startSynchronous];
    NSLog(@"XML response %@",[request responseString]);
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSLog(@"XML response %@",[request responseString]);
    NSArray *areas = [self listOfStringsFromXml:[request responseString]];
    
    return areas;
}

#pragma mark -
#pragma mark Report Management APIs
- (BOOL) emailReceipt:(Order *)order withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil || order == nil || order.customer == nil) {
        return NO;
    }
    
    // Make Synchronous HTTP request
    NSString *orderId = [NSString stringWithFormat:@"%@", order.orderId];
    NSString *email = order.customer.emailAddress;
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", baseUrl, posReportMgmtUri, @"receipt", orderId, email];
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo url:urlString];
    
    NSLog(@"Sending Email... %@ %@ %@", urlString, order.orderId.stringValue, order.customer.emailAddress);
    
    [request startSynchronous];
    
    if ([request error]) {
        NSLog(@"Email Error");
        return NO;
    }
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    NSLog(@"Response String: %@", [request responseString]);
    
    
    // Return result
    return isSuccessful;
}

- (BOOL) emailReceiptWithEmail:(Order *)order withEmail:(NSString *)emailAddress withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil || order == nil || order.customer == nil) {
        return NO;
    }
    
    // Make Synchronous HTTP request
    NSString *orderId = [NSString stringWithFormat:@"%@", order.orderId];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@/%@/%@", baseUrl, posReportMgmtUri, @"receipt", orderId, emailAddress];
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo url:urlString];
    
    NSLog(@"Sending Email... %@ %@ %@", urlString, order.orderId.stringValue, order.customer.emailAddress);
    
    [request startSynchronous];
    
    if ([request error]) {
        NSLog(@"Email Error");
        return NO;
    }
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    NSLog(@"Response String: %@", [request responseString]);
    
    
    // Return result
    return isSuccessful;
}

#pragma mark -
#pragma mark Private interface
- (NSString *) escapeXMLForParsing: (NSString *) xmlString {
    
    // Replace any entity reference or XML special characters that could impact parsing
    NSString *escapedString = [xmlString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    return escapedString;
}

-(ASIHTTPRequest *) getRequestForSession:(SessionInfo *)sessionInfo serviceDomainUri:(NSString *)serviceDomainUri serviceUri:(NSString *)serviceUri {
    // Make Synchronous HTTP request to verify the login session
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", baseUrl, serviceDomainUri, serviceUri];
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo url:urlString];
    return request;
}
-(ASIHTTPRequest *) getRequestForSession:(SessionInfo *)sessionInfo url:(NSString *) urlString {
    // Make Synchronous HTTP request to verify the login session
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    return request;
}


//==========SSSession reload
-(ASIHTTPRequest *) ssgetRequestForSession:(SessionInfo *)sessionInfo serviceDomainUri:(NSString *)serviceDomainUri serviceUri:(NSString *)serviceUri {
    // Make Synchronous HTTP request to verify the login session
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", ssbaseUrl, serviceDomainUri, serviceUri];
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo url:urlString];
    return request;
}
-(ASIHTTPRequest *) ssgetRequestForSession:(SessionInfo *)sessionInfo url:(NSString *) urlString {
    // Make Synchronous HTTP request to verify the login session
    NSURL *url = [NSURL URLWithString:urlString];
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

-(NSArray *) listOfStringsFromXml:(NSString *)xmlString {
    
    if (xmlString == nil) {
        return nil;
    }
    
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Add the items to the list
    for (CXMLElement *node in [root elementsForName:@"string"]) {
        [itemList addObject:[node stringValue]];
    }
    
    return itemList;
}


#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    NSLog(@"Request is %@/%@/%@/%@",baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku);
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId, itemSku] withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    // Create an XML document parser
    NSString *response = [request responseString];
    NSLog(@"XML response %@",[request responseString]);
    
    ProductItem *item = [ProductItem fromXml:response];
    return item;
}

//Enning Tang Add lookupProductItemByStore 11/19/2012
-(ProductItem *) lookupProductItemByStore: (NSString *) itemSku withStoreid:  (NSString *) StoreID withSession:  (SessionInfo *) sessionInfo{
    
    if (sessionInfo == nil) {
        return nil;
    }
    
    NSLog(@"Request is %@/%@/%@/%@",baseUrl, posInventoryMgmtUri, StoreID, itemSku);
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, posInventoryMgmtUri, StoreID, itemSku] withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    NSLog(@"XML response %@",[request responseString]);
    
    ProductItem *item = [ProductItem fromXml:response];
    return item;
    
}


- (NSArray *) lookupProductItemByName:(NSString *)itemName withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    NSLog(@"Request is %@/%@/name/%@",  baseUrl, posInventoryMgmtUri, sessionInfo.storeId);
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/name/%@", baseUrl, posInventoryMgmtUri, sessionInfo.storeId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [NSString stringWithFormat:@"<ItemSearch>%@</ItemSearch>", itemName];    
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSLog(@"XML response %@",[request responseString]);
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSArray *items = [ProductItem listFromXml:[request responseString]];
    
    return [items sortedArrayUsingSelector:@selector(compare:)];
}


-(NSArray *) lookupSheetByProduct:(NSString *) product andCustomer:(NSString *) customer andContractor:(NSString *) contractor andArchived:(Boolean) archived withSession:(SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    
    NSLog(@"Request is %@/%@/selectionlookup",  ssbaseUrl, selSheetLookupUri);
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/selectionlookup", ssbaseUrl, self.selSheetLookupUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    NSLog(@"Request URL: %@", url);
    
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [NSString stringWithFormat:@"<SelectionSearch>\
                            <StoreID>%@</StoreID>\
                            <SalesPersonID>%@</SalesPersonID>\
                            <ProjectName>%@</ProjectName>\
                            <ClientName>%@</ClientName>\
                            <ContractorName>%@</ContractorName>\
                            <Archived>%@</Archived>\
                            </SelectionSearch>", sessionInfo.storeId, sessionInfo.employeeId, product, customer, contractor, (archived ? @"true" : @"false")];    
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"REQUEST is %@",requestXml);
    [request startSynchronous];
    NSString *responsestring = [request responseString];
    NSLog(@"Response is %@", responsestring);
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"requestError");
        return nil;   
    } 
    
    NSArray *items = [SelectionSheet listFromXml:[request responseString]];
    
    return items;
    
}


//==============================================SelectionSelect
-(NSString *)lookupSelection:(NSString *)productUID withSession:(SessionInfo *)sessionInfo{
    if (sessionInfo == nil) {
        return nil;
    }
    
    NSLog(@"LookupSelection running");
    
    // Send the lookup request
    NSString *selectionselectUri = [NSString stringWithFormat:@"%@", productUID];
    ASIHTTPRequest *request = [self ssgetRequestForSession:sessionInfo serviceDomainUri:selSheetMgmtUri serviceUri:selectionselectUri];
    
    
    NSLog(@"%@", [request url]);
    [request setTimeOutSeconds:10];
    [request startSynchronous];
    
    NSLog(@"%@", productUID);
    //NSLog(@"Response String: %@", [request responseString]);
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    }
    
    
    // Parse the XML response for the customer details
    //Project *pr =  [Project fromXml:[request responseString]];
    
    //if (pr == nil || (pr.errorList != nil && [pr.errorList count] > 0)) {
      //  return nil;
    //}
    //return [request responseData];
    return [request responseString];

}

//=============================================

-(SelectionSheet *)lookupSheetById:(NSString *) sheetId withSession:(SessionInfo *) sessionInfo {
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    /* NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, self.selSheetLookupUri, sheetId]];
     ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
     
     [request setValidatesSecureCertificate:NO];
     [request setTimeOutSeconds:30];
     [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
     [request addRequestHeader:@"Content-Type" value:@"text/xml"];*/
    
    NSLog(@"Sheet ID is %@",sheetId);
    
    NSString *requestURL = [NSString stringWithFormat:@"%@/%@/%@", ssbaseUrl, self.selSheetLookupUri, sheetId];
    
    NSLog(@"URL is %@",requestURL);
    
    ASIHTTPRequest *request =  [self startGetRequest:requestURL withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    
    // Create an XML document parser
    NSString *response = [request responseString];
    NSLog(@"Response is %@",response);
    
    SelectionSheet *item = [SelectionSheet fromXml:response];
    return item;
    
    
    // [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    /* NSArray *requestErrors = [request validateAsXmlContent];
     if ([requestErrors count] > 0) {
     return nil;   
     } 
     
     NSArray *items = [SelectionSheet listFromXml:[request responseString]];
     
     return items;
     */
}




/*-(BOOL) isProductItemAvailable:  (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity withSession:  (SessionInfo *) sessionInfo {
 if (sessionInfo == nil) {
 return NO;
 }
 
 ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/availability/%@/%@/%@", baseUrl, posInventoryMgmtUri,sessionInfo.storeId, itemId, quantity] withSession:sessionInfo];
 NSArray *requestErrors = [request validateAsXmlContent];
 if ([requestErrors count] > 0) {
 return NO;   
 } 
 
 // Create an XML document parser
 NSString *response = [request responseString];
 BOOL isAvailable =  [POSOxmUtils isXmlResultTrue:response];
 
 // Return result
 return isAvailable;
 }*/


//Enning Tang 1/28/2013 getLTLWeight
-(NSNumber *) getLTLWeight:(NSNumber *)ItemID withQuantity:(NSNumber *)Quantity withSession:  (SessionInfo *) sessionInfo
{
    NSLog(@"GET LTL WEIGHT CALLED...%@ %@", ItemID, Quantity);
    NSNumber *weight = [[NSNumber alloc]initWithInt:0];
    
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/LTL/%@/%@", baseUrl, posInventoryMgmtUri, ItemID, Quantity] withSession:sessionInfo];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"LTL Weight request error");
        return weight;
    }
    
    // Create an XML document parser
    NSString *response = [request responseString];
    //NSLog(@"Response String: %@", response);
    
    NSString *stringWt = [response stringByReplacingOccurrencesOfString:@"</int>" withString:@""];
    stringWt = [stringWt stringByReplacingOccurrencesOfString:@"<int xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    
    //NSLog(@"Response String from LTL Weight: %@", stringWt);
    
        
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    weight = [formatter numberFromString:stringWt];
    [formatter release];
    
    return weight;
}

//Enning Tang 3/20/2013 call for close order
-(void) closeOrderByOrderId:(SessionInfo *)sessionInfo orderId:(NSString *)orderId{
    
    NSLog(@"close order called");
    // Make sure that we have a valid session and order
    
    if (sessionInfo == nil) {
        NSLog(@"session is null");
    }
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"closeOrderByOrderId"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<OrderId>%@</OrderId>", orderId]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        
        for (Error *error in requestErrors) {
            
        }
        
        //return;
    }
    
    NSString *resp = [request responseString];
    NSLog(@"Close Order resp string: %@", resp);
    
}
//===============================================================

#pragma mark -
#pragma mark Transaction Lock
//Enning Tang Transaction Lock 3/21/2013
- (NSArray *) transactionLockCheck:(NSString *)orderId withSession:(SessionInfo *)sessionInfo {
    
    NSArray *lock = [[NSArray alloc]init];
    NSLog(@"transactionLockCheck called");
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"storelookupbysalesperson"];
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<orderID>%@</orderID>", orderId]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"transactionLockCheck request error");
        return lock;
    }
    
    // Create an XML document parser

    NSString *resp = [request responseString];
    NSLog(@"Response String: %@", resp);
    resp = [resp stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    resp = [resp stringByReplacingOccurrencesOfString:@"||</string>" withString:@""];
    lock = [resp componentsSeparatedByString:@"||"];
    
    //for(NSString *currentNumberString in stores) {
    //  NSLog(@"Number: %@", currentNumberString);
    //}
    NSLog(@"length %@", [NSString stringWithFormat:@"%d", [lock count]]);

    return lock;
}

- (NSString *) setTransactionLock:(NSString *)orderId salesPersonId:(NSString *)salesPersonId storeId:(NSString *)storeId sysUserId:(NSString *)sysUserId salesPersonName:(NSString *)salesPersonName dateLogin:(NSString *)dateLogin withSession:(SessionInfo *)sessionInfo {
    NSString *res = @"";
    
    NSLog(@"setTransactionLock called");
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"storelookupbysalesperson"];
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<orderID>%@</orderID><salesPersonId>%@</salesPersonId><storeId>%@</storeId><sysUserId>%@</sysUserId><salesPersonName>%@</salesPersonName><dateLogin>%@</dateLogin>", orderId, salesPersonId, storeId, sysUserId, salesPersonName, dateLogin]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"setTransactionLock request error");
        return res;
    }
    
    // Create an XML document parser
    
    NSString *resp = [request responseString];
    NSLog(@"Response String: %@", resp);
    res = [resp stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    res = [resp stringByReplacingOccurrencesOfString:@"||</string>" withString:@""];
    return res;
}

- (NSString *) releaseTransactionLock:(NSString *)orderId withSession:(SessionInfo *)sessionInfo {
    NSString *res = @"";
    NSLog(@"releaseTransactionLock called");
    
    ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"storelookupbysalesperson"];
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<orderID>%@</orderID>", orderId]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"releaseTransactionLock request error");
        return res;
    }
    
    // Create an XML document parser
    
    NSString *resp = [request responseString];
    NSLog(@"Response String: %@", resp);
    res = [resp stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">" withString:@""];
    res = [resp stringByReplacingOccurrencesOfString:@"||</string>" withString:@""];
    
    //for(NSString *currentNumberString in stores) {
    //  NSLog(@"Number: %@", currentNumberString);
    //}
    return  res;
}

//============================================================
- (BOOL)insertOtherPayment:(Order *)order amountPayment:(NSDecimalNumber *)amountPayment paymentType:(NSString *)paymentType withSession:(SessionInfo *)sessionInfo
{
    BOOL result = YES;
    NSLog(@"InsertOtherPayment called");
    // Make sure that we have a valid session and order
    
    if (sessionInfo == nil) {
        NSLog(@"session is null");
    }
    
    //ASIHTTPRequest *request = [self getRequestForSession:sessionInfo serviceDomainUri:posOrderMgmtUri serviceUri:@"InsertOtherPayment"];
    NSString *reqURL = [NSString stringWithFormat:@"%@/%@/InsertOtherPayment/%@/%@/%@/%@/%@/%@", baseUrl, posOrderMgmtUri, order.orderId.stringValue, order.store.storeId.stringValue, order.customer.customerId.stringValue, amountPayment.stringValue, order.salesPersonEmployeeId.stringValue, paymentType];
    
    ASIHTTPRequest *request =  [self startGetRequest:[NSString stringWithFormat:@"%@/%@/InsertOtherPayment/%@/%@/%@/%@/%@/%@", baseUrl, posOrderMgmtUri, order.orderId.stringValue, order.store.storeId.stringValue, order.customer.customerId.stringValue, amountPayment.stringValue, order.salesPersonEmployeeId.stringValue, paymentType] withSession:sessionInfo];
    
    NSLog(@"REQ URL: %@", reqURL);
    
    NSArray *requestErrors = [request validateAsXmlContent];
    
    if ([requestErrors count] > 0) {
        
        for (Error *error in requestErrors) {
            
        }
        
        //return;
        result = NO;
    }
    // Create an XML document parser
    
    NSString *resp = [request responseString];
    NSLog(@"InsertOtherPayment resp string: %@", resp);
    return result;
}




#pragma mark -
#pragma mark Private Methods
- (ASIHTTPRequest *) startGetRequest: (NSString *) urlString withSession: (SessionInfo *) sessionInfo {
    // Make Synchronous HTTP request
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:10];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    
    [request startSynchronous];
    
    return request;
}


@end
