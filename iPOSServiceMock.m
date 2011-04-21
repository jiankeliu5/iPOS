//
//  iPOSServiceMock.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSServiceMock.h"
#import "Error.h";

@implementation iPOSServiceMock

#pragma mark Constructor/Deconstructor
-(id) init {
    return [super init];
}
-(void) dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Session Mgmt APIs
-(SessionInfo *) login:(NSString *)employeeNumber withPassword:(NSString *)password {
    SessionInfo *session = [[[SessionInfo alloc] init] autorelease];
    
    session.employeeId = [NSNumber numberWithInt:123];
    session.storeId = [NSNumber numberWithInt: 1200];
    session.serverSessionId = @"1234-test-34";
    session.passwordForVerification = [[password copy] autorelease];
    
    return session;
}

-(BOOL) logout:(SessionInfo *)sessionInfo {
    return YES;
}

- (BOOL) verifySession:(SessionInfo *)sessionInfo withPassword: (NSString *) password {

    if (password && [password isEqualToString: sessionInfo.passwordForVerification]) {
        return YES;
    };
    
    return NO;
}

#pragma mark -
#pragma mark Customer Mgmt APIs
-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber withSession:(SessionInfo *)sessionInfo {
    if ([phoneNumber isEqualToString:@"612-807-6120"]) {
        Customer *customer = [[[Customer alloc] init] autorelease];
        
        customer.customerId = [NSNumber numberWithInt:1414];
        customer.customerType = @"Retail";
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
        
        error.message = @"Customer is already created.";
        error.reference = customer;
        
        [errors addObject:error];
        
    } 
    
    if (customer.firstName == nil || customer.lastName == nil || customer.phoneNumber == nil || customer.address == nil || customer.address.zipPostalCode == nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = @"Missing required data.";
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

#pragma mark -
#pragma mark Order Mgmt
- (void) newQuote:(Order *)order withSession:(SessionInfo *)sessionInfo {
    // Do Nothing
}
- (void) newOrder:(Order *)order withSession:(SessionInfo *)sessionInfo {
    // Do Nothing
}
- (void) emailReceipt:(Order *)order withSession:(SessionInfo *)sessionInfo {
    // Do Nothing
}

@end
