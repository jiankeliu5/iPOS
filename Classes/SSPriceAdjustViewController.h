//
//  SSPriceAdjustViewController.h
//  iPOS
//
//  Created by Enning Tang on 8/9/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "iPOSFacade.h"
#import "SSOrderCart.h"
#import "OrderItem.h"
#import "LineView.h"
#import "MOGlassButton.h"


@interface SSPriceAdjustViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
    iPOSFacade *facade;
    SSOrderCart *orderCart;
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
