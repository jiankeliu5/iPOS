//
//  ChargeCreditCardAmountView.h
//  iPOS
//
//  Created by Torey Lomenda on 4/20/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExtUITextField.h"
#import "MOGlassButton.h"
#import "PaymentView.h"

@class ChargeCreditCardView;
@class PaymentView;
@protocol ChargeCreditCardViewDelegate

- (void) setupKeyboardSupport:(id) chargeCCView;
- (void) readyForCardSwipe:(NSDecimalNumber *) chargeAmount fromView:(ChargeCreditCardView *) chargeCCView;
- (void) cancelCardSwipe:(ChargeCreditCardView *) chargeCCView;

@end

@interface ChargeCreditCardView : UIView<PaymentView>{
    NSString *balanceDue;
    NSString *totalBalance;
    
    UIView *mainRoundedView;
        
    UILabel *balanceDueTitle;
    UILabel *balanceDueLabel;
    UILabel *amountToChargeLabel;
    UIView *ccChargeAmountView;
    UIView *ccSwipeMsgView;
    
    ExtUITextField *chargeAmountTextField;
    MOGlassButton *cancelButton;
    
    NSObject <ChargeCreditCardViewDelegate>* viewDelegate;
}

@property (nonatomic, retain) NSString *balanceDue;
@property (nonatomic, retain) NSString *totalBalance;

@property (nonatomic, assign) NSObject<ChargeCreditCardViewDelegate>* viewDelegate;


- (void) switchCardSwipeToReady;

@end
