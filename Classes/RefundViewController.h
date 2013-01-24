//
//  RefundViewController.h
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTDevices.h"
#import "iPOSFacade.h"
#import "OrderCart.h"
#import "NotesController.h"
#import "SignatureViewController.h"
#import "ChargeCreditCardView.h"

#import "RefundView.h"

@interface RefundViewController : UIViewController<RefundViewDelegate, NotesControllerDelegate, SignatureDelegate, ChargeCreditCardViewDelegate, UIAlertViewDelegate> {
    iPOSFacade *facade;
    OrderCart *orderCart;
    
    RefundView *refundView;
    ChargeCreditCardView *chargeCCView;
    
    Refund *refundInfo;
    
    BOOL orderIsSaved;
    
    DTDevices *linea;
}

@property (nonatomic, assign) iPOSFacade *facade;
@property (nonatomic, assign) OrderCart *orderCart;
@property (nonatomic, retain) Refund *refundInfo;

@end
