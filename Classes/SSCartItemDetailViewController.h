//
//  SSCartItemDetailViewController.h
//  iPOS
//
//  Created by Enning Tang on 8/8/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SSOrderCart.h"
#import "OrderItem.h"
#import "MOGlassButton.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"

@interface SSCartItemDetailViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
	SSOrderCart *orderCart;
	OrderItem *orderItem;
	
	UIView *productItemView;
    UIButton *uomExchangeButton;
	NSInteger nextRotationDegreesForExchangeButton;
    
    UILabel *skuLabel;
	UILabel *descLabel;
	UILabel *priceLabel;
	
	UIView *orderItemView;
	ExtUITextField *quantityField;
	UILabel *unitOfMeasureLabel;
	UILabel *itemTotalLabel;
    
    UILabel *convertToBoxesLabel;
    UISwitch *convertToBoxesSwitch;
	
	MOGlassButton *deleteButton;
	MOGlassButton *closeLineButton;
    MOGlassButton *openButton;
	MOGlassButton *priceButton;
	
	NSNumberFormatter *quantityFormatter;
	
}

// Use assign instead of retain because the order items are kept in a singleton.
@property (nonatomic, assign) OrderItem *orderItem;

- (id)initWithOrderItem:(OrderItem *)editOrderItem;

@end
