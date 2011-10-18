//
//  Refund.m
//  iPOS
//
//  Created by Dan C on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Refund.h"

#import "RefundXmlMarshaller.h"


@implementation Refund

@synthesize refundItems, orderId, customerId, storeId, salesPersonId, refundDate, signature;

- (id)init
{
    self = [super init];
    if (self) {
        refundItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) addRefundItem:(RefundItem *)item{
    
    [refundItems addObject:item];
}

- (NSArray *) getRefundItems{
    return refundItems;
}

- (NSString *) toXml{
    
    RefundXmlMarshaller *xmlMarshaller = [[RefundXmlMarshaller alloc] init ];
    
    return [xmlMarshaller toXml:self];
}

@end
