//
//  OtherPaymentView.h
//  iPOS
//
//  Created by Enning Tang on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "PaymentView.h"
#import "ExtUITextField.h"
#import "MOGlassButton.h"

@class OtherPaymentView;

@protocol OtherPaymentViewDelegate

- (void) setupKeyboardSupport:(id) chargeCCView;
- (void) readyForCardSwipe:(NSDecimalNumber *) chargeAmount fromView:(OtherPaymentView *) chargeCCView;
- (void) cancelCardSwipe:(OtherPaymentView *) chargeCCView;

@end

@interface OtherPaymentView : UIView<PaymentView>{
    NSString *balanceDue;
    NSString *totalBalance;
    
    UILabel *balanceDueTitle;
    UILabel *balanceDueLabel;
    UILabel *amountToChargeLabel;
    
    ExtUITextField *chargeAmountTextField;
    MOGlassButton *cancelButton;
    
    NSObject <OtherPaymentViewDelegate>* viewDelegate;
    
}

@property (nonatomic, retain) NSString *balanceDue;
@property (nonatomic, retain) NSString *totalBalance;

@property (nonatomic, assign) NSObject<OtherPaymentViewDelegate>* viewDelegate;

- (id) initWithFrame:(CGRect)frame;

@end
