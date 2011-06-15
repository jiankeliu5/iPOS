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

@class AddItemView;

@protocol AddItemViewDelegate

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;
- (void) cancelAddItem:(AddItemView *)addItemView;

@end

@interface AddItemView : UIView <UITextFieldDelegate, ItemListViewDelegate, ItemDetailViewDelegate> {
	NSArray *productItemList;
    
    ProductItem *itemToAdd;
    
	NSObject <AddItemViewDelegate>* viewDelegate;
	
	GradientView *roundedView;
    ItemListView *itemListView;
    ItemDetailView *itemDetailView;
	
	MOGlassButton *addToCartButton;
	MOGlassButton *exitButton;
    
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

@property (nonatomic, retain) NSArray *productItemList;
@property (nonatomic, retain) ProductItem *itemToAdd;

@property (nonatomic, assign) NSObject<AddItemViewDelegate>* viewDelegate;
@property (nonatomic, retain) id currentFirstResponder;
@property                     BOOL keyboardCancelled;

@end
