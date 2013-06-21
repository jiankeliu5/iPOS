//
//  AddItemView.h
//  iPOS
//
//  Created by Steven McCoole on 2/12/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GradientView.h"
#import "MOGlassButton.h"
#import "ExtUITextField.h"

#import "ItemDetailView.h"
#import "ItemListView.h"
#import "AvailabilityView.h"

#import "ProductItem.h"

#import "iPOSFacade.h"


@class SSAddItemView;

@protocol SSAddItemViewDelegate

- (void) addItem:(SSAddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;
- (void) cancelAddItem:(SSAddItemView *)addItemView;

@end

@interface SSAddItemView : UIView <UITextFieldDelegate, ItemListViewDelegate, ItemDetailViewDelegate, UIPickerViewDelegate> {
	NSArray *productItemList;
    
    ProductItem *itemToAdd;
    
	NSObject <SSAddItemViewDelegate>* viewDelegate;
	
	GradientView *roundedView;
    
    UIView *itemContentView;
    UIView *toolsContentView;
    
    //Enning Tang Add ShipToStoreID View
    UIView *ShipToStoreIDView;
    UIPickerView *StorePicker;
    iPOSFacade *facade;
    NSArray *stores;
    NSDecimalNumber *quantity;
    NSString *ShipToStoreID;
    NSString *currentStoreID;
    
    
    ItemListView *itemListView;
    ItemDetailView *itemDetailView;
	
	MOGlassButton *addToCartButton;
	MOGlassButton *exitButton;
    MOGlassButton *confirmButton;
    
	GradientView *addQuantityView;
	UILabel *addQuantityUnitsLabel;
	UILabel *addQuantityFullBoxesLabel;
    UISwitch *addQuantityFullBoxSwitch;
    
    ExtUITextField *addQuantityField;
	
	id currentFirstResponder;
	CGFloat previousViewOriginY;
	BOOL keyboardCancelled;
	
	NSNumberFormatter *quantityFormatter;
    
    
}

@property (nonatomic, retain) NSArray *stores;
@property (nonatomic, retain) NSArray *productItemList;
@property (nonatomic, retain) ProductItem *itemToAdd;
@property (nonatomic, retain) NSDecimalNumber *quantity;
@property (nonatomic, retain) NSString *ShipToStoreID;
@property (nonatomic, retain) NSString *currentStoreID;

@property (nonatomic, assign) NSObject<SSAddItemViewDelegate>* viewDelegate;
@property (nonatomic, retain) id currentFirstResponder;
@property                     BOOL keyboardCancelled;

//- (void) addItemwithsku:(NSString*)sku orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;

@end
