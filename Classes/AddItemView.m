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

#define MARGIN 10.0f
#define MARGIN_ADDQUANTITY 30.0f

#define BUTTON_SIZE 80.0f
#define BUTTON_SPACING 40.0f

#define ADDQUANTITY_FIELD_HEIGHT 40.0f

#define KEYBOARD_TOOLBAR_HEIGHT 44.0f



#pragma mark -
#pragma mark Private Interface
@interface AddItemView ()

- (void) layoutInPortrait;
- (void) layoutInLandscape;
- (void) layoutAddQuantityView;

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
    
    // Add the rounded view and the container views
    roundedView = [[GradientView alloc] initWithFrame:CGRectZero];
    [roundedView.layer setCornerRadius:5.0f];
    [roundedView.layer setMasksToBounds:YES];
    [roundedView.layer setBorderWidth:1.0f];
    [roundedView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [roundedView setStart:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] andEndColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
    [self addSubview:roundedView];
    [roundedView release];
    
    itemContentView = [[UIView alloc] initWithFrame:CGRectZero];
    itemContentView.backgroundColor = [UIColor whiteColor];
    [roundedView addSubview:itemContentView];
    [itemContentView release];
    
    // Add the tools (Buttons and other controls)
    toolsContentView = [[UIView alloc] initWithFrame:CGRectZero];
    toolsContentView.backgroundColor = [UIColor whiteColor];
    
    addToCartButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [addToCartButton setupAsBlackButton];
    addToCartButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    addToCartButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [addToCartButton setTitle:@"ADD\nTO\nCART" forState:UIControlStateNormal];
    [addToCartButton addTarget:self action:@selector(handleAddToCartButton:) forControlEvents:UIControlEventTouchUpInside];
    [toolsContentView addSubview:addToCartButton];
    [addToCartButton release];

    exitButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
    [exitButton setupAsBlackButton];
    exitButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    exitButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [exitButton setTitle:@"EXIT" forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(handleExitButton:) forControlEvents:UIControlEventTouchUpInside];
    [toolsContentView addSubview:exitButton];
    [exitButton release];
    
    
    addQuantityView = [[GradientView alloc] initWithFrame:CGRectZero];
    [addQuantityView.layer setCornerRadius:5.0f];
    [addQuantityView.layer setMasksToBounds:YES];
    [addQuantityView.layer setBorderWidth:1.0f];
    [addQuantityView.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [addQuantityView setStart:[UIColor colorWithRed:96.0/255.0 green:96.0/255.0 blue:96.0/255.0 alpha:1.0] andEndColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    addQuantityView.hidden = YES;
    
    addQuantityField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
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
    
    UIToolbar *keyboardToolbar = [[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease];
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
    
    addQuantityUnitsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addQuantityUnitsLabel.textAlignment = UITextAlignmentLeft;
    addQuantityUnitsLabel.textColor = [UIColor whiteColor];
    addQuantityUnitsLabel.backgroundColor = [UIColor clearColor];
    [addQuantityView addSubview:addQuantityUnitsLabel];
    [addQuantityUnitsLabel release];
    
    addQuantityFullBoxesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    addQuantityFullBoxesLabel.text = @"Full Boxes";
    addQuantityFullBoxesLabel.textAlignment = UITextAlignmentLeft;
    addQuantityFullBoxesLabel.textColor = [UIColor whiteColor];
    addQuantityFullBoxesLabel.backgroundColor = [UIColor clearColor];
    addQuantityFullBoxesLabel.hidden = YES;
    [addQuantityView addSubview:addQuantityFullBoxesLabel];
    [addQuantityFullBoxesLabel release];
    
    addQuantityFullBoxSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
    [addQuantityFullBoxSwitch addTarget:self action:@selector(handleDefaultFullBoxesSwitch:) forControlEvents:UIControlEventValueChanged];
    addQuantityFullBoxSwitch.on = YES;
    addQuantityFullBoxSwitch.hidden = YES;
    [addQuantityView addSubview:addQuantityFullBoxSwitch];
    [addQuantityFullBoxSwitch release];
    
    [toolsContentView addSubview:addQuantityView];

    [roundedView addSubview:toolsContentView];
    [toolsContentView release];
	
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
//=========================================================== 
// - setItemToAdd:
//=========================================================== 
- (void)setItemToAdd:(ProductItem *)anItemToAdd {
    if (itemToAdd != anItemToAdd) {
        [anItemToAdd retain];
        [itemToAdd release];
        itemToAdd = anItemToAdd;
        
        // Initialize the details view if it is not 
        if (itemDetailView == nil) {
            itemDetailView = [[ItemDetailView alloc] initWithFrame:itemContentView.bounds];       
            itemDetailView.delegate = self;
            [itemContentView addSubview:itemDetailView];
            [itemDetailView release];
        }
    }
}

//=========================================================== 
// - setProductItemList:
//=========================================================== 
- (void) setProductItemList:(NSArray *)productList {
	// This basically does the same as the standard synthesized
	// retain setter, but we have to override it in order to
	// make ourselves redisplay when we get a new productItem 
	// set.
	if (productItemList != productList) {
        // If the list of products is only 1, default the item to add to the first element
        // and release the list
        if (productList && [productList count] == 1) {
            self.itemToAdd = (ProductItem *) [productList objectAtIndex:0];
            
            [productItemList release];
            productItemList = nil;
        } else {
            [productItemList release];
            productItemList = [productList retain];
            
            self.itemToAdd = nil;
            
            if (itemListView == nil) {
                itemListView = [[ItemListView alloc] initWithFrame:itemContentView.bounds];
                itemListView.viewDelegate = self;
                [itemContentView addSubview:itemListView];
                [itemListView release];
            }
        }

        if ([self.subviews count] > 0) {
            [self updateDisplayValues];
            [self setNeedsDisplay];
        }
	}
}

#pragma mark -
#pragma mark Layout Methods
- (void) layoutSubviews {
    if (self.bounds.size.width > self.bounds.size.height) {
        [self layoutInLandscape];
    } else {
        [self layoutInPortrait];
    }
    
    [self layoutAddQuantityView];
    
	self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
    self.keyboardCancelled = NO;
    [self updateDisplayValues];
	}

- (void) layoutInPortrait {
    CGRect bounds = self.bounds;  
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    // Layout the container views
    CGRect topContainerRect = CGRectZero;
    CGRect bottomContainerRect = CGRectZero;
    
    roundedView.frame = CGRectMake(MARGIN, MARGIN, width - MARGIN*2, height - MARGIN*2);
    
    CGRectDivide(CGRectMake(0, 0,roundedView.frame.size.width, roundedView.frame.size.height), &topContainerRect, &bottomContainerRect, height * 0.65, CGRectMinYEdge);
    
    itemContentView.frame = topContainerRect;
    toolsContentView.frame = bottomContainerRect;
    
    // Resize the Item Content
    if (itemDetailView) {
        itemDetailView.frame = itemContentView.frame;
    }
    if (itemListView) {
        itemListView.frame = itemContentView.frame;
    }
    
    // Resize the tools content
    CGRect addToCartRect = CGRectZero;
    CGRect exitRect = CGRectZero;
    CGRectDivide(toolsContentView.frame, &addToCartRect, &exitRect, toolsContentView.frame.size.width * 0.5, CGRectMinXEdge);
    
    addToCartButton.frame = CGRectMake(addToCartRect.size.width - BUTTON_SIZE - BUTTON_SPACING/2, 
                                       (addToCartRect.size.height - BUTTON_SIZE)/2, 
                                      BUTTON_SIZE, BUTTON_SIZE);
    exitButton.frame = CGRectMake(exitRect.origin.x + BUTTON_SPACING/2, 
                                  (exitRect.size.height - BUTTON_SIZE)/2, 
                                  BUTTON_SIZE, BUTTON_SIZE);   
}


- (void) layoutInLandscape {
    CGRect bounds = self.bounds;  
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    // Layout the container views
    CGRect leftContainerRect = CGRectZero;
    CGRect rightContainerRect = CGRectZero;
    
    roundedView.frame = CGRectMake(MARGIN, MARGIN, width - MARGIN*2, height - MARGIN*2);
    
    CGRectDivide(CGRectMake(0, 0,roundedView.frame.size.width, roundedView.frame.size.height), &leftContainerRect, &rightContainerRect, width * 0.625, CGRectMinXEdge);
    
    itemContentView.frame = leftContainerRect;
    toolsContentView.frame = rightContainerRect;
    
    // Resize the Item Content
    if (itemDetailView) {
        itemDetailView.frame = itemContentView.frame;
    }
    if (itemListView) {
        itemListView.frame = itemContentView.frame;
    }
    
    CGRect addToCartRect = CGRectZero;
    CGRect exitRect = CGRectZero;
    CGRectDivide(toolsContentView.frame, &addToCartRect, &exitRect, toolsContentView.frame.size.height * 0.5, CGRectMinYEdge);
    
    addToCartButton.frame = CGRectMake((addToCartRect.size.width - BUTTON_SIZE)/2, 
                                       addToCartRect.size.height - BUTTON_SIZE - BUTTON_SPACING/2, 
                                       BUTTON_SIZE, BUTTON_SIZE);
    exitButton.frame = CGRectMake((exitRect.size.width - BUTTON_SIZE)/2, 
                                  exitRect.origin.y + BUTTON_SPACING/2, 
                                  BUTTON_SIZE, BUTTON_SIZE);
    
    // Resize the addQuantity Fields
    addQuantityField.inputAccessoryView.frame = CGRectMake(0.0f, 0.0f, width, KEYBOARD_TOOLBAR_HEIGHT);
}

- (void) layoutAddQuantityView {
    CGRect bounds = self.bounds;  
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
     
    
    addQuantityField.inputAccessoryView.frame = CGRectMake(0.0f, 0.0f, width, KEYBOARD_TOOLBAR_HEIGHT);
    
    CGRect beginRect = CGRectZero;
    CGRect addQuantityLabelRect = CGRectZero;
    CGRect addQuantityFieldRect = CGRectZero;
    CGRect addQuantityFullBoxLabelRect = CGRectZero;
    CGRect addQuantityFullBoxSwitchRect = CGRectZero;
    
    if (width < height) {
        addQuantityView.frame = CGRectMake(MARGIN_ADDQUANTITY, MARGIN_ADDQUANTITY/2, toolsContentView.frame.size.width - MARGIN_ADDQUANTITY*2, toolsContentView.frame.size.height - MARGIN_ADDQUANTITY);   
        beginRect = CGRectMake(0, 0, addQuantityView.frame.size.width, addQuantityView.frame.size.height);
        
        if (!addQuantityFullBoxesLabel.hidden) {
            // Divide 2 rows, 2 cols
            CGRectDivide(beginRect, &addQuantityFieldRect, &addQuantityLabelRect, beginRect.size.width * 0.5, CGRectMinXEdge);
            CGRectDivide(addQuantityLabelRect, &addQuantityLabelRect, &addQuantityFullBoxSwitchRect, beginRect.size.height * 0.5, CGRectMinYEdge);
            CGRectDivide(addQuantityFieldRect, &addQuantityFieldRect, &addQuantityFullBoxLabelRect, beginRect.size.height * 0.5, CGRectMinYEdge);
        } else {
            // Divide 1 row, 2 cols
            CGRectDivide(beginRect, &addQuantityFieldRect, &addQuantityLabelRect, beginRect.size.width * 0.5, CGRectMinXEdge);
        }
        
        // Lay out the views
        addQuantityField.frame = CGRectMake(MARGIN*3, (addQuantityFieldRect.size.height - ADDQUANTITY_FIELD_HEIGHT)/2, addQuantityFieldRect.size.width - MARGIN*3, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityUnitsLabel.frame = CGRectMake(addQuantityLabelRect.origin.x + MARGIN*2, (addQuantityLabelRect.size.height - ADDQUANTITY_FIELD_HEIGHT)/2, addQuantityLabelRect.size.width, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityUnitsLabel.textAlignment = UITextAlignmentLeft;
        
        addQuantityFullBoxesLabel.frame = CGRectMake(MARGIN*3, addQuantityFieldRect.size.height + (addQuantityFullBoxLabelRect.size.height - ADDQUANTITY_FIELD_HEIGHT)/2, 
                                                     addQuantityFullBoxLabelRect.size.width - MARGIN*3, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityFullBoxSwitch.frame = CGRectMake(addQuantityFullBoxSwitchRect.origin.x + MARGIN, addQuantityLabelRect.size.height + (addQuantityFullBoxSwitchRect.size.height - ADDQUANTITY_FIELD_HEIGHT)/2 + MARGIN, 
                                                    addQuantityFullBoxSwitchRect.size.width, 0);
    }
    
    if (width > height) {
        addQuantityView.frame = CGRectMake(MARGIN_ADDQUANTITY/2, MARGIN_ADDQUANTITY/2, toolsContentView.frame.size.width - MARGIN_ADDQUANTITY, toolsContentView.frame.size.height - MARGIN_ADDQUANTITY);   
        beginRect = CGRectMake(0, 0, addQuantityView.frame.size.width, addQuantityView.frame.size.height);
        
        if (!addQuantityFullBoxesLabel.hidden) {
            // Divide 4 rows
            CGRectDivide(beginRect, &addQuantityFieldRect, &addQuantityLabelRect, beginRect.size.height * 0.25, CGRectMinYEdge);
            CGRectDivide(addQuantityLabelRect, &addQuantityLabelRect, &addQuantityFullBoxLabelRect, addQuantityLabelRect.size.height * 0.33, CGRectMinYEdge);
            CGRectDivide(addQuantityFullBoxLabelRect, &addQuantityFullBoxLabelRect, &addQuantityFullBoxSwitchRect, addQuantityFullBoxLabelRect.size.height * 0.5, CGRectMinYEdge);
        } else {
            // Divide 2 rows
            CGRectDivide(beginRect, &addQuantityFieldRect, &addQuantityLabelRect, beginRect.size.height * 0.5, CGRectMinYEdge);
        }
        
        // Lay out the views
        addQuantityField.frame = CGRectMake(MARGIN, addQuantityFieldRect.size.height - ADDQUANTITY_FIELD_HEIGHT, addQuantityFieldRect.size.width - MARGIN*2, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityUnitsLabel.frame = CGRectMake(MARGIN, addQuantityLabelRect.origin.y, addQuantityLabelRect.size.width, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityUnitsLabel.textAlignment = UITextAlignmentLeft;
        
        addQuantityFullBoxesLabel.frame = CGRectMake(MARGIN, addQuantityFullBoxLabelRect.origin.y + (addQuantityFullBoxLabelRect.size.height - ADDQUANTITY_FIELD_HEIGHT), 
                                                     addQuantityFullBoxLabelRect.size.width - MARGIN*2, ADDQUANTITY_FIELD_HEIGHT);
        addQuantityFullBoxSwitch.frame = CGRectMake(MARGIN, addQuantityFullBoxSwitchRect.origin.y,
                                                    addQuantityFullBoxSwitchRect.size.width, 0);
    }

    
}

#pragma mark -
#pragma mark Methods
- (void)updateDisplayValues {    
    // Determine if the list view needs to be added
    if (itemToAdd != nil) {
        itemDetailView.item = itemToAdd;
        addToCartButton.enabled = YES;
        
        // Move Item List View off to the left of main view
        if (itemListView) {
            CGRect slideOutFrame = itemListView.frame;
            slideOutFrame.origin.x = - (itemContentView.bounds.size.width);
            itemListView.frame = slideOutFrame;
        }
    } else if (productItemList != nil) {
        itemListView.itemList = productItemList;
        addToCartButton.enabled = NO;
        
        // Move Item Detail View off to the right
        if (itemDetailView) {
            CGRect slideOutFrame = itemDetailView.frame;
            slideOutFrame.origin.x = itemContentView.bounds.size.width;
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
    if ([pi isUOMConversionRequired]) {
      addQuantityFullBoxSwitch.on = pi.defaultToBox;
        addQuantityFullBoxesLabel.hidden = NO;
        addQuantityFullBoxSwitch.hidden = NO;
        
    } else {
        addQuantityFullBoxSwitch.on = pi.defaultToBox;
        addQuantityFullBoxesLabel.hidden = YES;
        addQuantityFullBoxSwitch.hidden = YES;
    }
    
    [self layoutAddQuantityView];
    
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
        
        itemDetailView.item = nil;
        
        // Deselect any item from the search results
        [itemListView deselectTableRow];
        
        [UIView beginAnimations:nil context:nil];  
        [UIView setAnimationDuration:0.3];
            slideOutFrame.origin.x = itemContentView.bounds.size.width;
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
        slideInFrame.origin.x = itemContentView.bounds.size.width;
        
        itemDetailView.item = itemToAdd;
        itemDetailView.frame = slideInFrame;
        
        [UIView beginAnimations:nil context:nil];  
        [UIView setAnimationDuration:0.3];
            slideOutFrame.origin.x = - (itemContentView.bounds.size.width);
            slideInFrame.origin.x = 0.0f;
        
            itemListView.frame = slideOutFrame;
            itemDetailView.frame = slideInFrame;
            itemDetailView.alpha = 1.0;
        [UIView commitAnimations]; 
        
        addToCartButton.enabled = YES;
        
        // Change state of exit button
        [exitButton setTitle:@"BACK" forState:UIControlStateNormal];
    }
}


@end
