//
//  ItemListView.h
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ProductItem.h"

@protocol ItemListViewDelegate

-(void) selectItem: (ProductItem *) item;

@end

@interface ItemListView : UIView<UITableViewDelegate, UITableViewDataSource> {
    NSArray *itemList;
    
    NSObject<ItemListViewDelegate> *viewDelegate;
    
    UILabel *matchesLabel;
    UITableView *itemListTable;
}

@property (nonatomic, assign) NSArray *itemList;
@property (nonatomic, assign) NSObject<ItemListViewDelegate> *viewDelegate;

- (void) deselectTableRow;
@end
