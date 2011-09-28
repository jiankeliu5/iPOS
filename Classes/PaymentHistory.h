//
//  PaymentHistory.h
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreditCardPaymentHistoryItem.h"
#import "AccountPaymentHistoryItem.h"

@interface PaymentHistory : NSObject
{
    CreditCardPaymentHistoryItem *creditCardPayment;
    AccountPaymentHistoryItem *accountPayment;
}

@property(nonatomic, retain) CreditCardPaymentHistoryItem *creditCardPayment;
@property(nonatomic, retain) AccountPaymentHistoryItem *accountPayment;

@end
