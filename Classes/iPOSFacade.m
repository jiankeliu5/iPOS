//
//  iPOSFacade.m
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "iPOSFacade.h"
#import "AccountPayment.h"


@implementation iPOSFacade

static iPOSFacade *facade = nil;

@synthesize posService, inventoryService, paymentService, sessionInfo, sssessionInfo, orderHistoryService;

#pragma mark Singleton Initializer
+ (iPOSFacade *) sharedInstance {
    if (facade == nil) {
        facade = [[super allocWithZone:nil] init];
    } 
    
    return facade;
    
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

#pragma mark Constructor/Destructor
-(id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    posService = [[iPOSServiceImpl alloc] init];
    inventoryService = [[InventoryServiceImpl alloc] init];    
    paymentService = [[PaymentServiceImpl alloc] init];
    orderHistoryService = [[OrderHistoryService alloc] init];
    
    return self;
}

-(void) dealloc {
    [posService release];
    [inventoryService release];
    [paymentService release];
    [sessionInfo release];
    [sssessionInfo release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark iPOS Session Mgmt
- (BOOL) login: (NSString *) username password: (NSString *) password {
    sessionInfo = [[self.posService login:username withPassword:password] retain];
    
    if (sessionInfo != nil) {
        return TRUE;
    }
    
	return FALSE;
}

-(SessionStatus) verifySession:(NSString *)passwordToVerify {
	if (passwordToVerify && ![passwordToVerify isEqualToString:self.sessionInfo.passwordForVerification]) {
		return SessionBadPassword;
	}
    return ([self.posService verifySession:sessionInfo withPassword:passwordToVerify]) ? SessionOk : SessionExpired;
}

-(BOOL) logout {
	BOOL logoutStatus = [posService logout:sessionInfo];
	[sessionInfo release];
	sessionInfo = nil;
    return logoutStatus;
}


#pragma mark -
#pragma mark SS Session Mgmt
- (BOOL) sslogin: (NSString *) username password: (NSString *) password {
    sssessionInfo = [[self.posService sslogin:username withPassword:password] retain];
    
    if (sssessionInfo != nil) {
        return TRUE;
    }
    
	return FALSE;
}

-(SessionStatus) ssverifySession:(NSString *)passwordToVerify {
	if (passwordToVerify && ![passwordToVerify isEqualToString:self.sssessionInfo.passwordForVerification]) {
		return SessionBadPassword;
	}
    return ([self.posService ssverifySession:sessionInfo withPassword:passwordToVerify]) ? SessionOk : SessionExpired;
}

-(BOOL) sslogout {
	BOOL logoutStatus = [posService sslogout:sessionInfo];
	[sssessionInfo release];
	sssessionInfo = nil;
    return logoutStatus;
}


#pragma mark -
#pragma mark Customer Management
- (NSArray *) lookupCustomerByName:(NSString *)customerName {
    return [self.posService lookupCustomerByName:customerName withSession:sessionInfo];
}

-(Customer *) lookupCustomerByPhone:(NSString *)phoneNumber {
    return [self.posService lookupCustomerByPhone:phoneNumber withSession:sessionInfo];
}

-(void) newCustomer:(Customer *)customer {
    [self.posService newCustomer:customer withSession:self.sessionInfo];
}

-(void) updateCustomer:(Customer *)customer {
    [self.posService updateCustomer:customer withSession:self.sessionInfo];
}

#pragma mark -
#pragma mark Order Management
-(void) saveSheet:(SelectionSheet *)sheet {
    [self.posService save:sheet withSession:sssessionInfo];
}

-(NSArray *) lookupSheetByProduct:(NSString *) product andCustomer:(NSString *) customer andContractor:(NSString *) contractor andArchived:(Boolean) archived{
    return [self.posService lookupSheetByProduct:product andCustomer:customer andContractor:contractor andArchived:archived withSession:self.sssessionInfo];
}

-(NSString *) lookupSelection:(NSString *) projectUID{
    return [self.posService lookupSelection:projectUID withSession:self.sssessionInfo];
}

-(SelectionSheet *) lookupSheetById:(NSString *) sheetId {
    return [self.posService lookupSheetById:sheetId withSession:self.sssessionInfo];
}


-(NSArray *) lookupRooms {
    return [self.posService lookupRoomsWithSession:self.sssessionInfo];
}
-(NSArray *) lookupAreas {
    return [self.posService lookupAreasWithSession:self.sssessionInfo];
}


#pragma mark -
#pragma mark Order Management
-(void) saveOrder:(Order *)order {
    [self.posService save:order withSession:sessionInfo];
}

-(NSArray *) storelookup{
    return [self.posService storelookup:sessionInfo];
}

-(NSString *) storelookupbysalesperson: (NSString *) salesperson{
    return [self.posService storelookupbysalesperson:sessionInfo salesperson:salesperson];
}

-(NSDecimalNumber *) taxratelookupbystoreid: (NSString *) shiptostoreid{
    return [self.posService taxratelookupbystoreid:sessionInfo shiptostoreid:shiptostoreid];
}

-(void) closeOrderByOrderId:(NSString *) orderId{
    return [self.posService closeOrderByOrderId:sessionInfo orderId:orderId];
}

- (BOOL) emailReceipt:(Order *)order {
    return [self.posService emailReceipt:order withSession:sessionInfo];
}

- (BOOL) emailReceiptWithEmail:(Order *)order withEmail:(NSString *)emailAddress{
    return [self.posService emailReceiptWithEmail:order withEmail:emailAddress withSession:sessionInfo];
}

- (BOOL) orderDiscountFor: (Order *) order withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover {
    return [self.posService orderDiscountFor:order withDiscountAmount:discountAmount managerApproval:managerApprover withSession:sessionInfo];
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku {
    return [self.inventoryService lookupProductItem:itemSku withSession:sessionInfo];
}

- (NSArray *) lookupProductItemByName:(NSString *)itemName {
    //return [self.posService lookupProductItemByName:itemName withSession:sessionInfo];
    return [self.inventoryService lookupProductItemByName:itemName withSession:sessionInfo];
}

-(BOOL) isProductItemAvailable: (NSNumber *) itemId forQuantity: (NSDecimalNumber *) quantity {
    return [self.inventoryService isProductItemAvailable:itemId forQuantity:quantity withSession:sessionInfo];
}

- (BOOL) adjustSellingPriceFor:(OrderItem *)orderItem withCustomer:(Customer *)customer {
    return [self.inventoryService adjustSellingPriceFor:orderItem withCustomer:customer withSession:sessionInfo];
}

- (BOOL) adjustSellingPriceFor: (OrderItem *) orderItem withDiscountAmount: (NSDecimalNumber *) discountAmount managerApproval: (ManagerInfo *) managerApprover {
    return [self.inventoryService adjustSellingPriceFor:orderItem withDiscountAmount:discountAmount managerApproval:managerApprover withSession: sessionInfo];
}

#pragma mark -
#pragma mark Transaction Lock Enning Tang 3/21/2013
- (NSArray *) transactionLockCheck:(NSString *)orderId {
    return [self.posService transactionLockCheck:orderId withSession:sessionInfo];
}

- (NSString *) setTransactionLock:(NSString *)orderId salesPersonId:(NSString *)salesPersonId storeId:(NSString *)storeId sysUserId:(NSString *)sysUserId salesPersonName:(NSString *)salesPersonName dateLogin:(NSString *)dateLogin {
    return [self.posService setTransactionLock:orderId salesPersonId:salesPersonId storeId:storeId sysUserId:sysUserId salesPersonName:salesPersonName dateLogin:dateLogin withSession:sessionInfo];
}

- (NSString *) releaseTransactionLock:(NSString *)orderId {
    return  [self.posService releaseTransactionLock:orderId withSession:sessionInfo];
}

#pragma mark Insert Other Payment Enning Tang 3/28/2013
- (BOOL)insertOtherPayment:(Order *)order amountPayment:(NSDecimalNumber *)amountPayment paymentType:(NSString *)paymentType{
    return [self.posService insertOtherPayment:order amountPayment:amountPayment paymentType:paymentType withSession:sessionInfo];
}

#pragma mark -
#pragma mark Payment Management
- (BOOL) tenderPaymentWithCC:(CreditCardPayment *)ccPayment {
    return [self.paymentService tenderPaymentWithCC:ccPayment withSession:sessionInfo];
}

- (BOOL) acceptSignatureOnAccount:(AccountPayment *)payment {
    return [self.paymentService acceptSignatureOnAccount:payment withSession:sessionInfo];
}

- (BOOL) acceptSignatureFor:(CreditCardPayment *)ccPayment {
    return [self.paymentService acceptSignatureFor:ccPayment withSession:sessionInfo];
}

- (void) tenderPaymentOnAccount:(AccountPayment *)accountPayment {
    [self.paymentService tenderPaymentOnAccount:accountPayment withSession:sessionInfo];
}

#pragma mark -
#pragma mark Order History
-(NSArray *) lookupOrderByPhoneNumber: (NSString *)phoneNumber{
    
    return [self.orderHistoryService lookupOrderByPhoneNumber:phoneNumber withSessionInfo:sessionInfo];
}

//Enning Tang added 5/2/2013
-(NSArray *) lookupOrderBySalesPersonId:(NSString *)salesPersonId{
    return [self.orderHistoryService lookupOrderBySalesPersonId:salesPersonId withSessionInfo:sessionInfo];
}

-(Order *) lookupOrderByOrderId:(NSNumber *) orderId {
    return [self.orderHistoryService lookupOrderByOrderId:[orderId stringValue] withSessionInfo:sessionInfo];
}

-(NSArray *) getPaymentHistoryForOrderid: (NSNumber *)orderId{
    return [self.orderHistoryService getPaymentHistoryForOrderid:[orderId stringValue] withSessionInfo:sessionInfo];
}

-(BOOL) sendRefundRequest:(Refund *)refund{
    return [self.paymentService sendRefundRequest:refund withSession:sessionInfo];
}

-(ProductItem *) lookupProductItemByStore:(NSString *)itemSku withStoreid:(NSString *)StoreID{
    return [self.posService lookupProductItemByStore:itemSku withStoreid:StoreID withSession:sessionInfo];
}

-(NSNumber *) getLTLWeight:(NSNumber *)ItemID withQuantity:(NSNumber *)Quantity{
    return [self.posService getLTLWeight:ItemID withQuantity:Quantity withSession:sessionInfo];
}


@end
