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

@synthesize posService, inventoryService, paymentService, sessionInfo;

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
    
    return self;
}

-(void) dealloc {
    [posService release];
    [inventoryService release];
    [paymentService release];
    [sessionInfo release];
    
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
	[self.sessionInfo release];
	self.sessionInfo = nil;
    return logoutStatus;
}


#pragma mark -
#pragma mark Customer Management
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
-(void) newQuote:(Order *)order {
    [self.posService newQuote:order withSession:sessionInfo];
}

-(void) newOrder:(Order *)order {
    [self.posService newOrder:order withSession:sessionInfo];
}

- (BOOL) emailReceipt:(Order *)order {
    return [self.posService emailReceipt:order withSession:sessionInfo];
}

#pragma mark -
#pragma mark Inventory Management
-(ProductItem *) lookupProductItem:(NSString *) itemSku {
    return [self.inventoryService lookupProductItem:itemSku withSession:sessionInfo];
}

- (NSArray *) lookupProductItemByName:(NSString *)itemName {
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
#pragma mark Payment Management
- (void) tenderPaymentWithCC:(CreditCardPayment *)ccPayment {
    [self.paymentService tenderPaymentWithCC:ccPayment withSession:sessionInfo];
}

- (BOOL) acceptSignatureFor:(CreditCardPayment *)ccPayment {
    return [self.paymentService acceptSignatureFor:ccPayment withSession:sessionInfo];
}

- (void) tenderPaymentOnAccount:(AccountPayment *)accountPayment {
    [self.paymentService tenderPaymentOnAccount:accountPayment withSession:sessionInfo];
}

@end
