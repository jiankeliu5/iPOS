//
//  LookupOrderViewController.h
//  iPOS
//
//  Created by Steven McCoole on 10/5/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPOSFacade.h"
#import "OrderCart.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"

@interface LookupOrderViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    ExtUITextField *lookupCustomerField;
    ExtUITextField *lookupCustomerEmailField;
    ExtUITextField *lookupOrderPhoneField;
    ExtUITextField *lookupOrderIdField;
    MOGlassButton *lookupSelectionProject;
    
    UIBarButtonItem *closeBarButton;
    
    NSNumberFormatter *orderIdFormatter;
    NSDateFormatter *dateFormatter;
}

@property (nonatomic, retain) UIBarButtonItem *closeBarButton;

@end
