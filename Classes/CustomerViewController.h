//
//  CustomerViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "OrderCart.h"
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"

#import "Customer.h"

@interface CustomerViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
	
	OrderCart *orderCart;
    iPOSFacade *facade;
    
	ExtUITextField *custPhoneField;
    ExtUITextField *custNameField;
    
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
