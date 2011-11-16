//
//  PaymentServiceImpl.m
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "PaymentServiceImpl.h"

#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+Validate.h"

#import "POSOxmUtils.h"

@interface PaymentServiceImpl()

- (BOOL) sendSignatureRequest:(NSString *)signatureXml forPayment:(Payment *) payment withSessionInfo:(SessionInfo *) sessionInfo;
@end

@implementation PaymentServiceImpl

@synthesize baseUrl, posPaymentMgmtUri;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id) init {
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

- (void) dealloc {
    [baseUrl release];
    [posPaymentMgmtUri release];
    
    [super dealloc];
}

-(void) setToDemoMode {
    // For apps you could use [NSBundle mainBundle] to get the main plist, however this does not work with test bundles.
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.demo.baseurl"];    
    self.posPaymentMgmtUri = @"PaymentService";
}

-(void) setToReleaseMode {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    self.baseUrl = (NSString *) [bundle objectForInfoDictionaryKey:@"ipos.service.baseurl"];
    self.posPaymentMgmtUri = @"PaymentService";
}

#pragma mark -
#pragma mark Payment Service Implementations
- (void) tenderPaymentWithCC:(CreditCardPayment *)ccPayment withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil || ccPayment == nil || ![ccPayment validate]) {
        return;
    }
    
    // Send the request to tender payment
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, posPaymentMgmtUri, @"tender"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    
    // Post data for payment
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *paymentXml = [ccPayment toXml];    
    [request appendPostData:[paymentXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    // Post verification and complete request
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out any errors previously set
        [ccPayment removeAllErrors];
        
        Error *paymentError = [[[Error alloc] init] autorelease];
        paymentError.errorId = @"ERR_PAY";
        paymentError.message = [NSString stringWithFormat:@"Could not process payment for order '%@'.", ccPayment.orderId];
        [ccPayment addError:paymentError];
        
        for (Error *error in requestErrors) {
            [ccPayment addError:error];
        }
        
        return;   
    }
    
    
    // Parse the XML response for the order details
    CreditCardPayment *paymentReturned =  [CreditCardPayment fromXml:[request responseString]];
    [ccPayment mergeWith:paymentReturned];
}


- (BOOL) acceptSignatureOnAccount:(AccountPayment *)payment withSession:(SessionInfo *)sessionInfo {
    
     NSString *xml = [payment.signature toXml];
    return [self sendSignatureRequest:xml forPayment:payment withSessionInfo:sessionInfo];
}


- (BOOL) acceptSignatureFor:(CreditCardPayment *)ccPayment withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil || ccPayment == nil || ccPayment.signature == nil || [[ccPayment.signature validate] count] > 0) {
        return NO;
    }
    
    // Send the request to tender payment
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, posPaymentMgmtUri, @"signature"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    
    // Post data for payment
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *signatureXml = [ccPayment.signature toXml];    
    [request appendPostData:[signatureXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    // Post verification and complete request
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out any errors previously set
        [ccPayment removeAllErrors];
        
        for (Error *error in requestErrors) {
            [ccPayment addError:error];
        }
        
        return NO;   
    }    
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    
    // Return result
    return isSuccessful;
}

- (BOOL) sendSignatureRequest:(NSString *)signatureXml forPayment:(Payment *) payment withSessionInfo:(SessionInfo *) sessionInfo {
    
    // Send the request to tender payment
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, posPaymentMgmtUri, @"signature"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    
    // Post data for payment
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
       
    [request appendPostData:[signatureXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    // Post verification and complete request
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out any errors previously set
        [payment removeAllErrors];
        
        for (Error *error in requestErrors) {
            [payment addError:error];
        }
        
        return NO;   
    }    
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    
    // Return result
    return isSuccessful;

}

- (void) tenderPaymentOnAccount:(AccountPayment *)accountPayment withSession:(SessionInfo *)sessionInfo {
    if (sessionInfo == nil || accountPayment == nil) {
        return;
    }
    
    // Send the request to tender payment
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, posPaymentMgmtUri, @"tender"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    
    // Post data for payment
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    NSString *paymentXml = [accountPayment toXml];    
    [request appendPostData:[paymentXml dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    // Post verification and complete request
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out any errors previously set
        [accountPayment removeAllErrors];
        
        Error *paymentError = [[[Error alloc] init] autorelease];
        paymentError.errorId = @"ERR_PAY";
        paymentError.message = [NSString stringWithFormat:@"Could not process payment for order '%@'.", accountPayment.orderId];
        [accountPayment addError:paymentError];
        
        for (Error *error in requestErrors) {
            [accountPayment addError:error];
        }
        
        return;   
    }
    
    // Parse the XML response for the order details
    AccountPayment *paymentReturned =  [AccountPayment fromXml:[request responseString]];
    [accountPayment mergeWith:paymentReturned];
}

- (BOOL) sendRefundRequest:(Refund *)refund withSession:(SessionInfo *)sessionInfo{
    
    // Send the request to tender payment
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", baseUrl, posPaymentMgmtUri, @"refund"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30];
    
    if (sessionInfo && sessionInfo.deviceId) {
        [request addRequestHeader:@"DeviceID" value:sessionInfo.deviceId];
    }
    
    // Make sure the store id and sales person id are set
    refund.storeId = sessionInfo.storeId;
    refund.salesPersonId = sessionInfo.employeeId;
    
    // Post data for payment
    [request addRequestHeader:@"Content-Type" value:@"text/xml"];
    
    [request appendPostData:[[refund toXml] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request startSynchronous];
    
    // Post verification and complete request
    NSArray *requestErrors = [request validateAsXmlContent];
    if ([requestErrors count] > 0) {
        // Clear out any errors previously set
        [refund removeAllErrors];
        
        for (Error *error in requestErrors) {
            [refund addError:error];
        }
        
        return NO;   
    }    
    
    BOOL isSuccessful = [POSOxmUtils isXmlResultTrue:[request responseString]];
    
    // Return result
    return isSuccessful;
}

@end
