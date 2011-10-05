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
#import "OrderHistoryXmlMarshaller.h"
#import "OrderSummaryXmlMarshaller.h"
#import "PaymentHistoryXMLMarshaller.h"

@interface OrderHistoryService()

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
    
    if (sessionInfo == nil) {
        return nil;
    }
    
    // Fetch the list
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, orderHistoryUri, orderId]];
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
    
    Order * order = [[[OrderHistoryXmlMarshaller alloc] init]toObject:[request responseString]];
    
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
    
    NSString *requestXml = [NSString stringWithFormat:@"<OrderSearch>%@</OrderSearch>", phoneNumber];    
    [request appendPostData:[requestXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        return nil;   
    } 
    
    NSArray *orders = [[[OrderSummaryXmlMarshaller alloc] init]toObject:[request responseString]];
    
    return orders;
}

-(PaymentHistory *) getPaymentHistoryForOrderid: (NSString *)orderId withSessionInfo:(SessionInfo *) sessionInfo{
    
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
    
    return [[[PaymentHistoryXMLMarshaller alloc] init] toObject:[request responseString]];
}


@end
