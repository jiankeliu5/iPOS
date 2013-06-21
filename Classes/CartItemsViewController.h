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
#import "ExtUITextField.h"
#import "SearchItemView.h"
#import "CartItemTableCell.h"

#import "MOGlassButton.h"
#import "AddItemView.h"
#import "SpecialItem.h"

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SearchItemViewDelegate, CartItemCellDelegate, ProfitMarginViewDelegate, SpecialItemDelegate> {
	iPOSFacade *facade;
    OrderCart *orderCart;
    
    Linea *linea;
    
    SearchItemView *searchOverlay;
    AddItemView *addItemOverlay;
	
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
    
    MOGlassButton *discountButton;
	
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
    //Enning Tang Add LTLWeight Button 2013/2/26
    UIBarButtonItem *LTLButton;
    
    UIButton *commitEditsButton;
	UILabel *markDeleteLabel;
	UILabel *markCloseLabel;
	UIView *editHeaderView;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
	
}

@property (nonatomic, retain) NSArray *toolbarBasic;
@property (nonatomic, retain) NSArray *toolbarWithQuoteAndOrder;
@property (nonatomic, retain) NSArray *toolbarEditMode;
//Enning Tang Added toolbarRunning
@property (nonatomic, retain) NSArray *toolbarRunning;

@property (nonatomic, retain) UIButton *commitEditsButton;
@property (nonatomic, retain) UILabel *markDeleteLabel;
@property (nonatomic, retain) UILabel *markCloseLabel;
@property (nonatomic, retain) UIView *editHeaderView;

@property (nonatomic, assign) BOOL multiEditMode;
@property (nonatomic, assign) NSInteger countMarkDelete;
@property (nonatomic, assign) NSInteger countMarkClose;

@end
