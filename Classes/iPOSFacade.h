//
//  iPOSFacade.h
//  iPOS

//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSServiceImpl.h"
#import "InventoryServiceImpl.h"
#import "PaymentServiceImpl.h"
#import "OrderHistoryService.h"

typedef enum { SessionOk = 0,
			   SessionBadPassword = 1,
			   SessionExpired = 2 } SessionStatus;

@interface iPOSFacade : NSObject {
    id<iPOSService> posService;
    id<InventoryService> inventoryService;
    id<PaymentService> paymentService;
    id<OrderHistoryServiceProtocol> orderHistoryService;
    
    SessionInfo * sessionInfo;
}

@property (nonatomic, retain) id<iPOSService> posService;
@property (nonatomic, retain) id<InventoryService> inventoryService;
@property (nonatomic, retain) id<PaymentService> paymentService;
@property (nonatomic, retain) id<OrderHistoryServiceProtocol> orderHistoryService;

@property (assign) SessionInfo *sessionInfo;

#pragma mark Shared Instance
+ (iPOSFacade *) sharedInstance;

#pragma mark iPOS Session Mgmt
- (BOOL) login: (NSString *) username password: (NSString *) password;
- (SessionStatus) verifySession: (NSString *) passwordToVerify;
- (BOOL) logout;

#pragma mark iPOS Customer Management
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber;
-(void) newCustomer: (Customer *) customer;
-(void) updateCustomer: (Customer *) customer;

#pragma mark iPOS Order Management
-(void) newQuote: (Order *) order;
-(void) newOrder: (Order *) order;
// -(void) updateOrder: (Order *) order;

- (BOOL) emailReceipt: (Order *) order;


#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku;
- (NSArray *) lookupProductItemByName:(NSString *) itemName;

-(BOOL) isProductItemAvailable: (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity;

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withCustomer: (Customer *) customer;
- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover;

#pragma mark -
#pragma mark Payment Management
-(void) tenderPaymentWithCC: (CreditCardPayment *) ccPayment;
-(BOOL) acceptSignatureFor: (CreditCardPayment *) ccPayment;
- (BOOL) acceptSignatureOnAccount:(AccountPayment *)payment;
-(void) tenderPaymentOnAccount:(AccountPayment *)accountPayment;

#pragma mark - 
#pragma mark Order History
-(Order *) lookupOrderByOrderId:(NSNumber *) orderId;
-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber;
-(PaymentHistory *) getPaymentHistoryForOrderid: (NSNumber *)orderId;

@end
