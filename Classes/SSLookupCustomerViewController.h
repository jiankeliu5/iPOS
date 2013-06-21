//
//  SSLookupCustomerViewController.h
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OrderCart.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"

#import "Customer.h"
#import "Items.h"
#import "ItemSet.h"

@interface SSLookupCustomerViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
	
	OrderCart *orderCart;
    iPOSFacade *facade;
    
	ExtUITextField *custPhoneField;
    ExtUITextField *custNameField;
    
    ItemSet *getitems;
    
    //	MOGlassButton *custSearchButton;
    //	MOGlassButton *confirmButton;
	
    //	UIView *detailView;
    //	UILabel *firstLabel;
    //	UILabel *firstName;
    //	UILabel *lastLabel;
    //	UILabel *lastName;
    //	UILabel *emailLabel;
    //	UILabel *email;
    //	UILabel *zipLabel;
    //	UILabel *zip;
    //    UILabel *holdStatusLabel;
    //    UILabel *holdStatus;
    //	
    //	BOOL custDetailsOpen;
    //	
    //	Customer *customer;
	
}

// @property (nonatomic, retain) Customer *customer;
@end
