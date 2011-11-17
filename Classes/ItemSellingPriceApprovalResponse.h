//
//  ItemSellingPriceApprovalResponse.h
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ItemSellingPriceApprovalResponse : NSObject {
    NSNumber *itemId;
    BOOL isApproved;
    NSNumber *authorizationId;
}

@property (nonatomic, retain) NSNumber *itemId;
@property                       BOOL isApproved;
@property (nonatomic, retain)   NSNumber *authorizationId;

#pragma mark -
#pragma mark Marshalling methods
+ (ItemSellingPriceApprovalResponse *) fromXml: (NSString *) xmlString;

@end
