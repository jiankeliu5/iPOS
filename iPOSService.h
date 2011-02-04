//
//  POSService.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

@protocol iPOSService <NSObject>

#pragma mark iPOS Session Management
@required 
- (void) login;
- (void) verifySession;
- (void) logout;

#pragma mark iPOS Customer Management
@required
-(void) lookupCustomer;
-(void) newCustomer;
-(void) updateCustomer;

#pragma mark iPOS Order Management
@required
-(void) newOrder;
-(void) discountItemPrice;
-(void) processPayment;





@end
