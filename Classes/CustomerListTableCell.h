//
//  CustomerListTableCell.h
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Customer.h"

@interface CustomerListTableCell : UITableViewCell {
    
    UILabel *customerNameLabel;
    UILabel *customerPhoneLabel;
    UILabel *customerTypeLabel;
    
    Customer *customer;
}

@property (nonatomic, assign) Customer *customer;
@property (nonatomic, retain) UILabel *customerNameLabel;
@property (nonatomic, retain) UILabel *customerPhoneLabel;
@property (nonatomic, retain) UILabel *customerTypeLabel;

@end
