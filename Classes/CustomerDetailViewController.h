//
//  CustomerDetailViewController.h
//  iPOS
//
//  Created by Torey Lomenda on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MOGlassButton.h"

#import "Customer.h"

@interface CustomerDetailViewController : UIViewController {

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
