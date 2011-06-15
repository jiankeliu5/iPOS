//
//  ItemDetailView.h
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductItem.h"

#import "AvailabilityView.h"
@protocol ItemDetailViewDelegate;

@interface ItemDetailView : UIView {
    id<ItemDetailViewDelegate> delegate;
    
    ProductItem *item;
    
    UILabel *skuLabel;
	UILabel *descriptionLabel;
	UILabel *priceLabel;
    
    UIButton *uomExchangeButton;
    NSInteger nextRotationDegreesForExchangeButton;
	
	AvailabilityView *storeInfoView;
	AvailabilityView *dc1InfoView;
	AvailabilityView *dc2InfoView;
	AvailabilityView *dc3InfoView;
    
    NSNumberFormatter *priceFormatter;
    
}

@property (nonatomic, assign) id<ItemDetailViewDelegate> delegate;
@property (nonatomic, assign) ProductItem *item;
@property (nonatomic, assign) NSInteger nextRotationDegreesForExchangeButton;

@end

@protocol ItemDetailViewDelegate <NSObject>

- (void) unitOfMeasureExchange: (ItemDetailView *) itemDetailView selectedUOM: (NSString *) uom;

@end
