//
//  TenderPaymentViewController.h
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExtUIViewController.h"
#import "OrderCart.h"
#import "ChargeCreditCardView.h"
#import "SignatureViewController.h"
#import "DTDevices.h"
#import "NotesController.h"
#import "AccountPaymentView.h"
#import "PaymentView.h"
#import "GradientView.h"

@interface TenderPaymentViewController : ExtUIViewController<ExtUIViewControllerDelegate, ChargeCreditCardViewDelegate, DTDeviceDelegate, SignatureDelegate, NotesControllerDelegate, AccountPaymentViewDelegate> {
	NSDecimalNumber *paymentAmount;
    id payment;
    
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    UIToolbar *paymentToolbar;
    UILabel *retailTotalLabel;
    UILabel *discountTotalLabel;
    UILabel *subTotalLabel;
    UILabel *taxTotalLabel;
    UILabel *totalLabel;
    
    
    UILabel *balancePaidTitleLabel;
    UILabel *balancePaidLabel;
    UILabel *balanceOwingTitleLabel;
    UILabel *balanceOwingLabel;
    UILabel *balanceDueTitleLabel;
    UILabel *balanceDueLabel;
    
    ChargeCreditCardView *chargeCCView;
    AccountPaymentView *accountPaymentView;
    
    GradientView *separatorView;
    GradientView *tenderTotalView;
    DTDevices *linea;
    
    BOOL orderIsSaved;
    BOOL doNavToReceiptAfterOnAcctPayment;
}

@property (nonatomic, retain) NSDecimalNumber *paymentAmount;
@property (nonatomic, retain) id payment;

@end
