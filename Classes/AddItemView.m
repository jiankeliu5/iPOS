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

#import "AlertUtils.h"
#import "AddItemView.h"
#import "LayoutUtils.h"
#import "ProductItem.h"

#import "iPOSFacade.h"

#define ITEM_VIEW_HEIGHT 299.0f

#define ROUND_VIEW_X 20.0f
#define ROUND_VIEW_Y 7.0f
#define ROUND_VIEW_WIDTH 280.0f
#define ROUND_VIEW_HEIGHT 402.0f
#define KEYBOARD_TOOLBAR_HEIGHT 44.0f
#define KEYBOARD_TOOLBAR_WIDTH 320.0f

#define MOVE_OFF_TO_LEFT_X -280.0f
#define MOVE_OFF_TO_RIGHT_X 280.0f

#define ADD_QUANTITYVIEW_WIDTH 188.0f
#define ADD_QUANTITYVIEW_HEIGHT 80.0f
#define ADD_QUANTITYVIEW_W_SWITCH_WIDTH 220.0f
#define ADD_QUANTITYVIEW_W_SWITCH_HEIGHT 100.0f
#define ADD_QUANTITYVIEW_MARGIN_LEFT 46.0f
#define ADD_QUANTITYVIEW_W_SWITCH_MARGIN_LEFT 30.0f
#define ADD_QUANTITYVIEW_MARGIN_TOP 10.0f


#pragma mark -
#pragma mark Private Interface
@interface AddItemView ()
- (void) updateDisplayValues;

- (void) handleDefaultFullBoxesSwitch: (id) sender;

- (void) handleExitButton:(id)sender;
- (void) handleAddToCartButton:(id)sender;

- (void) addKeyboardListeners;
- (void) removeKeyboardListeners;
- (void) dismissKeyboard:(id)sender;
- (void) dismissKeyboardWithCancel:(id)sender;

- (void) slideToItemDetails;
- (void) slideToItemList;
@end

#pragma mark -
@implementation AddItemView

// This is our data item to display and work with
@synthesize productItemList, itemToAdd;

// Our delegate to hand off to when we either cancel or enter a quantity.
@synthesize viewDelegate;

// Hook for who is responding, used to slide textfields up when keyboard shows
@synthesize currentFirstResponder;

@synthesize keyboardCancelled;

#pragma mark Constructors
- (id) initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
	
	quantityFormatter = [[NSNumberFormatter alloc] init];
	[quantityFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[quantityFormatter setGeneratesDecimalNumbers:YES];
	
    return self;
}

