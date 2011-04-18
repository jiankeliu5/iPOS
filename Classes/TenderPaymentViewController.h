//
//  TenderPaymentViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderCart.h"

@interface TenderPaymentViewController : UIViewController {
	iPOSFacade *facade;
    OrderCart *orderCart;
    
    UIToolbar *paymentToolbar;
    
    UILabel *retailTotalLabel;
    UILabel *discountTotalLabel;
    UILabel *subTotalLabel;
    UILabel *taxTotalLabel;
    UILabel *totalLabel;
    
    UILabel *balanceDueLabel;
}

@end
