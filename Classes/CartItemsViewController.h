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

#define CUST_LABEL_HEIGHT 12.0f
#define CUST_LABEL_FONT_SIZE 12.0f
#define ORDER_TABLE_HEIGHT 318.0f
#define ORDER_LABEL_FONT_SIZE 14.0f
#define ORDER_LABEL_WIDTH 280.0f
#define ORDER_LABEL_HEIGHT 14.0f
#define ORDER_VALUE_WIDTH 40.0f
#define ORDER_VALUE_HEIGHT 14.0f
#define ORDER_TOOLBAR_HEIGHT 44.0f
#define LOOKUP_SKU_X 2.0f
#define LOOKUP_SKU_Y 7.0f
#define LOOKUP_SKU_WIDTH 160.0f
#define LOOKUP_SKU_HEIGHT 30.0f

@interface CartItemsViewController : UIViewController <LineaDelegate, AddItemViewDelegate> {
	iPOSFacade *facade;
    
    Linea *linea;
	
	UILabel *custLabel;
	UITableView *orderTable;
	
	UILabel *subTotalLabel;
	UILabel *subTotalValue;
	UILabel *taxLabel;
	UILabel *taxValue;
	UILabel *totalLabel;
	UILabel *totalValue;
	
	UIToolbar *orderToolBar;
	ExtUITextField *lookupSkuField;
	
}

@end
