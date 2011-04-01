//
//  CartItemDetailViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "OrderItem.h"
#import "MOGlassButton.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"

@interface CartItemDetailViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
	iPOSFacade *facade;
	OrderItem *orderItem;
	
	UIView *productItemView;
	UILabel *skuLabel;
	UILabel *descLabel;
	UILabel *priceLabel;
	
	UIView *orderItemView;
	ExtUITextField *quantityField;
	UILabel *unitOfMeasureLabel;
	UILabel *itemTotalLabel;
	
	MOGlassButton *deleteButton;
	MOGlassButton *closeLineButton;
	MOGlassButton *priceButton;
	
}

@property (nonatomic, retain) OrderItem *orderItem;

- (id)initWithOrderItem:(OrderItem *)editOrderItem;

@end
