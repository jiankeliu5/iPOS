//
//  CustomerListViewController.h
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "iPOSFacade.h"

@interface CustomerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    iPOSFacade *facade;
    
    UITableView *customerListTableView;
    UIBarButtonItem *closeBarButton;
    
    NSString *searchString;
    
    NSArray *customerList;
}

@property (nonatomic, retain) NSArray *customerList;
@property (nonatomic, retain) NSString *searchString;

@end
