//
//  AddFromListViewController.h
//  selSheet
//
//  Created by Josh Walker on 2/10/2012.
//  Copyright 2012 Object Partners Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ModalViewControllerDelegate;


@interface AddFromListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    
}
@property(nonatomic, retain) NSArray *tableData;

@property (nonatomic, retain) UITableView *theTableView;
@property (nonatomic, assign) id<ModalViewControllerDelegate> delegate;

@end

@protocol ModalViewControllerDelegate <NSObject>

- (void)didDismissModalView;
- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddItem:(NSInteger)item;
- (void)addFromListViewController:(AddFromListViewController *)addFromListViewController didAddNewItem:(NSString *)itemString;


@end

