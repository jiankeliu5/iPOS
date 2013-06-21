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
#import "TKCalendarMonthView.h"

@interface TenderPaymentViewController : ExtUIViewController<ExtUIViewControllerDelegate, ChargeCreditCardViewDelegate, LineaDelegate, SignatureDelegate, NotesControllerDelegate, AccountPaymentViewDelegate, TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource> {
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
    Linea *linea;
    
    TKCalendarMonthView *calendar;
    UILabel *displaydate;
    UILabel *reqdate;
    NSString *requestString;
    UIButton *selectdate;
    
    BOOL orderIsSaved;
    BOOL doNavToReceiptAfterOnAcctPayment;
    
    //Enning Tang write down original order before saved 3/19/2013
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
