//
//  ItemSellingPriceApprovalRequest.m
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemSellingPriceApprovalRequest.h"
#import "ItemSellingPriceApprovalMarshaller.h"


@implementation ItemSellingPriceApprovalRequest

@synthesize itemId, priceGroupId, retailPrice, sellingPrice, managerInfo;

#pragma mark -
#pragma mark Constructor/Deconstructor
-(id) initWithOrderItem: (OrderItem *) orderItem managerInfo: (ManagerInfo *) theManagerInfo {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Initialize the fields
    if (orderItem && orderItem.item) {
        itemId = [orderItem.item.itemId retain];
        priceGroupId = [orderItem.item.priceGroupId retain];
        retailPrice = [orderItem.item.retailPricePrimary retain];
        sellingPrice = [orderItem.sellingPricePrimary retain];
    }
    
    if (theManagerInfo) {
        managerInfo = [theManagerInfo retain];
    }
    
    
    return self;
}

- (void) dealloc {
    [itemId release];
    [priceGroupId release];
    [retailPrice release];
    [sellingPrice release];
    [managerInfo release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Marshalling methods
- (NSString *) toXml {
    ItemSellingPriceApprovalMarshaller *marshaller = [[[ItemSellingPriceApprovalMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}
@end
