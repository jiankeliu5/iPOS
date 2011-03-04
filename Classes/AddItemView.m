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
#import "DistributionCenter.h"

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

// Our delegate to hand off to when we either cancel or enter a quantity.
@synthesize viewDelegate;

// Hook for who is responding, used to slide textfields up when keyboard shows
@synthesize currentFirstResponder;

#pragma mark Constructors
- (id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	availableFormatter = [[NSNumberFormatter alloc] init];
	[availableFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[availableFormatter setMaximumFractionDigits:2];
	[availableFormatter setMinimumFractionDigits:2];
	
    return self;
}

- (void) dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	
	[self setCurrentFirstResponder:nil];
	
	[self setViewDelegate:nil];
	
	[priceFormatter release];
	priceFormatter = nil;
	
	[availableFormatter release];
	availableFormatter = nil;
	
	[productItem release];
	productItem = nil;
	
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
	if (roundedView == nil) {
		roundedView = [[GradientView alloc] initWithFrame:CGRectMake(ROUND_VIEW_X, ROUND_VIEW_Y, ROUND_VIEW_WIDTH, ROUND_VIEW_HEIGHT)];
		[roundedView.layer setCornerRadius:5.0f];
		[roundedView.layer setMasksToBounds:YES];
		[roundedView.layer setBorderWidth:1.0f];
		[roundedView.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[roundedView setStart:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] andEndColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
		[self addSubview:roundedView];
		[roundedView release];
	}
	
	// Keep track of how far down we are in the view
	CGFloat cy = 10.0f;
	
	if (skuLabel == nil) {
		skuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)];
		skuLabel.backgroundColor = [UIColor clearColor];
		skuLabel.textColor = [UIColor blackColor];
		skuLabel.textAlignment = UITextAlignmentCenter;
		skuLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		skuLabel.text = @"NA";
		[roundedView addSubview:skuLabel];
		[skuLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (descriptionLabel == nil) {
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor blackColor];
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		descriptionLabel.text = @"NA";
		[roundedView addSubview:descriptionLabel];
		[descriptionLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (priceLabel == nil) {
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, BIG_LABEL_HEIGHT)];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.textColor = [UIColor blackColor];
		priceLabel.textAlignment = UITextAlignmentCenter;
		priceLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		priceLabel.text = @"NA";
		[roundedView addSubview:priceLabel];
		[priceLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT + 10.0f;
	

	if (storeInfoView == nil) {
		storeInfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, AVAILABILITY_VIEW_HEIGHT)];
		[roundedView addSubview:storeInfoView];
		[storeInfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;

	if (dc1InfoView == nil) {
		dc1InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, AVAILABILITY_VIEW_HEIGHT)];
		[roundedView addSubview:dc1InfoView];
		[dc1InfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;

	if (dc2InfoView == nil) {
		dc2InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, AVAILABILITY_VIEW_HEIGHT)];
		[roundedView addSubview:dc2InfoView];
		[dc2InfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;
	
	if (dc3InfoView == nil) {
		dc3InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, ROUND_VIEW_WIDTH, AVAILABILITY_VIEW_HEIGHT)];
		[roundedView addSubview:dc3InfoView];
		[dc3InfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT + 15.0f;
	
	if (addToCartButton == nil) {
		addToCartButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(46.0f, cy, 80.0f, 80.0f)];
		[addToCartButton setupAsBlackButton];
		addToCartButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		addToCartButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[addToCartButton setTitle:@"ADD\nTO\nCART" forState:UIControlStateNormal];
		// TODO Re-enable when we get the order cart functionality in
		// [addToCartButton addTarget:self action:@selector(handleAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
		[roundedView addSubview:addToCartButton];
		[addToCartButton release];
	}
	
	if (exitButton == nil) {
		exitButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(154.0f, cy, 80.0f, 80.0f)];
		[exitButton setupAsBlackButton];
		exitButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		exitButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
		[exitButton addTarget:self action:@selector(handleExitButton:) forControlEvents:UIControlEventTouchUpInside];
		[roundedView addSubview:exitButton];
		[exitButton release];
	}
	
	if (addQuantityView == nil) {
		addQuantityView = [[GradientView alloc] initWithFrame:CGRectMake(46.0f, cy, 188.0f, 80.0f)];
		[addQuantityView.layer setCornerRadius:5.0f];
		[addQuantityView.layer setMasksToBounds:YES];
		[addQuantityView.layer setBorderWidth:1.0f];
		[addQuantityView.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[addQuantityView setStart:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0] andEndColor:[UIColor blackColor]];
		
		addQuantityField = [[ExtUITextField alloc] initWithFrame:CGRectMake(15.0f, 20.0f, 90.0f, 40.0f)];
		addQuantityField.textColor = [UIColor blackColor];
		addQuantityField.borderStyle = UITextBorderStyleRoundedRect;
		addQuantityField.textAlignment = UITextAlignmentCenter;
		addQuantityField.clearsOnBeginEditing = YES;
		addQuantityField.placeholder = @"Quantity";
		addQuantityField.tagName = @"AddQuantity";
		addQuantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		addQuantityField.returnKeyType = UIReturnKeyGo;
		addQuantityField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		addQuantityField.delegate = self;
		[addQuantityView addSubview:addQuantityField];
		[addQuantityField release];
		
		addQuantityUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0f, 20.0f, 53.0f, 40.0f)];
		addQuantityUnitsLabel.textAlignment = UITextAlignmentCenter;
		addQuantityUnitsLabel.textColor = [UIColor whiteColor];
		addQuantityUnitsLabel.backgroundColor = [UIColor clearColor];
		[addQuantityView addSubview:addQuantityUnitsLabel];
		[addQuantityUnitsLabel release];
		
	}
	
	[self updateDisplayValues];

}

- (void)updateDisplayValues {
	if (self.productItem != nil) {
		ProductItem *pi = (ProductItem *)self.productItem;
		skuLabel.text = [pi.sku stringValue];
		descriptionLabel.text = pi.description;
		priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [priceFormatter stringFromNumber:pi.retailPrice], pi.primaryUnitOfMeasure];
		
		[storeInfoView setStoreAvailabilityAtStoreId:pi.store.storeId withAvailable:pi.store.availability];
		
		if ([pi.distributionCenterList count] > 0) {
			DistributionCenter *dc1 = (DistributionCenter *)[pi.distributionCenterList objectAtIndex:0];
			[dc1InfoView setDistributionCenter:dc1];
		}
		
		if ([pi.distributionCenterList count] > 1) {
			DistributionCenter *dc2 = (DistributionCenter *)[pi.distributionCenterList objectAtIndex:1];
			[dc2InfoView setDistributionCenter:dc2];
		}
		
		if ([pi.distributionCenterList count] > 2) {
			DistributionCenter *dc3 = (DistributionCenter *)[pi.distributionCenterList objectAtIndex:2];
			[dc3InfoView setDistributionCenter:dc3];
		}

	}
}

- (void)handleExitButton:(id)sender {
	if (viewDelegate != nil && [viewDelegate respondsToSelector:@selector(cancelAddItem:)]) {
		// This was set up in loadView but if we don't choose add to cart it is not released
		// when added to the main view, so need to make sure to do it here.
		[addQuantityView release];
		[viewDelegate cancelAddItem:self];
	}
}

- (void)handleAddToCartButton:(id)sender {
	[self addKeyboardListeners];
	ProductItem *pi = (ProductItem *)self.productItem;
	addQuantityUnitsLabel.text = pi.primaryUnitOfMeasure;
	[roundedView addSubview:addQuantityView];
	[addQuantityView release];
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
