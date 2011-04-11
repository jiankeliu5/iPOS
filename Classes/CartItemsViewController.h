//
//  CartItemsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"

#import "OrderCart.h"
#import "AddItemView.h"
#import "ExtUITextField.h"
#import "SearchItemView.h"
#import "CartItemTableCell.h"

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SearchItemViewDelegate, CartItemCellDelegate> {
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
	NSArray *toolbarWithQuote;
	NSArray *toolbarEditMode;
	
	UIBarButtonItem *editBarButton;
	UIBarButtonItem *cancelBarButton;
	UIButton *commitEditsDeleteButton;
	UIButton *commitEditsCloseButton;
	
	BOOL multiEditMode;
	NSInteger countMarkedDelete;
	NSInteger countMarkedClose;
	
}

@property (nonatomic, retain) NSArray *toolbarBasic;
@property (nonatomic, retain) NSArray *toolbarWithQuote;
@property (nonatomic, retain) NSArray *toolbarEditMode;

@property (nonatomic, retain) UIBarButtonItem *editBarButton;
@property (nonatomic, retain) UIBarButtonItem *cancelBarButton;
@property (nonatomic, retain) UIButton *commitEditsDeleteButton;
@property (nonatomic, retain) UIButton *commitEditsCloseButton;

@property (nonatomic, assign) BOOL multiEditMode;
@property (nonatomic, assign) NSInteger countMarkDelete;
@property (nonatomic, assign) NSInteger countMarkClose;

@end
