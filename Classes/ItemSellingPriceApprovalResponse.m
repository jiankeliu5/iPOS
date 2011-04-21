//
//  ItemSellingPriceApprovalResponse.m
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemSellingPriceApprovalResponse.h"
#import "ItemSellingPriceApprovalMarshaller.h"


@implementation ItemSellingPriceApprovalResponse

@synthesize authorizationId, isApproved;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id) init {
    self = [super init];
    
    return self;
}

- (void) dealloc {
    [authorizationId release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Marshalling Methods
+ (ItemSellingPriceApprovalResponse *) fromXml:(NSString *)xmlString {
    ItemSellingPriceApprovalMarshaller *marshaller = [[[ItemSellingPriceApprovalMarshaller alloc] init] autorelease];
    return (ItemSellingPriceApprovalResponse *) [marshaller toObject:xmlString];
}
@end
