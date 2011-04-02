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
#import "ExtUIViewController.h"
#import "ExtUITextField.h"

@interface CartItemsViewController : ExtUIViewController <LineaDelegate, AddItemViewDelegate, ExtUIViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
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
	ExtUITextField *lookupSkuField;
	
	NSArray *toolbarSearchOnly;
	NSArray *toolbarSearchAndQuote;
	
}

@property (nonatomic, retain) NSArray *toolbarSearchOnly;
@property (nonatomic, retain) NSArray *toolbarSearchAndQuote;

@end
