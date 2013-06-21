//
//  ItemTableCell.h
//  iPOS
//
//  Created by Torey Lomenda on 5/9/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductItem.h"

@interface ItemTableCell : UITableViewCell {
    ProductItem *item;
    
    UILabel *itemDescriptionLabel;
}

@property (nonatomic, assign) ProductItem *item;

@end
