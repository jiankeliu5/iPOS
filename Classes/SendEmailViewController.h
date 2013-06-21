//
//  SendEmailViewController.h
//  iPOS
//
//  Created by Enning Tang on 5/8/13.
//
//

#import <UIKit/UIKit.h>
#import "ExtUIViewController.h"
#import "ExtUITextField.h"
#import "AddItemView.h"
#import "SignatureViewController.h"
#import "MOGlassButton.h"

#import "OrderCart.h"
#import "Order.h"

@interface SendEmailViewController : ExtUIViewController <ExtUIViewControllerDelegate> {
    iPOSFacade *facade;
	
    Order *order;
    OrderCart *orderCart;
    UILabel *emailReceipt;
    ExtUITextField *orderID;
    ExtUITextField *emailAddress;
    MOGlassButton *sendReceipt;
}

@property (nonatomic, retain) Order *order;

@end
