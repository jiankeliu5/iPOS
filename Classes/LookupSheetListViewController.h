//
//  LookupSheetListViewController.h
//  selSheet
//
//  Created by Joshua Walker on 2/28/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectionSheet.h"
#import "iPOSFacade.h"
#import "GDataXMLNode.h"
#import "Items.h"
#import "ItemSet.h"
#import "XmlMarshaller.h"
#import "SSOrderCart.h"

@interface LookupSheetListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    iPOSFacade *facade;
    SelectionSheet *selSheet;
    //UIBarButtonItem *checkoutButton;
    SSOrderCart *orderCart;
    ItemSet *_itemset;
}
@property(nonatomic, retain) NSArray *tableData;

@property (nonatomic, retain) UITableView *theTableView;

@property (nonatomic, retain) UIBarButtonItem *checkoutbutton;

@property (nonatomic, retain) UITextField *customernamefield;
@property (nonatomic, retain) UITextField *customerphonefield;

@property (nonatomic, retain) NSString *checkoutResponseString;
//@property (nonatomic, retain) NSData *checkoutResponseData;

@property (nonatomic, retain) ItemSet *itemset;
@property (nonatomic, retain) NSMutableArray *itemDescription;
@property (nonatomic, retain) NSMutableArray *itemSku;
@property (nonatomic, retain) NSMutableArray *itemQty;
@property (nonatomic, retain) NSMutableArray *itemUOM;

@end
