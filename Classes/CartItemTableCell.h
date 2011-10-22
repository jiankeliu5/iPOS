//
//  CartItemTableCell.h
//  iPOS
//
//  Created by Steven McCoole on 3/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderItem.h"
#import "ProductItem.h"

@class CartItemTableCell;

@protocol CartItemCellDelegate

- (void) cartItemCell:(CartItemTableCell *)aCartItemCell markForDelete:(BOOL)shouldDelete;
- (void) cartItemCell:(CartItemTableCell *)aCartItemCell markForClose:(BOOL)shouldClose;

@end

@interface CartItemTableCell : UITableViewCell {
	OrderItem *orderItem;
	NSObject <CartItemCellDelegate>* cellDelegate;
	
	UILabel *descriptionLabel;
    UILabel *itemStatusLabel;
	UILabel *quantityLabel;
	UILabel *lineCostLabel;
	BOOL deleteChecked;
	BOOL closeChecked;
	BOOL multiEditing;
	BOOL disabledLook;
    
	UIButton *deleteCheckButton;
	UIButton *closeCheckButton;
}

// Use assign instead of retain because the order items are kept
// in a singleton.
@property (nonatomic, assign) OrderItem *orderItem;
@property (nonatomic, assign) NSObject<CartItemCellDelegate>* cellDelegate;

@property (nonatomic, assign) BOOL deleteChecked;
@property (nonatomic, assign) BOOL closeChecked;
@property (nonatomic, assign) BOOL multiEditing;
@property (nonatomic, assign) BOOL disabledLook;

- (void) checkDeleteAction:(id)sender;
- (void) checkCloseAction:(id)sender;

@end
