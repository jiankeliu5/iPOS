//
//  ReceiptOptionsViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderCart.h"
#import "MOGlassButton.h"

@interface ReceiptViewController : UIViewController {
    OrderCart *orderCart;
	iPOSFacade *facade;
    
    // Handle to the views for layout
    UIView *overlayView;
    UIView *roundedView;
    
    MOGlassButton *emailReceiptButton;
    MOGlassButton *printReceiptButton;
    MOGlassButton *printEmailReceiptButton;
    MOGlassButton *exitWithoutReceiptButton;

}

@end
