//
//  SSCheckoutCustomerDetailViewController.h
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOGlassButton.h"

#import "Customer.h"
#import "Items.h"
#import "ItemSet.h"

@interface SSCheckoutCustomerDetailViewController : UIViewController {
    
    MOGlassButton *confirmButton;
    MOGlassButton *editButton;
    
    UIView *detailView;
    UILabel *firstLabel;
    UILabel *firstName;
    UILabel *lastLabel;
    UILabel *lastName;
    UILabel *emailLabel;
    UILabel *email;
    UILabel *zipLabel;
    UILabel *zip;
    UILabel *holdStatusLabel;
    UILabel *holdStatus;
    
    BOOL custDetailsOpen;
    
    Customer *customer;
}

@property (nonatomic, retain) Customer *customer;

@end