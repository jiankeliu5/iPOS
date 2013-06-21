//
//  SSTenderPaymentViewController.h
//  iPOS
//
//  Created by Enning Tang on 8/7/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExtUIViewController.h"
#import "SSOrderCart.h"
#import "ChargeCreditCardView.h"
#import "SignatureViewController.h"
#import "LineaSDK.h"
#import "NotesController.h"
#import "AccountPaymentView.h"
#import "PaymentView.h"
#import "GradientView.h"
#import "TKCalendarMonthView.h"

@interface SSTenderPaymentViewController : ExtUIViewController<ExtUIViewControllerDelegate, ChargeCreditCardViewDelegate, LineaDelegate, SignatureDelegate, NotesControllerDelegate, AccountPaymentViewDelegate, TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource> {
	NSDecimalNumber *paymentAmount;
    id payment;
    
    iPOSFacade *facade;
    SSOrderCart *orderCart;
    
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
    Linea *linea;
    
    BOOL orderIsSaved;
    BOOL doNavToReceiptAfterOnAcctPayment;
    
    TKCalendarMonthView *calendar;
    UILabel *displaydate;
    UILabel *reqdate;
    NSString *requestString;
    UIButton *selectdate;
    
    Order *originalOrder;
    NSMutableArray *newClosedLines;
}

@property (nonatomic, retain) NSDecimalNumber *paymentAmount;
@property (nonatomic, retain) id payment;
@property (nonatomic, retain) TKCalendarMonthView *calendar;
@property (nonatomic, retain) UILabel *displaydate;
@property (nonatomic, retain) UILabel *reqdate;
@property (nonatomic, retain) NSString *requestString;
@property (nonatomic, retain) UIButton *selectdate;

@end
