//
//  ShipToViewController.h
//  iPOS
//
//  Created by Enning Tang on 10/30/12.
//
//

#import <UIKit/UIKit.h>
#import "ProductItem.h"
#import "iPOSFacade.h"
#import "MOGlassButton.h"
#import "OrderCart.h"
#import "ProductItem.h"
#import "OrderItem.h"

@class ShipToViewController;

@protocol ShipToViewControllerDelegate


@end

@interface ShipToViewController : UIViewController <UIPickerViewDelegate> {
    //Enning Tang Add ShipToStoreID View
    OrderItem *editItem;
    OrderCart *orderCart;
    UIView *ShipToStoreIDView;
    UIPickerView *StorePicker;
    iPOSFacade *facade;
    NSArray *stores;
    NSString *ShipToStoreID;
    NSString *currentStoreID;
    UILabel *shipTo;
    MOGlassButton *shipItem;
    MOGlassButton *shipOrder;
    
    ProductItem *itemToAdd;
}

@property (nonatomic, retain) NSArray *stores;
@property (nonatomic, retain) NSString *ShipToStoreID;
@property (nonatomic, retain) NSString *currentStoreID;
@property (nonatomic, retain) OrderItem *editItem;

- (id)initWithOrderItem:(OrderItem *)editOrderItem;

@end
