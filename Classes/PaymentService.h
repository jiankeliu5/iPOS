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

@protocol PaymentService <NSObject>

@required
-(void) tenderPaymentWithCC: (CreditCardPayment *) ccPayment withSession: (SessionInfo *) sessionInfo;
- (void) tenderPaymentOnAccount:(AccountPayment *)accountPayment withSession:(SessionInfo *)sessionInfo;

-(BOOL) acceptSignatureFor: (CreditCardPayment *) ccPayment withSession: (SessionInfo *) sessionInfo;

@end
