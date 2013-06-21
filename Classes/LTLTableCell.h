//
//  LTLTableCell.h
//  iPOS
//
//  Created by Enning Tang on 1/25/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderItem.h"
#import "ProductItem.h"
#import "iPOSFacade.h"

@class LTLTableCell;

@protocol LTLTableCellDelegate

- (void) LTLTableCell:(LTLTableCell *)aLTLTableCell markForDelete:(BOOL)shouldDelete;
- (void) LTLTableCell:(LTLTableCell *)aLTLTableCell markForClose:(BOOL)shouldClose;

@end

@interface LTLTableCell : UITableViewCell {
    iPOSFacade *facade;
    
	OrderItem *orderItem;
	NSObject <LTLTableCellDelegate>* cellDelegate;
	
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
    
    NSNumber *LTLWeight;
}

// Use assign instead of retain because the order items are kept
// in a singleton.

@property (nonatomic, assign) OrderItem *orderItem;
@property (nonatomic, assign) NSObject<LTLTableCellDelegate>* cellDelegate;


@property (nonatomic, assign) BOOL deleteChecked;
@property (nonatomic, assign) BOOL closeChecked;
@property (nonatomic, assign) BOOL multiEditing;
@property (nonatomic, assign) BOOL disabledLook;

@property (nonatomic, assign) NSNumber *LTLWeight;

- (void) checkDeleteAction:(id)sender;
- (void) checkCloseAction:(id)sender;

@end
