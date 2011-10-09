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

@interface LookupOrderViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    ExtUITextField *lookupOrderIdField;
    ExtUITextField *lookupOrderPhoneField;
    
    UIBarButtonItem *closeBarButton;
    
    NSNumberFormatter *orderIdFormatter;
}

@property (nonatomic, retain) UIBarButtonItem *closeBarButton;

@end
