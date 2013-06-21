//
//  SSCartItemsViewController.h
//  iPOS
//
//  Created by Enning Tang on 8/3/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "ProfitMarginViewController.h"
#import "SSOrderCart.h"
#import "SSAddItemView.h"
#import "ExtUITextField.h"
#import "SSSearchItemView.h"
#import "SSCartItemTableCell.h"
#import "Items.h"
#import "ItemSet.h"

#import "MOGlassButton.h"


@interface SSCartItemsViewController : UIViewController <LineaDelegate, SSAddItemViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SSSearchItemViewDelegate, SSCartItemCellDelegate, ProfitMarginViewDelegate> {
	iPOSFacade *facade;
    SSOrderCart *orderCart;
    
    Linea *linea;
    
    SSSearchItemView *searchOverlay;
    SSAddItemView *addItemOverlay;
	
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
    
    UIButton *commitEditsButton;
	UILabel *markDeleteLabel;
	UILabel *markCloseLabel;
	UIView *editHeaderView;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
    //Customer *cust;
    
    NSNumberFormatter *quantityFormatter;
	
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
@property (nonatomic, retain) ItemSet *getitems;

-(id)initWithCustomer:(Customer *)customer;
-(void)setCustomer:(Customer *) customer;
-(id)initwithItems:(ItemSet *) paraitems;

@end
