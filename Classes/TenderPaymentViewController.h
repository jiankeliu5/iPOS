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
#import "LineaSDK.h"
#import "NotesController.h"
#import "AccountPaymentView.h"
#import "PaymentView.h"
#import "GradientView.h"

@interface TenderPaymentViewController : ExtUIViewController<ExtUIViewControllerDelegate, ChargeCreditCardViewDelegate, LineaDelegate, SignatureDelegate, NotesControllerDelegate, AccountPaymentViewDelegate> {
	NSDecimalNumber *paymentAmount;
    id ccPayment;
    
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    UIToolbar *paymentToolbar;
    UILabel *retailTotalLabel;
    UILabel *discountTotalLabel;
    UILabel *subTotalLabel;
    UILabel *taxTotalLabel;
    UILabel *totalLabel;
    
    UILabel *balanceDueTitleLabel;
    UILabel *balanceDueLabel;
    ChargeCreditCardView *chargeCCView;
    AccountPaymentView *accountPaymentView;
    
    GradientView *separatorView;
    GradientView *tenderTotalView;
    Linea *linea;
}

@property (nonatomic, retain) NSDecimalNumber *paymentAmount;
@property (nonatomic, retain) id ccPayment;

@end
