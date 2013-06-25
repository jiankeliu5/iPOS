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
#import "SelectionSheet.h"
#import "Project.h"

typedef enum { SessionOk = 0,
    SessionBadPassword = 1,
    SessionExpired = 2 } SessionStatus;

@interface iPOSFacade : NSObject {
    id<iPOSService> posService;
    id<InventoryService> inventoryService;
    id<PaymentService> paymentService;
    id<OrderHistoryServiceProtocol> orderHistoryService;
    
    SessionInfo * sessionInfo;
    SessionInfo * sssessionInfo;
}

@property (nonatomic, retain) id<iPOSService> posService;
@property (nonatomic, retain) id<InventoryService> inventoryService;
@property (nonatomic, retain) id<PaymentService> paymentService;
@property (nonatomic, retain) id<OrderHistoryServiceProtocol> orderHistoryService;

@property (assign) SessionInfo *sessionInfo;
@property (assign) SessionInfo *sssessionInfo;

#pragma mark Shared Instance
+ (iPOSFacade *) sharedInstance;

#pragma mark iPOS Session Mgmt
- (BOOL) login: (NSString *) username password: (NSString *) password;
- (SessionStatus) verifySession: (NSString *) passwordToVerify;
- (BOOL) logout;

#pragma mark SS Session Mgmt
- (BOOL) sslogin: (NSString *) username password: (NSString *) password;
- (SessionStatus) ssverifySession: (NSString *) passwordToVerify;
- (BOOL) sslogout;

#pragma mark iPOS Customer Management
- (NSArray *) lookupCustomerByName: (NSString *) customerName;
- (NSArray *) lookupCustomerByEmail: (NSString *) customerEmail;
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber;
-(void) newCustomer: (Customer *) customer;
-(void) updateCustomer: (Customer *) customer;

#pragma mark iPOS Sheet Management
-(void) saveSheet: (SelectionSheet *) sheet;

-(NSArray *) lookupSheetByProduct:(NSString *) product andCustomer:(NSString *) customer andContractor:(NSString *) contractor andArchived:(Boolean) archived;

-(NSString *) lookupSelection:(NSString *) projectUID;


-(SelectionSheet *) lookupSheetById:(NSString *) sheetId;

//- (BOOL) emailReceipt: (Order *) order;

//- (BOOL) orderDiscountFor: (Order *) order withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover;

#pragma mark iPOS Order Management
-(void) saveOrder: (Order *) order;
- (BOOL) emailReceipt: (Order *) order;
- (BOOL) emailReceiptWithEmail:(Order *)order withEmail:(NSString *)emailAddress;
-(NSArray *) storelookup;
-(NSString *) storelookupbysalesperson: (NSString *) salesperson;
- (NSDecimalNumber *) taxratelookupbystoreid: (NSString *)shiptostoreid;
//Enning Tang 3/20/2013 added close order
-(void) closeOrderByOrderId:(NSString *)orderId;

-(BOOL) orderDiscountFor: (Order *) order withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover;

#pragma mark Transaction Lock Enning Tang 3/21/2013 
-(NSArray *) transactionLockCheck:(NSString *) orderId;
- (NSString *) setTransactionLock:(NSString *)orderId salesPersonId:(NSString *)salesPersonId storeId:(NSString *)storeId sysUserId:(NSString *)sysUserId salesPersonName:(NSString *)salesPersonName dateLogin:(NSString *)dateLogin;
- (NSString *) releaseTransactionLock:(NSString *)orderId;

#pragma mark Insert Other Payment 3/28/2013
- (BOOL) insertOtherPayment:(Order *) order amountPayment:(NSDecimalNumber *)amountPayment paymentType:(NSString *)paymentType;


#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku;

-(ProductItem *) lookupProductItemByStore: (NSString *) itemSku withStoreid: (NSString *) StoreID;

//Enning Tang 1/28/2013 Get LTL weight
-(NSNumber *) getLTLWeight:(NSNumber *)ItemID withQuantity:(NSNumber *)Quantity;

- (NSArray *) lookupProductItemByName:(NSString *) itemName;

-(BOOL) isProductItemAvailable: (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity;

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withCustomer: (Customer *) customer;
- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover;

#pragma mark -
#pragma mark Payment Management
-(BOOL) tenderPaymentWithCC: (CreditCardPayment *) ccPayment;
-(BOOL) acceptSignatureFor: (CreditCardPayment *) ccPayment;
- (BOOL) acceptSignatureOnAccount:(AccountPayment *)payment;
-(void) tenderPaymentOnAccount:(AccountPayment *)accountPayment;

#pragma mark - 
#pragma mark Order History
-(Order *) lookupOrderByOrderId:(NSNumber *) orderId;
-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber;
-(NSArray *) getPaymentHistoryForOrderid: (NSNumber *)orderId;

//Enning Tang added 5/2/2013
-(NSArray *) lookupOrderBySalesPersonId:(NSString *) salesPersonId;

-(BOOL) sendRefundRequest:(Refund *)refund;

-(NSArray *) lookupRooms;
-(NSArray *) lookupAreas;

@end
