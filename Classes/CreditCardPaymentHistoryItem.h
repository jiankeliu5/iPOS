//
//  CreditCardPaymentHistoryItem.h
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaymentHistoryItem.h"

@interface CreditCardPaymentHistoryItem : PaymentHistoryItem
{
    
    NSString *cardNumber;
    NSString *lpToken;
    NSString *tRouteD;
}

@property (nonatomic, retain) NSString *lpToken;
@property (nonatomic, retain) NSString *tRouteD;
@property (nonatomic, retain) NSString *cardNumber;
@end
