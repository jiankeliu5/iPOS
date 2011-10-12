//
//  CartItemsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "ProfitMarginViewController.h"
#import "OrderCart.h"
#import "AddItemView.h"
#import "ExtUITextField.h"
#import "SearchItemView.h"
#import "CartItemTableCell.h"


@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SearchItemViewDelegate, CartItemCellDelegate, ProfitMarginViewDelegate> {
	iPOSFacade *facade;
    OrderCart *orderCart;
    
    Linea *linea;
	
	UILabel *custPhoneLabel;
	UILabel *custNameLabel;
	UILabel *custZipLabel;
	
	UITableView *orderTable;
	
	UILabel *subTotalLabel;
	UILabel *subTotalValue;
	UILabel *taxLabel;
	UILabel *taxValue;
	UILabel *totalLabel;
	UILabel *totalValue;
	
	UIToolbar *orderToolBar;
	
	NSArray *toolbarBasic;
	NSArray *toolbarWithQuoteAndOrder;
	NSArray *toolbarEditMode;
    
    UIBarButtonItem *searchButton;
    UIBarButtonItem *custButton;
    UIBarButtonItem *quoteButton;
    UIBarButtonItem *orderButton;
    UIBarButtonItem *marginButton;
    UIBarButtonItem *logoutButton;
    UIBarButtonItem *editButton;
    UIBarButtonItem *cancelEditButton;
    
    UIButton *commitEditsButton;
	UILabel *markDeleteLabel;
	UILabel *markCloseLabel;
	UIView *editHeaderView;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
    
    // If this is true work with the new order in the cart
    // otherwise look for a previous order in the cart to 
    // work with.
    BOOL newOrderMode;
	
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

@property (nonatomic, assign) BOOL newOrderMode;

@end
