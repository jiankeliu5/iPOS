//
//  PaymentService.h
//  iPOS
//
//  Created by Torey Lomenda on 4/13/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SessionInfo.h"
#import "CreditCardPayment.h"
#import "AccountPayment.h"
#import "CashPayment.h"
#import "CheckPayment.h"
#import "InStoreCreditPayment.h"
#import "GiftCardPayment.h"
#import "GooglePayment.h"
#import "HomeDesignPayment.h"
#import "PayPalPayment.h"

#import "Refund.h"

@protocol PaymentService <NSObject>

@required
-(BOOL) tenderPaymentWithCC: (CreditCardPayment *) ccPayment withSession: (SessionInfo *) sessionInfo;
- (void) tenderPaymentOnAccount:(AccountPayment *)accountPayment withSession:(SessionInfo *)sessionInfo;

-(BOOL) acceptSignatureFor: (CreditCardPayment *) ccPayment withSession: (SessionInfo *) sessionInfo;
- (BOOL) acceptSignatureOnAccount:(AccountPayment *)payment withSession:(SessionInfo *)sessionInfo;
- (BOOL) sendRefundRequest:(Refund *)refund withSession:(SessionInfo *)sessionInfo;

@end
