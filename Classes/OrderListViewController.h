//
//  OrderListViewController.h
//  iPOS
//
//  Created by Steven McCoole on 10/6/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "OrderCart.h"

@interface OrderListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    UITableView *orderListTableView;
    UIBarButtonItem *closeBarButton;
    
    NSString *searchPhone;
    
}

@property (nonatomic, copy) NSString *searchPhone;

@end