- (void) dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	
	[self setCurrentFirstResponder:nil];
	
	[quantityFormatter release];
	quantityFormatter = nil;
	
    [productItemList release];
    productItemList = nil;
    
    [itemToAdd release];
    itemToAdd = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setProductItemList:(NSArray *)productList {
	// This basically does the same as the standard synthesized
	// retain setter, but we have to override it in order to
	// make ourselves redisplay when we get a new productItem 
	// set.
	if (productItemList != productList) {
        // If the list of products is only 1, default the item to add to the first element
        // and release the list
        if (productList && [productList count] == 1) {
            itemToAdd = [(ProductItem *) [productList objectAtIndex:0] retain];
            
            [productItemList release];
            productItemList = nil;
        } else {
            [productItemList release];
            productItemList = [productList retain];
            
            [itemToAdd release];
            itemToAdd = nil;
        }

        if ([self.subviews count] > 0) {
            [self updateDisplayValues];
            [self setNeedsDisplay];
        }
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
	CGFloat cy = 0;
    
	cy += ITEM_VIEW_HEIGHT + 8.0f;
	
	if (addToCartButton == nil) {
		addToCartButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(46.0f, cy, 80.0f, 80.0f)];
		[addToCartButton setupAsBlackButton];
		addToCartButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
		addToCartButton.titleLabel.textAlignment = UITextAlignmentCenter;
		[addToCartButton setTitle:@"ADD\nTO\nCART" forState:UIControlStateNormal];
		[addToCartButton addTarget:self action:@selector(handleAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
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
		addQuantityView = [[GradientView alloc] initWithFrame:CGRectMake(30.0f, cy, ADD_QUANTITYVIEW_WIDTH, ADD_QUANTITYVIEW_HEIGHT)];
		[addQuantityView.layer setCornerRadius:5.0f];
		[addQuantityView.layer setMasksToBounds:YES];
		[addQuantityView.layer setBorderWidth:1.0f];
		[addQuantityView.layer setBorderColor:[[UIColor blackColor] CGColor]];
		[addQuantityView setStart:[UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0] andEndColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
		addQuantityView.hidden = YES;
		
		addQuantityField = [[ExtUITextField alloc] initWithFrame:CGRectMake(15.0f, ADD_QUANTITYVIEW_MARGIN_TOP, 90.0f, 40.0f)];
		addQuantityField.textColor = [UIColor blackColor];
		addQuantityField.borderStyle = UITextBorderStyleRoundedRect;
		addQuantityField.textAlignment = UITextAlignmentCenter;
		addQuantityField.clearsOnBeginEditing = YES;
		addQuantityField.placeholder = @"Quantity";
		addQuantityField.tagName = @"AddQuantity";
		addQuantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		addQuantityField.returnKeyType = UIReturnKeyGo;
		addQuantityField.keyboardType = UIKeyboardTypeDecimalPad;
		addQuantityField.delegate = self;
		UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, KEYBOARD_TOOLBAR_WIDTH, KEYBOARD_TOOLBAR_HEIGHT)] autorelease];
		keyboardToolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
		keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
		UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissKeyboardWithCancel:)] autorelease];
		UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard:)] autorelease];
		UIBarButtonItem *flex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
		NSArray *items = [[[NSArray alloc] initWithObjects:doneButton, flex, cancelButton, nil] autorelease];
		[keyboardToolbar setItems:items];
		[addQuantityField setInputAccessoryView:keyboardToolbar];
		[addQuantityView addSubview:addQuantityField];
  	    [addQuantityField release];
		
		addQuantityUnitsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120.0f, ADD_QUANTITYVIEW_MARGIN_TOP, 53.0f, 40.0f)];
		addQuantityUnitsLabel.textAlignment = UITextAlignmentCenter;
		addQuantityUnitsLabel.textColor = [UIColor whiteColor];
		addQuantityUnitsLabel.backgroundColor = [UIColor clearColor];
		[addQuantityView addSubview:addQuantityUnitsLabel];
    	[addQuantityUnitsLabel release];
        
        addQuantityFullBoxesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, ADD_QUANTITYVIEW_MARGIN_TOP+40.0f, 90.0f, 40.0f)];
        addQuantityFullBoxesLabel.text = @"Full Boxes";
		addQuantityFullBoxesLabel.textAlignment = UITextAlignmentLeft;
		addQuantityFullBoxesLabel.textColor = [UIColor whiteColor];
		addQuantityFullBoxesLabel.backgroundColor = [UIColor clearColor];
        addQuantityFullBoxesLabel.hidden = YES;
		[addQuantityView addSubview:addQuantityFullBoxesLabel];
    	[addQuantityFullBoxesLabel release];
        
        addQuantityFullBoxSwitch = [[UISwitch alloc] initWithFrame: CGRectMake(120.0f, ADD_QUANTITYVIEW_MARGIN_TOP+40.0f+5.0f, 0, 0)];
        [addQuantityFullBoxSwitch addTarget:self action:@selector(handleDefaultFullBoxesSwitch:) forControlEvents:UIControlEventValueChanged];
        addQuantityFullBoxSwitch.on = YES;
        addQuantityFullBoxSwitch.hidden = YES;
        [addQuantityView addSubview:addQuantityFullBoxSwitch];
        [addQuantityFullBoxSwitch release];

		[roundedView addSubview:addQuantityView];
        
        [addQuantityView release];		
	}
	
	self.keyboardCancelled = NO;
	
	[self updateDisplayValues];
}

