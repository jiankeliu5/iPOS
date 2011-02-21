//
//  AddItemView.m
//  iPOS
//
//  Created by Steven McCoole on 2/12/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <math.h>

#import "AddItemView.h"
#import "LayoutUtils.h"
#import "ProductItem.h"

#pragma mark -
#pragma mark Private Interface
@interface AddItemView ()
- (void) updateDisplayValues;
- (void) handleExitButton:(id)sender;
- (void) handleAddToCartButton:(id)sender;
- (void) addKeyboardListeners;
- (void) removeKeyboardListeners;
@end

#pragma mark -
@implementation AddItemView

// This is our data item to display and work with
@synthesize productItem;

// Page components
@synthesize roundedView;
@synthesize skuLabel;
@synthesize descriptionLabel;
@synthesize priceLabel;
@synthesize storeInfo;
@synthesize storeIdLabel;
@synthesize storeAvailableLabel;
@synthesize storeOnHandLabel;
@synthesize warehouseInfo;
@synthesize warehouseIdLabel;
@synthesize warehouseAvailableLabel;
@synthesize warehouseOnHandLabel;
@synthesize addToCartButton;
@synthesize exitButton;
@synthesize	addQuantityView;
@synthesize addQuantityUnitsLabel;
@synthesize addQuantityField;

// NSDecimalNumber formatters.  Instance vars so we don't have to make release them all the time.
@synthesize priceFormatter;
@synthesize availableFormatter;

// Our delegate to hand off to when we either cancel or enter a quantity.
@synthesize viewDelegate;

// Hook for who is responding, used to slide textfields up when keyboard shows
@synthesize currentFirstResponder;

