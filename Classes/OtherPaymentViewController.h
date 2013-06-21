//
//  OtherPaymentViewController.h
//  iPOS
//
//  Created by Enning Tang on 3/28/13.
//
//

#import <UIKit/UIKit.h>
#import "ProductItem.h"
#import "iPOSFacade.h"
#import "MOGlassButton.h"
#import "AmountPaymentView.h"

@class OtherPaymentViewController;

@protocol OtherPaymentViewControllerDelegate


@end

@interface OtherPaymentViewController : UIViewController <AmountPaymentViewDelegate, UIPickerViewDelegate>{
    UIPickerView *PaymentTypePicker;
    iPOSFacade *facade;
    NSArray *PaymentType;
    NSDecimalNumber *balanceDue;
    NSDecimalNumber *totalBalanceDue;
    NSString *getPaymentType;
    UILabel *SelectPaymentType;
    UILabel *balanceDueLabel;
    MOGlassButton *Okay;
    
    AmountPaymentView *amountPaymentView;

}

@property (nonatomic, retain) NSArray *PaymentType;
@property (nonatomic, retain) NSDecimalNumber *balanceDue;
@property (nonatomic, retain) NSDecimalNumber *totalBalanceDue;
@property (nonatomic, retain) NSString *getPaymentType;

- (id)initWithBalanceDue:(NSDecimalNumber *)getbalanceDue totalBalanceDue:(NSDecimalNumber *) getTotalBalanceDue;

@end