- (void)updateDisplayValues {    
    // Add the Item Detail View if it not in the layout
    if (itemDetailView == nil) {
        itemDetailView = [[ItemDetailView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ROUND_VIEW_WIDTH, ITEM_VIEW_HEIGHT)];       
        itemDetailView.delegate = self;
        [roundedView addSubview:itemDetailView];
        [itemDetailView release];
    }
    
    // Determine if the list view needs to be added
    if (itemToAdd != nil) {
        itemDetailView.item = itemToAdd;
        addToCartButton.enabled = YES;
        
        // Move Item List View off to the left of main view
        if (itemListView) {
            CGRect slideOutFrame = itemListView.frame;
            slideOutFrame.origin.x = MOVE_OFF_TO_LEFT_X;
            itemListView.frame = slideOutFrame;
        }
    } else if (productItemList != nil) {
        if (itemListView == nil) {
            itemListView = [[ItemListView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ROUND_VIEW_WIDTH, ITEM_VIEW_HEIGHT)];
            itemListView.viewDelegate = self;
            [roundedView addSubview:itemListView];
            [itemListView release];
        }
        
        itemListView.itemList = productItemList;
        addToCartButton.enabled = NO;
        
        // Move Item Detail View off to the right
        if (itemDetailView) {
            CGRect slideOutFrame = itemDetailView.frame;
            slideOutFrame.origin.x = MOVE_OFF_TO_RIGHT_X;
            itemDetailView.frame = slideOutFrame;
        }
    }
}

- (void)handleExitButton:(id)sender {
    if ([exitButton.titleLabel.text isEqualToString:@"EXIT"]) {
        if (viewDelegate != nil && [viewDelegate respondsToSelector:@selector(cancelAddItem:)]) {
            // This used to have a release of addQuantityView.  This is not necessary since removing
            // this view from the parent view will release all subviews of this object.
            [viewDelegate cancelAddItem:self];
        }
    } else if ([exitButton.titleLabel.text isEqualToString:@"BACK"]) {
        [self slideToItemList];
    }       
}

- (void)handleAddToCartButton:(id)sender {
	[self addKeyboardListeners];
	ProductItem *pi = itemToAdd;
	addQuantityUnitsLabel.text = [pi unitOfMeasureDisplay:[pi getSelectedUOMForDisplay]];
    
    // Do I show the convert to boxes toggle
    CGRect addQuantityFrame = addQuantityView.frame;
    CGRect quantityTextFrame = addQuantityField.frame;
    CGRect quantityLabelFrame = addQuantityUnitsLabel.frame;
    if ([pi isUOMConversionRequired]) {
        addQuantityFrame.origin.x = ADD_QUANTITYVIEW_W_SWITCH_MARGIN_LEFT;
        addQuantityFrame.size.height = ADD_QUANTITYVIEW_HEIGHT+ADD_QUANTITYVIEW_MARGIN_TOP; 
        addQuantityFrame.size.width = ADD_QUANTITYVIEW_W_SWITCH_WIDTH;
        
        quantityLabelFrame.origin.y = ADD_QUANTITYVIEW_MARGIN_TOP;
        quantityTextFrame.origin.y = ADD_QUANTITYVIEW_MARGIN_TOP;
        
        addQuantityFullBoxSwitch.on = pi.defaultToBox;
        addQuantityFullBoxesLabel.hidden = NO;
        addQuantityFullBoxSwitch.hidden = NO;
        
    } else {
        addQuantityFrame.origin.x = ADD_QUANTITYVIEW_MARGIN_LEFT;
        addQuantityFrame.size.height = ADD_QUANTITYVIEW_HEIGHT; 
        addQuantityFrame.size.width = ADD_QUANTITYVIEW_WIDTH;
        
        quantityLabelFrame.origin.y = ADD_QUANTITYVIEW_MARGIN_TOP*2;
        quantityTextFrame.origin.y = ADD_QUANTITYVIEW_MARGIN_TOP*2;
        
        addQuantityFullBoxSwitch.on = pi.defaultToBox;
        addQuantityFullBoxesLabel.hidden = YES;
        addQuantityFullBoxSwitch.hidden = YES;
    }
    addQuantityView.frame = addQuantityFrame;
    addQuantityField.frame = quantityTextFrame;
    addQuantityUnitsLabel.frame = quantityLabelFrame;
    
	addQuantityView.hidden = NO;
}

