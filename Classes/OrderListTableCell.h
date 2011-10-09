//
//  OrderListTableCell.h
//  iPOS
//
//  Created by Steven McCoole on 10/8/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviousOrder.h"

@interface OrderListTableCell : UITableViewCell {
    PreviousOrder *previousOrder;
    UILabel *dateLabel;
    UILabel *totalLabel;
    UILabel *orderIdLabel;
    UILabel *statusLabel;
}

// Use assign because the previous orders are in a singleton.
@property (nonatomic, assign) PreviousOrder *previousOrder;

@end
