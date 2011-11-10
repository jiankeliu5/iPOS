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

@synthesize orderId;
@synthesize customerId;
@synthesize storeId;
@synthesize salesPersonId;
@synthesize refundDate;
@synthesize refundItems;
@synthesize signature;

- (id)init {
    self = [super init];
    if (self) {
        refundItems = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) dealloc {
    [orderId release];
    orderId = nil;
    [customerId release];
    customerId = nil;
    [storeId release];
    storeId = nil;
    [salesPersonId release];
    salesPersonId = nil;
    [refundDate release];
    refundDate = nil;
    [refundItems release];
    refundItems = nil;
    [signature release];
    signature = nil;
    
    [super dealloc];
}
- (void) addRefundItem:(RefundItem *)item {
    
    [refundItems addObject:item];
}

- (NSArray *) getRefundItems{
    return refundItems;
}

- (NSString *) toXml {
    
    RefundXmlMarshaller *xmlMarshaller = [[[RefundXmlMarshaller alloc] init ] autorelease];
    
    return [xmlMarshaller toXml:self];
}

@end