- (void) handleDefaultFullBoxesSwitch:(id)sender {
    ProductItem *pi = itemToAdd;
    
    if (pi) {
        pi.defaultToBox = addQuantityFullBoxSwitch.on;
    }
}

#pragma mark -
#pragma mark ItemListViewDelegate
- (void) selectItem:(ProductItem *)item {
    NSArray *itemList = self.productItemList;
    if (item && itemList && [itemList containsObject:item]) {
        
        // Fetch the details for the item and display them
        NSString *sku = [NSString stringWithFormat:@"%@", item.sku];
        
        self.itemToAdd = [[iPOSFacade sharedInstance] lookupProductItem:sku];
        
        if (itemToAdd == nil) {
            [AlertUtils showModalAlertMessage:[NSString stringWithFormat: @"Problem getting item details with sku '%@'", sku]]; 
        } else {
            [self slideToItemDetails];
        }
    }
}

#pragma mark -
#pragma mark ItemDetailViewDelegate
- (void) unitOfMeasureExchange:(ItemDetailView *)itemDetailView selectedUOM:(NSString *)uom {
    if (!addQuantityView.hidden) {
        ProductItem *pi = itemToAdd;
        addQuantityUnitsLabel.text = [pi unitOfMeasureDisplay:[pi getSelectedUOMForDisplay]];
    }
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
	
	NSDecimalNumber *quantity = ([textField.text length] > 0) ? (NSDecimalNumber *)[quantityFormatter numberFromString:textField.text] : nil;
	if (self.keyboardCancelled == NO && quantity != nil) {
		ProductItem *pi = itemToAdd;
		if (viewDelegate != nil && [viewDelegate respondsToSelector:@selector(addItem:orderQuantity:ofUnits:)]) {
			[viewDelegate addItem:self orderQuantity:quantity ofUnits:pi.primaryUnitOfMeasure];
		}
	} else {
		addQuantityView.hidden = YES;
		self.keyboardCancelled = NO;
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

- (void) dismissKeyboard:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
}

- (void) dismissKeyboardWithCancel:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		// Have to let the text field delegate know we cancelled.
		self.keyboardCancelled = YES;
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

#pragma mark -
#pragma mark Slide Animation Methods
- (void) slideToItemList {
    if (itemDetailView && itemListView) {
        CGRect slideOutFrame = itemDetailView.frame;
        CGRect slideInFrame = itemListView.frame;
        
        slideOutFrame.origin.x = 0.0f;
        slideInFrame.origin.x = MOVE_OFF_TO_LEFT_X;
        
        itemDetailView.item = nil;
        
        // Deselect any item from the search results
        [itemListView deselectTableRow];
        
        [UIView beginAnimations:nil context:nil];  
        [UIView setAnimationDuration:0.3];
            slideOutFrame.origin.x = MOVE_OFF_TO_RIGHT_X;
            slideInFrame.origin.x = 0.0f;
            itemDetailView.frame = slideOutFrame;
            itemListView.frame = slideInFrame;
        [UIView commitAnimations]; 
        
        addToCartButton.enabled = NO;
        [exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
    }
}

- (void) slideToItemDetails {
    if (itemToAdd && itemListView && itemDetailView) {
        CGRect slideOutFrame = itemListView.frame;
        CGRect slideInFrame = itemDetailView.frame;
        
        slideOutFrame.origin.x = 0.0f;
        slideInFrame.origin.x = MOVE_OFF_TO_RIGHT_X;
        
        itemDetailView.item = itemToAdd;
        itemDetailView.frame = slideInFrame;
        
        [UIView beginAnimations:nil context:nil];  
        [UIView setAnimationDuration:0.3];
            slideOutFrame.origin.x = MOVE_OFF_TO_LEFT_X;
            slideInFrame.origin.x = 0.0f;
            itemListView.frame = slideOutFrame;
            itemDetailView.frame = slideInFrame;
        [UIView commitAnimations]; 
        
        addToCartButton.enabled = YES;
        
        // Change state of exit button
        [exitButton setTitle:@"BACK" forState:UIControlStateNormal];
    }
}


@end
