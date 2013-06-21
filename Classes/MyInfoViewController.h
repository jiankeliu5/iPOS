//
//  MyInfoViewController.h
//  iPOS
//
//  Created by Enning Tang on 5/9/13.
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

@interface MyInfoViewController : UIViewController{
    iPOSFacade *facade;
	
    Order *order;
    OrderCart *orderCart;
    UILabel *salesPersonLabel;
    UILabel *storeIdLabel;
    UILabel *deviceIdLabel;
}
@end
