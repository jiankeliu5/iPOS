//
//  AccountPaymentView.h
//  iPOS
//
//  Created by Dan C on 9/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUITextField.h"
#import "MOGlassButton.h"
#import "OrderCart.h"
#import "PaymentView.h"
@class AccountPaymentView;
@class PaymentView;

@protocol AccountPaymentViewDelegate
- (void) setupKeyboardSupport:(id) accountPaymentView;
-(void) cancelAccountPayment:(id) sender;

@end


@interface AccountPaymentView : UIView<PaymentView>
{
    
    OrderCart *orderCart;
    
    NSString *balanceDue;
    NSString *totalAccountBalance;
    
    UIView *mainRoundedView;
    
    UILabel *balanceDueTitle;
    UILabel *balanceDueLabel;
    UILabel *creditAvailableTitle;
    UILabel *creditAvailableLabel;
    UILabel *amountToChargeLabel;
    UIView *ccChargeAmountView;
    id<AccountPaymentViewDelegate> viewDelegate;
    
    ExtUITextField *chargeAmountTextField;
    MOGlassButton *cancelButton;
}

@property (nonatomic, retain) NSString *balanceDue;
@property (nonatomic, retain) NSString *totalAccountBalance;
@property (nonatomic, retain) id viewDelegate;

@end
