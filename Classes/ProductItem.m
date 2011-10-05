//
//  ProductItem.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ProductItem.h"
#import "ProductItemXmlMarshaller.h"
#import "ProductItemListXmlMarshaller.h"

@implementation ProductItem
 
NSString * const UOM_EACH = @"EA";
NSString * const UOM_CARTON = @"CA";
NSString * const UOM_BOX = @"BX";
NSString * const UOM_COVERAGE = @"CV";
NSString * const UOM_LINEARFOOT = @"LF";
NSString * const UOM_QYARD = @"QY";
NSString * const UOM_SET = @"SE";
NSString * const UOM_SQFT = @"SF";

@synthesize itemId, sku, description, vendorName, statusCode, type, typeId;
@synthesize binLocation, stockingCode;
@synthesize selectedUOM, defaultToBox, piecesPerBox, primaryUnitOfMeasure, secondaryUnitOfMeasure, conversion;
@synthesize priceGroupId, retailPricePrimary, retailPriceSecondary, standardCost, taxRate, taxExempt;
@synthesize store, distributionCenterList;
@synthesize locn, lotn,lttr,mcu,nxtr,urrf,openItemStatus, lineState;

#pragma mark Constuctor/Deconstructor
-(id) init {
    self = [super init];
	
    unitOfMeasureLookup = [[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                @"BOX",
                                @"CARTON",
                                @"SQ FT",
                                @"EACH",
                                @"FT",
                                @"QYARD",
                                @"SET",
                                @"SQ FT",
                               nil] forKeys:[NSArray arrayWithObjects:
                                             UOM_BOX,
                                             UOM_CARTON,
                                             UOM_COVERAGE,
                                             UOM_EACH,
                                             UOM_LINEARFOOT,
                                             UOM_QYARD,
                                             UOM_SET,
                                             UOM_SQFT,
                                             nil]] retain];
    
    // Set a default for the selected UOM
    selectedUOM = UOMPrimary;
    
	return self;
}

-(void) dealloc {
	[unitOfMeasureLookup release];
	
    [itemId release];
    [sku release];
    [description release];
    [vendorName release];
    [statusCode release];
    [type release];
    [typeId release];
    
    [binLocation release];
    [stockingCode release];    
    [piecesPerBox release];
    [primaryUnitOfMeasure release];
    [secondaryUnitOfMeasure release];
    [conversion release];
    
    [priceGroupId release];
    [retailPricePrimary release];
    [retailPriceSecondary release];
    [standardCost release];
    [taxRate release];
    
    [store release];
    [distributionCenterList release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
- (BOOL) isUOMConversionRequired {
    if ([primaryUnitOfMeasure isEqualToString:secondaryUnitOfMeasure]) {
        return NO;
    }
    
    return YES;
}
- (void) toggleUOM {
    if (selectedUOM == UOMPrimary) {
        selectedUOM = UOMSecondary;
    } else {
        selectedUOM = UOMPrimary;
    }
}

- (NSString *) getSelectedUOMForDisplay {
    if (selectedUOM == UOMPrimary) {
        return primaryUnitOfMeasure;
    }
    
    return secondaryUnitOfMeasure;
}

- (NSString *) getRetailPriceForDisplay {
    NSDecimalNumber *value = nil;
    if (selectedUOM == UOMPrimary) {
        value = retailPricePrimary;
    } else {
        value = retailPriceSecondary;
    }
    
    return [NSString stringWithFormat:@"%@", value];
}

-(NSString *) unitOfMeasureDisplay:(NSString*)uom {
	return (NSString *)[unitOfMeasureLookup objectForKey:uom];
}

#pragma mark -
#pragma mark Comparison Methods
- (NSComparisonResult)compare:(id)otherObject {
    ProductItem *compareToItem = (ProductItem *) otherObject;
    return [self.description compare:compareToItem.description];
}

#pragma mark -
#pragma mark XML marshalling
+(ProductItem *) fromXml:(NSString *)xmlString {
    ProductItemXmlMarshaller *marshaller = [[[ProductItemXmlMarshaller alloc] init] autorelease];
    return (ProductItem *) [marshaller toObject:xmlString];    
}

+ (NSArray *) listFromXml:(NSString *)xmlString {
    ProductItemListXmlMarshaller *marshaller = [[[ProductItemListXmlMarshaller alloc] init] autorelease];
    return (NSArray *) [marshaller toObject:xmlString];    
}

- (NSString *) toXml {
    ProductItemXmlMarshaller *marshaller = [[[ProductItemXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

@end
