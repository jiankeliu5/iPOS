//
//  RefundItemTableCell.h
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefundItem.h"

@interface RefundItemTableCell : UITableViewCell {
    RefundItem *refundItem;
    
    UILabel *refundInfoLabel;
    UILabel *refundAmountLabel;
    UILabel *signatureRequiredLabel;
}

@property (nonatomic, assign) RefundItem *refundItem;
@property (nonatomic, retain) UILabel *refundInfoLabel;
@property (nonatomic, retain) UILabel *refundAmountLabel;
@property (nonatomic, retain) UILabel *signatureRequiredLabel;

@end
