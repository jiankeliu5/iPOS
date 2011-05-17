//
//  ProductItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DistributionCenter.h"
#import "Store.h"

@interface ProductItem : NSObject {
    NSNumber *itemId;
    
    // Basic Info
    NSString *sku;
    NSString *description;
    NSString *vendorName;
    NSString *statusCode;
    NSString *type;
    NSNumber *typeId;
    
    // Stocking Information
    NSString *binLocation;
    NSString *stockingCode;
    
    // Unit of Measure Info
    BOOL defaultToBox;
    NSNumber *piecesPerBox;
    NSString *primaryUnitOfMeasure;
    NSString *secondaryUnitOfMeasure;
    NSDecimalNumber *conversion;
    
    // Pricing Info
    NSNumber *priceGroupId;
    NSDecimalNumber *retailPrice;
    NSDecimalNumber *standardCost;
    NSDecimalNumber *taxRate;
    BOOL taxExempt;     
    
    // Store
    Store *store;
    
    // Distribution Center Info
    NSArray *distributionCenterList;
	
	NSDictionary *unitOfMeasureLookup;
}

@property(nonatomic, retain) NSNumber *itemId;
@property(nonatomic, retain) NSString *sku;
@property(nonatomic, retain) NSString *description;
@property(nonatomic, retain) NSString *vendorName;
@property(nonatomic, retain) NSString *statusCode;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, retain) NSNumber *typeId;
@property(nonatomic, retain) NSString *binLocation;
@property(nonatomic, retain) NSString *stockingCode;
@property                    BOOL defaultToBox;
@property(nonatomic, retain) NSNumber *piecesPerBox;
@property(nonatomic, retain) NSString *primaryUnitOfMeasure;
@property(nonatomic, retain) NSString *secondaryUnitOfMeasure;
@property(nonatomic, retain) NSDecimalNumber *conversion;
@property(nonatomic, retain) NSNumber *priceGroupId;
@property(nonatomic, retain) NSDecimalNumber *retailPrice;
@property(nonatomic, retain) NSDecimalNumber *standardCost;
@property(nonatomic, retain) NSDecimalNumber *taxRate;
@property                    BOOL taxExempt;

@property (nonatomic, retain) Store *store;
@property(nonatomic, retain) NSArray *distributionCenterList;

-(NSString *) unitOfMeasureDisplay:(NSString*)uom;

- (NSComparisonResult)compare:(id)otherObject;

#pragma mark -
#pragma mark Marshalling methods
+ (ProductItem *) fromXml: (NSString *) xmlString;
+ (NSArray *) listFromXml: (NSString *) xmlString;
- (NSString *) toXml;

@end
