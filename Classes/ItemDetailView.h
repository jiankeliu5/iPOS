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

@interface ItemDetailView : UIView {
    ProductItem *item;
    
    UILabel *skuLabel;
	UILabel *descriptionLabel;
	UILabel *priceLabel;
	
	AvailabilityView *storeInfoView;
	AvailabilityView *dc1InfoView;
	AvailabilityView *dc2InfoView;
	AvailabilityView *dc3InfoView;
    
    NSNumberFormatter *priceFormatter;
    
}

@property (nonatomic, assign) ProductItem *item;

@end
