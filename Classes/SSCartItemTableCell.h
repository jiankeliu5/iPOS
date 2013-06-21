//
//  SSCartItemTableCell.h
//  iPOS
//
//  Created by Enning Tang on 8/6/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderItem.h"
#import "ProductItem.h"

@class SSCartItemTableCell;

@protocol SSCartItemCellDelegate

- (void) cartItemCell:(SSCartItemTableCell *)aCartItemCell markForDelete:(BOOL)shouldDelete;
- (void) cartItemCell:(SSCartItemTableCell *)aCartItemCell markForClose:(BOOL)shouldClose;

@end

@interface SSCartItemTableCell : UITableViewCell {
	OrderItem *orderItem;
	NSObject <SSCartItemCellDelegate>* cellDelegate;
	
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
@property (nonatomic, assign) NSObject<SSCartItemCellDelegate>* cellDelegate;


@property (nonatomic, assign) BOOL deleteChecked;
@property (nonatomic, assign) BOOL closeChecked;
@property (nonatomic, assign) BOOL multiEditing;
@property (nonatomic, assign) BOOL disabledLook;

- (void) checkDeleteAction:(id)sender;
- (void) checkCloseAction:(id)sender;

@end
