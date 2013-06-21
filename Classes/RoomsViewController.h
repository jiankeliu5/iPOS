//
//  CartItemsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractTableViewController.h"
#import "AddFromListViewController.h"

@interface RoomsViewController : AbstractTableViewController <UITableViewDataSource, UITableViewDelegate, ModalViewControllerDelegate> {
    
}

@property (nonatomic, retain) NSArray *addRoomList;
@property (nonatomic, assign) Boolean addCustomer;
@end
