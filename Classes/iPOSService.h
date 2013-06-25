//
//  POSService.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "SessionInfo.h"
#import "Order.h"
#import "Customer.h"
#import "ManagerInfo.h"
#import "SelectionSheet.h"
#import "Project.h"

@protocol iPOSService <NSObject>

#pragma mark iPOS Session Management
@required 
-(SessionInfo *) login: (NSString *) employeeNumber withPassword: (NSString *) password;
-(BOOL) verifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password;
-(BOOL) logout: (SessionInfo *) sessionInfo;

#pragma mark SS Session Management
@required 
-(SessionInfo *) sslogin: (NSString *) employeeNumber withPassword: (NSString *) password;
-(BOOL) ssverifySession: (SessionInfo *) sessionInfo withPassword: (NSString *) password;
-(BOOL) sslogout: (SessionInfo *) sessionInfo;

#pragma mark iPOS Customer Management
@required
-(NSArray *) lookupCustomerByName: (NSString *) customerName withSession: (SessionInfo *) sessionInfo;
-(NSArray *) lookupCustomerByEmail: (NSString *) customerEmail withSession: (SessionInfo *) sessionInfo;
-(Customer *) lookupCustomerByPhone: (NSString *) phoneNumber withSession: (SessionInfo *) sessionInfo;
-(void) newCustomer: (Customer *) customer withSession: (SessionInfo *) sessionInfo;
-(void) updateCustomer: (Customer *) customer withSession: (SessionInfo *) sessionInfo;

#pragma mark iPOS Order Management
@required
- (void) save: (Order *) order withSession: (SessionInfo *) sessionInfo;
- (NSArray *) storelookup: (SessionInfo *) sessionInfo;
- (NSString *) storelookupbysalesperson: (SessionInfo *) sessionInfo salesperson:(NSString *) salesperson;
- (NSDecimalNumber *) taxratelookupbystoreid:(SessionInfo *)sessionInfo shiptostoreid:(NSString *)shiptostoreid;
//Enning Tang Added close order 3/20/2013
- (void) closeOrderByOrderId:(SessionInfo *)sessionInfo orderId:(NSString *)orderId;
- (BOOL) orderDiscountFor: (Order *) order withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover withSession: (SessionInfo *) sessionInfo;

#pragma mark transaction Lock Check Enning Tang 3/21/2013
- (NSArray *) transactionLockCheck: (NSString *) orderId withSession: (SessionInfo *) sessionInfo;
- (NSString *) setTransactionLock:(NSString *)orderId salesPersonId:(NSString *)salesPersonId storeId:(NSString *)storeId sysUserId:(NSString *)sysUserId salesPersonName:(NSString *)salesPersonName dateLogin:(NSString *)dateLogin withSession:(SessionInfo *)sessionInfo;
- (NSString *) releaseTransactionLock:(NSString *)orderId withSession:(SessionInfo *)sessionInfo;

-(BOOL)insertOtherPayment:(Order *) order amountPayment:(NSDecimalNumber *)amountPayment paymentType:(NSString *)paymentType withSession:(SessionInfo *)sessionInfo;

#pragma mark iPOS Report Management
- (BOOL) emailReceipt: (Order *) order withSession: (SessionInfo *) sessionInfo;
- (BOOL) emailReceiptWithEmail:(Order *)order withEmail:(NSString *)emailAddress withSession:(SessionInfo *)sessionInfo;

#pragma mark selSheet Services
-(NSArray *) lookupRoomsWithSession: (SessionInfo *) sessionInfo;
-(NSArray *) lookupAreasWithSession: (SessionInfo *) sessionInfo;
//- (BOOL) emailSelSheet: (SelectionSheet *) sheet withSession: (SessionInfo *) sessionInfo;

-(ProductItem *) lookupProductItem: (NSString *) itemSku withSession:  (SessionInfo *) sessionInfo;

-(ProductItem *) lookupProductItemByStore: (NSString *) itemSku withStoreid: (NSString *) StoreID withSession:  (SessionInfo *) sessionInfo;

- (NSArray *) lookupProductItemByName: (NSString *) itemName withSession: (SessionInfo *) sessionInfo;

-(NSArray *) lookupSheetByProduct:(NSString *) product andCustomer:(NSString *) customer andContractor:(NSString *) contractor andArchived:(Boolean) archived withSession:(SessionInfo *) sessionInfo;
-(NSString *) lookupSelection:(NSString *) productUID withSession:(SessionInfo *) sessionInfo;
-(SelectionSheet *)lookupSheetById:(NSString *) sheetId withSession:(SessionInfo *) sessionInfo;
-(NSNumber *) getLTLWeight:(NSNumber *)ItemID withQuantity:(NSNumber *)Quantity withSession:  (SessionInfo *) sessionInfo;


#pragma mark -
#pragma mark Payment Processing

@end
