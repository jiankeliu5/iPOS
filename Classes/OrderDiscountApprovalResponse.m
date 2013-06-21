//
//  OrderDiscountApprovalResponse.m
//  iPOS
//
//  Created by Torey Lomenda on 11/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "OrderDiscountApprovalResponse.h"
#import "OrderDiscountApprovalXmlMarshaller.h"

@implementation OrderDiscountApprovalResponse
@synthesize itemSellingPriceApprovalList;

#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void) dealloc {
    [itemSellingPriceApprovalList release];
    itemSellingPriceApprovalList = nil;
    
    [super dealloc];
}

#pragma mark -
-(BOOL) isApproved {
    BOOL isApproved = YES;
    
    if (itemSellingPriceApprovalList && [itemSellingPriceApprovalList count] > 0) {
        for (ItemSellingPriceApprovalResponse *approval in itemSellingPriceApprovalList) {
            if (!approval.isApproved) {
                isApproved = NO;
                break;
            }
        }
    } else {
        isApproved = NO;
    }
    
    return isApproved;
}

#pragma mark -
#pragma mark XML Marshalling
+ (OrderDiscountApprovalResponse *) fromXml:(NSString *)xmlString {
    OrderDiscountApprovalXmlMarshaller *marshaller = [[[OrderDiscountApprovalXmlMarshaller alloc] init] autorelease];
    
    return [marshaller toObject:xmlString];
}

@end
