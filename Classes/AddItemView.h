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
@class AddItemView;

@protocol AddItemViewDelegate

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;
- (void) cancelAddItem:(AddItemView *)addItemView;

@end


#define AVAILABLE_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define UNAVAILABLE_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]
#define LARGE_FONT_SIZE 16.0f
#define SMALL_FONT_SIZE 11.0f
#define BIG_LABEL_HEIGHT 16.0f
#define SMALL_LABEL_HEIGHT 14.0f
#define ROUND_VIEW_WIDTH 240.0f
#define ROUND_VIEW_HEIGHT 290.0f

@interface AddItemView : UIView <UITextFieldDelegate>
{
	id productItem;
	NSObject <AddItemViewDelegate>* viewDelegate;
	
	GradientView *roundedView;
	UILabel *skuLabel;
	UILabel *descriptionLabel;
	UILabel *priceLabel;
	UIView *storeInfo;
	UILabel *storeIdLabel;
	UILabel *storeAvailableLabel;
	UILabel *storeOnHandLabel;
	UIView *warehouseInfo;
	UILabel *warehouseIdLabel;
	UILabel *warehouseAvailableLabel;
	UILabel *warehouseOnHandLabel;
	MOGlassButton *addToCartButton;
	MOGlassButton *exitButton;
	GradientView *addQuantityView;
	UILabel *addQuantityUnitsLabel;
	ExtUITextField *addQuantityField;
	
	NSNumberFormatter *priceFormatter;
	NSNumberFormatter *availableFormatter;
	
	id currentFirstResponder;
	CGFloat previousViewOriginY;

}

@property (nonatomic, retain) id productItem;
@property (nonatomic, assign) NSObject<AddItemViewDelegate>* viewDelegate;
@property (nonatomic, retain) id currentFirstResponder;

@end
