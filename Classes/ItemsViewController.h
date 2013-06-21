//
//  ItemsViewController.h
//  selSheet
//
//  Created by Joshua Walker on 2/11/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "AbstractTableViewController.h"
#import "AddFromListViewController.h"
#import "Area.h"
#import "SSAddItemView.h"
#import "SearchItemView.h"
#import "LineaSDK.h"

@interface ItemsViewController : AbstractTableViewController <UITableViewDataSource, UITableViewDelegate, LineaDelegate, SSAddItemViewDelegate, SearchItemViewDelegate, UIAlertViewDelegate> {
    UITextView *textField;
    Linea *linea;
}

@property (nonatomic, retain) Area *parentArea;

- (id)initWithArea:(Area *)area;
- (void) showAddItemOverlay: (NSArray *) foundItems;

@end