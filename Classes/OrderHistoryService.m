//
//  OrderHistoryService.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderHistoryService.h"
#import "ASIHTTPRequest.h"

#import "ASIHTTPRequest+Validate.h"

#import "OrderSummaryXmlMarshaller.h"
#import "OrderXmlMarshaller.h"
#import "PaymentHistoryXMLMarshaller.h"
#import "iPOSFacade.h"
#import "OrderCart.h"

@interface OrderHistoryService()
- (NSString *) escapeXMLForParsing: (NSString *) xmlString;

-(void) setToDemoMode;
-(void) setToReleaseMode;
    

@end

@implementation OrderHistoryService

@synthesize baseUrl, orderHistoryUri;

- (id)init
{
    self = [super init];
    if (self) {
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

    }
    
    return self;
}

-(void) setToDemoMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];    
    self.orderHistoryUri = @"OrderService";
}

-(void) setToReleaseMode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.orderHistoryUri = @"OrderService";
}


-(Order *) lookupOrderByOrderId:(NSString *) orderId withSessionInfo: (SessionInfo *) sessionInfo {
    
    NSLog(@"Lookup orders called");
    if (sessionInfo == nil) {
        NSLog(@"Session is null");
        return nil;
    }
    //Enning Tang 3/22/2013 transactionLock
    /*
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    OrderCart *orderCart = [OrderCart sharedInstance];
    NSArray *lock = [facade transactionLockCheck:orderId];
    NSString *getOrderId = [lock objectAtIndex:0];
    if (![getOrderId isEqualToString:@"0"]) //if order has been locked.
    {
        NSString *getSalesPersonId = [lock objectAtIndex:1];
        NSString *getStoreId = [lock objectAtIndex:2];
        NSString *getSysUserId = [lock objectAtIndex:3];
        NSString *getSalesPersonName = [lock objectAtIndex:4];
        NSString *getdateLogin = [lock objectAtIndex:5];
        NSString *lockMessage = [NSString stringWithFormat:@"This order has been locked by %@(%@) from store %@ (%@) at %@, please contact the sales person to finish this order.", getSalesPersonName, getSalesPersonId, getStoreId, getSysUserId, getdateLogin];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Order has been locked" message:lockMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return nil;
    }else //release previous order lock and set new order lock
    {
        NSString *previousOrderId = [orderCart getOrder].orderId.stringValue;
        NSDate *currdate = [NSDate date];
        NSString *currDateString = [NSString stringWithFormat:@"%@",currdate];
        [facade releaseTransactionLock:previousOrderId];
        [facade setTransactionLock:orderId salesPersonId:facade.sessionInfo.employeeId.stringValue storeId:facade.sessionInfo.storeId.stringValue sysUserId:[NSString stringWithFormat:@"IPOS%@", facade.sessionInfo.storeId.stringValue] salesPersonName:facade.sessionInfo.loginUserName dateLogin:currDateString];
    }*/
    //===========================================
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", baseUrl, orderHistoryUri, orderId, sessionInfo.storeId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    //NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<Salesperson>%@</Salesperson>", orderId]];
    //[request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSLog(@"request method: %@", [request responseString]);
    
    [request startSynchronous];
    
    NSLog(@"order select by order id response string: %@", [request responseString]);
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        NSLog(@"Error");
        return nil;   
    } 
    
    //NSLog(@"order select by order id response string: %@", [request responseString]);
    
    Order * order = [[[[OrderXmlMarshaller alloc] init] autorelease] toObject:[request responseString]];
    
    return order;
}

-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber withSessionInfo:(SessionInfo *) sessionInfo{
    
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/orderlookup", baseUrl, orderHistoryUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<OrderSearch>%@</OrderSearch>", phoneNumber]];    
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSArray *orders = [[[[OrderSummaryXmlMarshaller alloc] init] autorelease] toObject:[request responseString]];
    
    return orders;
}

-(NSArray *) lookupOrderBySalesPersonId:(NSString *)salesPersonId withSessionInfo:(SessionInfo *)sessionInfo{
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/orderlookupbysalesperson", baseUrl, orderHistoryUri]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *requestXml = [self escapeXMLForParsing:[NSString stringWithFormat:@"<OrderSearch>%@</OrderSearch>", salesPersonId]];
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;
    }
    
    NSArray *orders = [[[[OrderSummaryXmlMarshaller alloc] init] autorelease] toObject:[request responseString]];
    
    return orders;
}

-(NSArray *) getPaymentHistoryForOrderid: (NSString *)orderId withSessionInfo:(SessionInfo *) sessionInfo{
    
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/orderpayment/%@", baseUrl, orderHistoryUri, orderId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
       
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    return [[[[PaymentHistoryXMLMarshaller alloc] init] autorelease] toObject:[request responseString]];
}

- (NSString *) escapeXMLForParsing: (NSString *) xmlString {
    
    // Replace any entity reference or XML special characters that could impact parsing
    NSString *escapedString = [xmlString stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    
    return escapedString;
}

@end
