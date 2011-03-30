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

#define CUST_SELECTED_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define NO_CUST_SELECTED_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]

#define CUST_LABEL_HEIGHT 14.0f
#define CUST_LABEL_FONT_SIZE 12.0f
#define CUST_LABEL_END_WIDTH 106.0f
#define CUST_LABEL_MIDDLE_WIDTH 108.0f

#define ORDER_TABLE_HEIGHT 310.0f

#define ORDER_LABEL_FONT_SIZE 14.0f
#define ORDER_LABEL_WIDTH 220.0f
#define ORDER_LABEL_HEIGHT 16.0f
#define ORDER_VALUE_X 240.0f
#define ORDER_VALUE_WIDTH 80.0f
#define ORDER_VALUE_HEIGHT 16.0f
#define ORDER_TOOLBAR_HEIGHT 44.0f

#define LOOKUP_SKU_X 2.0f
#define LOOKUP_SKU_Y 7.0f
#define LOOKUP_SKU_WIDTH 140.0f
#define LOOKUP_SKU_HEIGHT 30.0f
#define LOOKUP_SKU_FONT_SIZE 15.0f
#define KEYBOARD_TOOLBAR_HEIGHT 44.0f

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
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
	id currentFirstResponder;
	CGFloat previousViewOriginY;
	BOOL cancelSkuLookup;
	
}

@property (nonatomic, retain) id currentFirstResponder;
@property                     BOOL cancelSkuLookup;

@end
