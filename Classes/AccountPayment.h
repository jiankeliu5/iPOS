//
//  AccountPayment.h
//  iPOS
//
//  Created by Dan C on 9/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Payment.h"

@interface AccountPayment : Payment


#pragma mark -
#pragma mark Marshalling methods
+ (AccountPayment *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

- (void) mergeWith: (AccountPayment *) mergePayment;
@end
