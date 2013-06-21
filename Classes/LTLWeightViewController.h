//
//  LTLWeightViewController.h
//  iPOS
//
//  Created by Enning Tang on 1/24/13.
//
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "ProfitMarginViewController.h"
#import "OrderCart.h"
#import "AddItemView.h"
#import "ExtUITextField.h"
#import "SearchItemView.h"
#import "CartItemTableCell.h"
#import "LTLTableCell.h"

#import "MOGlassButton.h"


@class LTLWeightViewController;

@protocol LTLWeightViewControllerDelegate

-(void) close:(LTLWeightViewController *)LTLView;

@end

@interface LTLWeightViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, CartItemCellDelegate, ProfitMarginViewDelegate> {
	iPOSFacade *facade;
    OrderCart *orderCart;
    
    Linea *linea;
    
    SearchItemView *searchOverlay;
	
	UITableView *orderTable;
	
	UILabel *subTotalLabel;
	UILabel *subTotalValue;
	UILabel *taxLabel;
	UILabel *taxValue;
	UILabel *totalLabel;
	UILabel *totalValue;
	
	UIToolbar *orderToolBar;
    
    MOGlassButton *discountButton;
	
	NSArray *toolbarBasic;
	NSArray *toolbarWithQuoteAndOrder;
	NSArray *toolbarEditMode;
    
    UIButton *commitEditsButton;
	UILabel *markDeleteLabel;
	UILabel *markCloseLabel;
	UIView *editHeaderView;
    
    //UILabel *totalWeight;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
    
    //Enning Tang Add total LTL weight
    NSNumber *totalLTLWeight;
	
}

@property (nonatomic, retain) NSArray *toolbarBasic;
@property (nonatomic, retain) NSArray *toolbarWithQuoteAndOrder;
@property (nonatomic, retain) NSArray *toolbarEditMode;

@property (nonatomic, retain) UIButton *commitEditsButton;
@property (nonatomic, retain) UILabel *markDeleteLabel;
@property (nonatomic, retain) UILabel *markCloseLabel;
@property (nonatomic, retain) UIView *editHeaderView;

@property (nonatomic, assign) BOOL multiEditMode;
@property (nonatomic, assign) NSInteger countMarkDelete;
@property (nonatomic, assign) NSInteger countMarkClose;
@property (nonatomic, retain) NSNumber *totalLTLWeight;

@end
