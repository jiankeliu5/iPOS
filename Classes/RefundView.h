//
//  RefundView.h
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Order.h"

@protocol RefundViewDelegate;

@interface RefundView : UIView<UITableViewDelegate, UITableViewDataSource> {

    id<RefundViewDelegate> delegate;
    Order *order;
    Refund *refundInfo;
    
    UILabel *refundTitle;
    UILabel *refundTotalLabel;
    UIToolbar *refundToolbar;
    UITableView *refundAmountsTableView;
}
@property (nonatomic, assign) id<RefundViewDelegate> delegate;

@property (nonatomic, assign) Order *order;
@property (nonatomic, assign) Refund *refundInfo;
@property (nonatomic, retain) UILabel *refundTitle;
@property (nonatomic, retain) UILabel *refundTotalLabel;
@property (nonatomic, retain) UIToolbar *refundToolbar;
@property (nonatomic, retain) UITableView *refundAmountsTableView;

- (id) initWithFrame: (CGRect) frame andOrder: (Order *) anOrder andRefund: (Refund *) aRefundInfo;

@end

@protocol RefundViewDelegate <NSObject>

- (void) applyRefund: (RefundView *) refundView;
- (void) editOrderNotes: (RefundView *) refundView;

@end