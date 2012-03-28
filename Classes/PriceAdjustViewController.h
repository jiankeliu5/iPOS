//
//  PriceAdjustViewController.h
//  iPOS
//
//  Created by Steven McCoole on 4/14/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "iPOSFacade.h"
#import "OrderCart.h"
#import "OrderItem.h"
#import "LineView.h"
#import "MOGlassButton.h"


@interface PriceAdjustViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
	OrderItem *orderItem;
	
	NSNumberFormatter *discountFormatter;
	
	UIView *roundView;
	UILabel *retailTotalLabel;
	UILabel *retailTotalValueLabel;
	UILabel *sellingTotalLabel;
	UILabel *sellingTotalValueLabel;
	UILabel *discountLabel;
	ExtUITextField *discountField;
	LineView *lineView;
	UILabel *mgrIdLabel;
	ExtUITextField *mgrIdField;
	UILabel *mgrPasswordLabel;
	ExtUITextField *mgrPasswordField;
	MOGlassButton *submitButton;
	
}
// Use assign instead of retain since order items are kept in a singleton.
@property (nonatomic, assign) Order *order;
@property (nonatomic, assign) OrderItem *orderItem;

// The price adjustment is either going to be for a single item or the full order
- (id)initWithOrderItem:(OrderItem *)adjustOrderItem;

- (id) initWithOrder: (Order *) adjustedOrder;

@end
