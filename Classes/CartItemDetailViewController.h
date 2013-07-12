//
//  CartItemDetailViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OrderCart.h"
#import "OrderItem.h"
#import "MOGlassButton.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "AddItemView.h"

@interface CartItemDetailViewController : ExtUIViewController <ExtUIViewControllerDelegate, AddItemViewDelegate> {
	OrderCart *orderCart;
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
    //Enning Tang Add ship Button
    MOGlassButton *shipButton;
    
    MOGlassButton *inventoryButton;
    // Not used yet.  SMM
    // MOGlassButton *returnButton;
	
	NSNumberFormatter *quantityFormatter;
	
    AddItemView *addItemOverlay;
}

// Use assign instead of retain because the order items are kept in a singleton.
@property (nonatomic, assign) OrderItem *orderItem;

- (id)initWithOrderItem:(OrderItem *)editOrderItem;

@end
