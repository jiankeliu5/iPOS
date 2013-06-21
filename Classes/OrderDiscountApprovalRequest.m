//
//  OrderDiscountApprovalRequest.m
//  iPOS
//
//  Created by Torey Lomenda on 11/17/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "OrderDiscountApprovalRequest.h"
#import "OrderDiscountApprovalXmlMarshaller.h"

@implementation OrderDiscountApprovalRequest

@synthesize itemId;
@synthesize priceGroupId;
@synthesize discountAmount;
@synthesize managerInfo;
@synthesize itemSellingApprovalList;

#pragma mark -
#pragma mark init/dealloc
- (id) initWithOrder:(Order *)order managerInfo:(ManagerInfo *)theManagerInfo withOrderDiscount:(NSDecimalNumber *)discount {
    
    self = [super init];
    
    if (self) {
        if (theManagerInfo) {
            managerInfo = [theManagerInfo retain];
        }
        
        discountAmount = [discount retain];
        
        // Initialize the fields
        if (order) {
            NSArray *openOrderItems = [order getOrderItems:LINE_ORDERSTATUS_OPEN];
            
            if (openOrderItems && [openOrderItems count] > 0) {
                NSMutableArray *tempApprovalList = [NSMutableArray arrayWithCapacity:[openOrderItems count]];
                ItemSellingPriceApprovalRequest *sellingPriceApproval = nil;
                
                // Distribute the discount amount evenly across order items
                NSLog(@"1");
                NSDecimalNumber *discountPercent = [discountAmount decimalNumberByDividingBy:[order calcOpenItemsSubTotal]];
                NSDecimalNumber *discountPerItem = nil;
                
                for (OrderItem *item in openOrderItems) {
                    discountPerItem = [[item calcLineSubTotal] decimalNumberByMultiplyingBy:discountPercent];
                    
                    sellingPriceApproval = [[ItemSellingPriceApprovalRequest alloc] initWithOrderItem:item managerInfo:nil];
                    sellingPriceApproval.sellingPrice = [item calcSellingPricePrimaryFrom:discountPerItem];
                    
                    [tempApprovalList addObject:sellingPriceApproval];
                    
                    [sellingPriceApproval release];
                    
                    sellingPriceApproval = nil;
                    discountPerItem = nil;
                }
                
                self.itemSellingApprovalList = [NSArray arrayWithArray:tempApprovalList];
            }
        }
    }

    return self;
}

- (void) dealloc {
    [itemId release];
    itemId = nil;
    [priceGroupId release];
    priceGroupId = nil;
    [discountAmount release];
    discountAmount = nil;
    [managerInfo release];
    managerInfo = nil;
    
    [super dealloc];
}

#pragma mark -
- (NSDecimalNumber *) getDiscountPerItem {
    NSDecimalNumber *divideByNum = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%u", [itemSellingApprovalList count]]];
    NSDecimalNumber *discountPerItem = [discountAmount decimalNumberByDividingBy:divideByNum];
    
    return discountPerItem;
}

#pragma mark - 
#pragma mark XML Marshalling
- (NSString *) toXml {
    OrderDiscountApprovalXmlMarshaller *marshaller = [[[OrderDiscountApprovalXmlMarshaller alloc] init] autorelease];
    
    return [marshaller toXml:self];
}
@end
