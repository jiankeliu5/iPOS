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
#import "AvailabilityView.h"

@class AddItemView;

@protocol AddItemViewDelegate

- (void) addItem:(AddItemView *)addItemView orderQuantity:(NSDecimalNumber *)quantity ofUnits:(NSString *)unitOfMeasure;
- (void) cancelAddItem:(AddItemView *)addItemView;

@end


#define AVAILABLE_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define UNAVAILABLE_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]
#define LARGE_FONT_SIZE 16.0f
#define BIG_LABEL_HEIGHT 16.0f
#define AVAILABILITY_VIEW_HEIGHT 56.0f
#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 402.0f

@interface AddItemView : UIView <UITextFieldDelegate>
{
	id productItem;
	NSObject <AddItemViewDelegate>* viewDelegate;
	
	GradientView *roundedView;
	UILabel *skuLabel;
	UILabel *descriptionLabel;
	UILabel *priceLabel;
	
	AvailabilityView *storeInfoView;
	
	AvailabilityView *dc1InfoView;
	
	AvailabilityView *dc2InfoView;
	
	AvailabilityView *dc3InfoView;
	
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
