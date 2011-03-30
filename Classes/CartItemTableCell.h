//
//  CartItemTableCell.h
//  iPOS
//
//  Created by Steven McCoole on 3/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OrderItem.h"
#import "ProductItem.h"

#define LABEL_FONT_SIZE 14.0f
#define LABEL_HEIGHT 16.0f
#define START_X 10.0f
#define START_Y 4.0f
#define QUANTITY_LABEL_PERCENT_WIDTH 66.0f
#define LINE_COST_LABEL_PERCENT_WIDTH 34.0f

@interface CartItemTableCell : UITableViewCell 
{
	OrderItem *orderItem;
	UILabel *descriptionLabel;
	UILabel *quantityLabel;
	UILabel *lineCostLabel;
}

@property (nonatomic, retain) OrderItem *orderItem;

@end
