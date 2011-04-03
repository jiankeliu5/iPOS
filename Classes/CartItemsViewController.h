//
//  CartItemsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineaSDK.h"
#import "iPOSFacade.h"
#import "AddItemView.h"
#import "ExtUITextField.h"
#import "SearchItemView.h"

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SearchItemViewDelegate> {
	iPOSFacade *facade;
    
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
	UIBarButtonItem *commitEditsButton;
	
}

@property (nonatomic, retain) NSArray *toolbarBasic;
@property (nonatomic, retain) NSArray *toolbarWithQuote;
@property (nonatomic, retain) NSArray *toolbarEditMode;

@property (nonatomic, retain) UIBarButtonItem *editBarButton;
@property (nonatomic, retain) UIBarButtonItem *cancelBarButton;
@property (nonatomic, retain) UIBarButtonItem *commitEditsButton;

@end
