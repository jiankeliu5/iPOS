//
//  AmountPaymentView.h
//  iPOS
//
//  Created by Enning Tang on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "ExtUITextField.h"
#import "MOGlassButton.h"
#import "PaymentView.h"
#import "ExtUIViewController.h"
#import "AlertUtils.h"
#import "iPOSFacade.h"
#import "OrderCart.h"
#import "Order.h"

@class AmountPaymentView;
@class PaymentView;
@protocol AmountPaymentViewDelegate

- (void) setupKeyboardSupport:(id) chargeCCView;
- (void) cancelSearchItem:(AmountPaymentView *)aSearchItemView;

@end

@interface AmountPaymentView : UIView<PaymentView, UITextFieldDelegate> {
    NSDecimalNumber *balanceDue;
    NSDecimalNumber *totalBalance;
    
    UIView *mainRoundedView;
    
    UINavigationController *navigationController;
    
    UILabel *balanceDueTitle;
    UILabel *balanceDueLabel;
    UILabel *totalBalanceDueTitle;
    UILabel *totalBalanceDueLabel;
    UILabel *amountToChargeLabel;
    CGPoint originalCenter;
    
    NSString *paymentType;
    
    ExtUITextField *chargeAmountTextField;
    MOGlassButton *confirmButton;
    MOGlassButton *cancellButton;
    
    NSObject <AmountPaymentViewDelegate>* viewDelegate;
    
    id currentFirstResponder;
	BOOL keyboardCancelled;
    
    iPOSFacade *facade;
    
    OrderCart *orderCart;
    
}

@property (nonatomic, retain) NSDecimalNumber *balanceDue;
@property (nonatomic, retain) NSDecimalNumber *totalBalance;
@property (nonatomic, retain) NSString *paymentType;
@property (nonatomic, retain) id currentFirstResponder;
@property (nonatomic, assign) BOOL keyboardCancelled;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, assign) NSObject<AmountPaymentViewDelegate>* viewDelegate;


- (id) initWithBalanceDue:(CGRect)frame balanceDue:(NSDecimalNumber *) setBalanceDue totalBalance:(NSDecimalNumber *) setTotalBalance;

@end