#pragma mark Constructors
- (id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
	[self setPriceFormatter:[[NSNumberFormatter alloc] init]];
	[self.priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self setAvailableFormatter:[[NSNumberFormatter alloc] init]];
	[self.availableFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[self.availableFormatter setMaximumFractionDigits:2];
	[self.availableFormatter setMinimumFractionDigits:2];
	
    return self;
}

- (void) dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	[self setCurrentFirstResponder:nil];
	
	[self setViewDelegate:nil];
	
	[self setPriceFormatter:nil];
	[self setAvailableFormatter:nil];
	
	[self setSkuLabel:nil];
	[self setDescriptionLabel:nil];
	[self setPriceLabel:nil];
	[self setStoreIdLabel:nil];
	[self setStoreAvailableLabel:nil];
	[self setStoreOnHandLabel:nil];
	[self setWarehouseIdLabel:nil];
	[self setWarehouseAvailableLabel:nil];
	[self setWarehouseOnHandLabel:nil];
	[self setAddToCartButton:nil];
	[self setExitButton:nil];
	[self setAddQuantityField:nil];
	[self setAddQuantityUnitsLabel:nil];
	[self setAddQuantityView:nil];
	[self setStoreInfo:nil];
	[self setWarehouseInfo:nil];
	[self setRoundedView:nil];
	
	[self setProductItem:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (id) productItem {
	return productItem;
}

- (void) setProductItem:(id)product {
	// This basically does the same as the standard synthesized
	// retain setter, but we have to override it in order to
	// make ourselves redisplay when we get a new productItem 
	// set.
	if (productItem != product) {
		[productItem autorelease];
		productItem = [product retain];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Methods

- (void) layoutSubviews {
		
	self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
	if (self.roundedView == nil) {
		[self setRoundedView:[[GradientView alloc] initWithFrame:CGRectMake(40.0f, 60.0f, ROUND_VIEW_WIDTH, ROUND_VIEW_HEIGHT)]];
		[self.roundedView.layer setCornerRadius:5.0f];
		[self.roundedView.layer setMasksToBounds:YES];
		[self.roundedView.layer setBorderWidth:1.0f];
		[self.roundedView.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[self.roundedView setStart:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] andEndColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
		[self addSubview:self.roundedView];
	}
	
	// Keep track of how far down we are in the view
	CGFloat cy = 10.0f;
	
	if (self.skuLabel == nil) {
		[self setSkuLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)]];
		self.skuLabel.backgroundColor = [UIColor clearColor];
		self.skuLabel.textColor = [UIColor blackColor];
		self.skuLabel.textAlignment = UITextAlignmentCenter;
		self.skuLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		self.skuLabel.text = @"NA";
		[self.roundedView addSubview:self.skuLabel];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (self.descriptionLabel == nil) {
		[self setDescriptionLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)]];
		self.descriptionLabel.backgroundColor = [UIColor clearColor];
		self.descriptionLabel.textColor = [UIColor blackColor];
		self.descriptionLabel.textAlignment = UITextAlignmentCenter;
		self.descriptionLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		self.descriptionLabel.text = @"NA";
		[self.roundedView addSubview:self.descriptionLabel];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (self.priceLabel == nil) {
		[self setPriceLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)]];
		self.priceLabel.backgroundColor = [UIColor clearColor];
		self.priceLabel.textColor = [UIColor blackColor];
		self.priceLabel.textAlignment = UITextAlignmentCenter;
		self.priceLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		self.priceLabel.text = @"NA";
		[self.roundedView addSubview:self.priceLabel];
	}
	
	cy += BIG_LABEL_HEIGHT + 10.0f;
	
	if (self.storeInfo == nil) {
		
		[self setStoreInfo:[[UIView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, (SMALL_LABEL_HEIGHT * 4.0))]];
		self.storeInfo.backgroundColor = AVAILABLE_COLOR;
		[self.storeInfo.layer setBorderWidth:1.0f];
		[self.storeInfo.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[self.roundedView addSubview:self.storeInfo];
		
		CGFloat sy = (SMALL_LABEL_HEIGHT / 2.0f);					
		if (self.storeIdLabel == nil) {
			[self setStoreIdLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, sy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.storeIdLabel.backgroundColor = [UIColor clearColor];
			self.storeIdLabel.textColor = [UIColor blackColor];
			self.storeIdLabel.textAlignment = UITextAlignmentCenter;
			self.storeIdLabel.font = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
			self.storeIdLabel.text = @"NA";
			[self.storeInfo addSubview:self.storeIdLabel];
		}
		
		sy += SMALL_LABEL_HEIGHT;
		
		if (self.storeAvailableLabel == nil) {
			[self setStoreAvailableLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, sy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.storeAvailableLabel.backgroundColor = [UIColor clearColor];
			self.storeAvailableLabel.textColor = [UIColor blackColor];
			self.storeAvailableLabel.textAlignment = UITextAlignmentCenter;
			self.storeAvailableLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
			self.storeAvailableLabel.text = @"NA";
			[self.storeInfo addSubview:self.storeAvailableLabel];
		}
		
		sy += SMALL_LABEL_HEIGHT;
		
		if (self.storeOnHandLabel == nil) {
			[self setStoreOnHandLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, sy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.storeOnHandLabel.backgroundColor = [UIColor clearColor];
			self.storeOnHandLabel.textColor = [UIColor blackColor];
			self.storeOnHandLabel.textAlignment = UITextAlignmentCenter;
			self.storeOnHandLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
			self.storeOnHandLabel.text = @"NA";
			[self.storeInfo addSubview:self.storeOnHandLabel];
		}
	}
	
	cy += (SMALL_LABEL_HEIGHT * 4.0);

	if (self.warehouseInfo == nil) {
		[self setWarehouseInfo:[[UIView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, (SMALL_LABEL_HEIGHT * 4.0))]];
		self.warehouseInfo.backgroundColor = AVAILABLE_COLOR;
		[self.warehouseInfo.layer setBorderWidth:1.0f];
		[self.warehouseInfo.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[self.roundedView addSubview:self.warehouseInfo];
		
		CGFloat wy = (SMALL_LABEL_HEIGHT / 2.0f);
		
		if (self.warehouseIdLabel == nil) {
			[self setWarehouseIdLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, wy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.warehouseIdLabel.backgroundColor = [UIColor clearColor];
			self.warehouseIdLabel.textColor = [UIColor blackColor];
			self.warehouseIdLabel.textAlignment = UITextAlignmentCenter;
			self.warehouseIdLabel.font = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
			self.warehouseIdLabel.text = @"NA";
			[self.warehouseInfo addSubview:self.warehouseIdLabel];
		}
		
		wy += SMALL_LABEL_HEIGHT;
		
		if (self.warehouseAvailableLabel == nil) {
			[self setWarehouseAvailableLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, wy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.warehouseAvailableLabel.backgroundColor = [UIColor clearColor];
			self.warehouseAvailableLabel.textColor = [UIColor blackColor];
			self.warehouseAvailableLabel.textAlignment = UITextAlignmentCenter;
			self.warehouseAvailableLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
			self.warehouseAvailableLabel.text = @"NA";
			[self.warehouseInfo addSubview:self.warehouseAvailableLabel];
		}
		
		wy += SMALL_LABEL_HEIGHT;
		
		if (self.warehouseOnHandLabel == nil) {
			[self setWarehouseOnHandLabel:[[UILabel alloc] initWithFrame:CGRectMake(0.0f, wy, ROUND_VIEW_WIDTH, SMALL_LABEL_HEIGHT)]];
			self.warehouseOnHandLabel.backgroundColor = [UIColor clearColor];
			self.warehouseOnHandLabel.textColor = [UIColor blackColor];
			self.warehouseOnHandLabel.textAlignment = UITextAlignmentCenter;
			self.warehouseOnHandLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
			self.warehouseOnHandLabel.text = @"NA";
			[self.warehouseInfo addSubview:self.warehouseOnHandLabel];
		}
	}
	
	cy += (SMALL_LABEL_HEIGHT * 4.0) + 15.0f;
	
	if (self.addToCartButton == nil) {
		[self setAddToCartButton:[[MOGlassButton alloc] initWithFrame:CGRectMake(26.0f, cy, 80.0f, 80.0f)]];
		[self.addToCartButton setupAsBlackButton];
		self.addToCartButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.addToCartButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[self.addToCartButton setTitle:@"ADD\nTO\nCART" forState:UIControlStateNormal];
		[self.addToCartButton addTarget:self action:@selector(handleAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
		[self.roundedView addSubview:self.addToCartButton];
	}
	
	if (self.exitButton == nil) {
		[self setExitButton:[[MOGlassButton alloc] initWithFrame:CGRectMake(134.0f, cy, 80.0f, 80.0f)]];
		[self.exitButton setupAsBlackButton];
		self.exitButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.exitButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[self.exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
		[self.exitButton addTarget:self action:@selector(handleExitButton:) forControlEvents:UIControlEventTouchUpInside];
		[self.roundedView addSubview:self.exitButton];
	}
	
	if (self.addQuantityView == nil) {
		[self setAddQuantityView:[[GradientView alloc] initWithFrame:CGRectMake(26.0f, cy, 188.0f, 80.0f)]];
		[self.addQuantityView.layer setCornerRadius:5.0f];
		[self.addQuantityView.layer setMasksToBounds:YES];
		[self.addQuantityView.layer setBorderWidth:1.0f];
		[self.addQuantityView.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[self.addQuantityView setStart:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0] andEndColor:[UIColor blackColor]];
		
		[self setAddQuantityField:[[ExtUITextField alloc] initWithFrame:CGRectMake(15.0f, 20.0f, 90.0f, 40.0f)]];
		self.addQuantityField.textColor = [UIColor blackColor];
		self.addQuantityField.borderStyle = UITextBorderStyleRoundedRect;
		self.addQuantityField.textAlignment = UITextAlignmentCenter;
		self.addQuantityField.clearsOnBeginEditing = YES;
		self.addQuantityField.placeholder = @"Quantity";
		self.addQuantityField.tagName = @"AddQuantity";
		self.addQuantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.addQuantityField.returnKeyType = UIReturnKeyGo;
		self.addQuantityField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		self.addQuantityField.delegate = self;
		[self.addQuantityView addSubview:self.addQuantityField];
		
		[self setAddQuantityUnitsLabel:[[UILabel alloc] initWithFrame:CGRectMake(120.0f, 20.0f, 53.0f, 40.0f)]];
		self.addQuantityUnitsLabel.textAlignment = UITextAlignmentCenter;
		self.addQuantityUnitsLabel.textColor = [UIColor whiteColor];
		self.addQuantityUnitsLabel.backgroundColor = [UIColor clearColor];
		[self.addQuantityView addSubview:self.addQuantityUnitsLabel];
		
	}
	
	[self updateDisplayValues];

}

- (void)updateDisplayValues {
	if (self.productItem != nil) {
		ProductItem *pi = (ProductItem *)self.productItem;
		self.skuLabel.text = [pi.sku stringValue];
		self.descriptionLabel.text = pi.description;
		self.priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [self.priceFormatter stringFromNumber:pi.retailPrice], pi.primaryUnitOfMeasure];
		
		self.storeIdLabel.text = [pi.storeId stringValue];
		self.storeAvailableLabel.text = [NSString stringWithFormat:@"%@ available", [self.availableFormatter stringFromNumber:pi.storeAvailability]];
		self.storeOnHandLabel.text = [NSString stringWithFormat:@"%@ on hand", @"0.00"];
		// If availablity is less than zero. Unfortunately that is the way you have to do it with NSDecimailNumbers
		if ([pi.storeAvailability compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
			self.storeInfo.backgroundColor = UNAVAILABLE_COLOR;
		}
		self.warehouseIdLabel.text = @"000";
		self.warehouseAvailableLabel.text = [NSString stringWithFormat:@"%@ available", [self.availableFormatter stringFromNumber:pi.distributionCenterAvailability]];
		self.warehouseOnHandLabel.text = [NSString stringWithFormat:@"%@ on hand", @"0.00"];
		if ([pi.distributionCenterAvailability compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
			self.warehouseInfo.backgroundColor = UNAVAILABLE_COLOR;
		}
	}
}

- (void)handleExitButton:(id)sender {
	if (viewDelegate != nil && [viewDelegate respondsToSelector:@selector(cancelAddItem:)]) {
		[viewDelegate cancelAddItem:self];
	}
}

- (void)handleAddToCartButton:(id)sender {
	[self addKeyboardListeners];
	ProductItem *pi = (ProductItem *)self.productItem;
	self.addQuantityUnitsLabel.text = pi.primaryUnitOfMeasure;
	[self.roundedView addSubview:self.addQuantityView];
}

#pragma mark -
#pragma mark ExtUITextField delegates
- (BOOL)textFieldShouldBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	 return YES;
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
}

- (void)textFieldDidEndEditing:(ExtUITextField *)textField {
	[self removeKeyboardListeners];
	self.currentFirstResponder = nil;
	ProductItem *pi = (ProductItem *)self.productItem;
	NSDecimalNumber *quantity = [NSDecimalNumber decimalNumberWithString:textField.text];
	if (viewDelegate != nil && [viewDelegate respondsToSelector:@selector(addItem:orderQuantity:ofUnits:)]) {
		[viewDelegate addItem:self orderQuantity:quantity ofUnits:pi.primaryUnitOfMeasure];
	}
	
}

- (void)addKeyboardListeners {
	NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
	[noteCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[noteCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) removeKeyboardListeners {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
}

#pragma mark -
#pragma mark Keyboard Management
- (void)keyboardWillShow:(NSNotification *)notification {

	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	NSDictionary* userInfo = [notification userInfo];
	
	// we don't use SDK constants here to be universally compatible with all SDKs ≥ 3.0
	NSValue* keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"];
	if (!keyboardFrameValue) {
		keyboardFrameValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
	}
	
	// Reduce the tableView height by the part of the keyboard that actually covers the tableView
	CGRect windowRect = [[UIApplication sharedApplication] keyWindow].bounds;
	if (UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation ) {
		windowRect = [LayoutUtils swapRect:windowRect];
	}
	
	UITextField *tf = (UITextField *)self.currentFirstResponder;
	
	CGRect viewRectAbsolute = [tf convertRect:tf.bounds toView:[[UIApplication sharedApplication] keyWindow]];
	if (UIInterfaceOrientationLandscapeLeft == orientation ||UIInterfaceOrientationLandscapeRight == orientation ) {
		viewRectAbsolute = [LayoutUtils swapRect:viewRectAbsolute];
	}
	
	CGRect frame = self.frame;
	CGRect keyboardRect = [keyboardFrameValue CGRectValue];
	
	previousViewOriginY = frame.origin.y;
	
	CGFloat adjustUpBy = (windowRect.size.height - keyboardRect.size.height) - (CGRectGetMaxY(viewRectAbsolute) + 10.0f);
	
	if (adjustUpBy < 0) {
		frame.origin.y = adjustUpBy;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		self.frame = frame;
		[UIView commitAnimations];
	}
	// iOS 3 sends hide and show notifications right after each other
	// when switching between textFields, so cancel -scrollToOldPosition requests
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
		

}

- (void)keyboardWillHide:(NSNotification *)notification {
	
	NSDictionary* userInfo = [notification userInfo];
	
	CGRect frame = self.frame;
	if (frame.origin.y != previousViewOriginY) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
		[UIView setAnimationCurve:[[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
		frame.origin.y = previousViewOriginY;
		self.frame = frame;
		[UIView commitAnimations];
		previousViewOriginY = 0.0f;
	}
}


@end
