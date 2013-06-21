//
//  SSCheckoutCustomerListViewController.h
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iPOSFacade.h"
#import "Items.h"
#import "ItemSet.h"

@interface SSCheckoutCustomerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    iPOSFacade *facade;
    
    UITableView *customerListTableView;
    //UIBarButtonItem *closeBarButton;
    
    NSString *searchString;
    
    NSArray *customerList;
    
    BOOL doGetOrdersOnSelection;
}

@property (nonatomic, retain) NSArray *customerList;
@property (nonatomic, retain) NSString *searchString;
@property (nonatomic, assign, getter=isDoGetOrdersOnSelection) BOOL doGetOrdersOnSelection;

@end
