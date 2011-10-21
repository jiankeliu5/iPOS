//
//  CartItemDetailViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CartItemDetailViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"
#import "NSString+StringFormatters.h"

#import "AlertUtils.h"
#import "PriceAdjustViewController.h"

#import "UIScreen+Helpers.h"

#define LABEL_FONT_SIZE 16.0f
#define LABEL_HEIGHT 18.0f

#define MARGIN_ITEM 20.0f

#define TEXT_FIELD_HEIGHT 40.0f
#define TEXT_FIELD_WIDTH 90.0f

//#define UOM_LABEL_START_X 120.0f
//#define UOM_LABEL_WIDTH 60.0f
//#define ITEM_TOTAL_START_X 160.0f
//#define ITEM_TOTAL_WIDTH 160.0f
//
//#define CONVERT_TO_BOX_SPACING 15.0f
//#define CONVERT_TO_BOX_LABEL_WIDTH 185.0f
//#define CONVERT_TO_BOX_SWITCH_HEIGHT 27.0f
//

#define BUTTON_HEIGHT 40.0f
#define BUTTON_HEIGHT_LANDSCAPE 30.0f
#define BUTTON_WIDTH 212.0f
#define BUTTON_SPACE 10.0f
//
#define UOM_EXCHANGE_BUTTON_SIZE 37.0f

@interface CartItemDetailViewController()

- (void) layoutView: (UIInterfaceOrientation) orientation;
- (void) updateDisplayValues;

- (void) switchSelectedUOM: (id) selector;

- (void) handleConvertToBoxesSwitch: (id) sender;

- (void) handleDeleteButton:(id)sender;
- (void) handleOpenButton:(id)sender;
- (void) handleCloseButton:(id)sender;
- (void) handlePriceButton:(id)sender;

@end

@implementation CartItemDetailViewController

@synthesize orderItem;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	// [[self navigationItem] setTitle:@"Item Number Here"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	nextRotationDegreesForExchangeButton = 180;
    
	quantityFormatter = [[NSNumberFormatter alloc] init];
	[quantityFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[quantityFormatter setGeneratesDecimalNumbers:YES];
    
    orderCart = [OrderCart sharedInstance];

    return self;
}

- (id) initWithOrderItem:(OrderItem *)editOrderItem {
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
    nextRotationDegreesForExchangeButton = 180;
	orderCart = [OrderCart sharedInstance];
	[self setOrderItem:editOrderItem];
	
	[[self navigationItem] setTitle:editOrderItem.item.sku];
	
	return self;
}

- (void)dealloc {
	[quantityFormatter release];
	quantityFormatter = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (UIView *) contentView
{
	return (UIView *)[self view];
}

#pragma mark -
#pragma mark UIViewController overrides

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *bgView = [[UIView alloc] initWithFrame:[self rectForNav]];
	bgView.backgroundColor = [UIColor whiteColor];
	[self setView:bgView];
	[bgView release];
	
	productItemView = [[UIView alloc] initWithFrame:CGRectZero];
	productItemView.backgroundColor = [UIColor colorWithWhite:0.70f alpha:1.0f];
	
	// Where we are in the productItem view 
    if (uomExchangeButton == nil) {
        uomExchangeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [uomExchangeButton setImage:[UIImage imageNamed:@"exchange.png"] forState:UIControlStateNormal];
        [uomExchangeButton addTarget:self action:@selector(switchSelectedUOM:) forControlEvents:UIControlEventTouchUpInside];
        
        [productItemView addSubview:uomExchangeButton];
        uomExchangeButton.hidden = NO;
        [uomExchangeButton release];
    }

	skuLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	skuLabel.backgroundColor = [UIColor clearColor];
	skuLabel.textColor = [UIColor blackColor];
	skuLabel.textAlignment = UITextAlignmentCenter;
	skuLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:skuLabel];
	[skuLabel release];
	
	descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	descLabel.backgroundColor = [UIColor clearColor];
	descLabel.textColor = [UIColor blackColor];
	descLabel.textAlignment = UITextAlignmentCenter;
	descLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:descLabel];
	[descLabel release];
	
	priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	priceLabel.backgroundColor = [UIColor clearColor];
	priceLabel.textColor = [UIColor blackColor];
	priceLabel.textAlignment = UITextAlignmentCenter;
	priceLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	[productItemView addSubview:priceLabel];
	[priceLabel release];
	
	[self.view addSubview:productItemView];
	[productItemView release];
		
	orderItemView = [[UIView alloc] initWithFrame:CGRectZero];
	orderItemView.backgroundColor = [UIColor colorWithWhite:0.50f alpha:1.0f];
	
	quantityField = [[ExtUITextField alloc] initWithFrame:CGRectZero];
	quantityField.textColor = [UIColor blackColor];
	quantityField.borderStyle = UITextBorderStyleRoundedRect;
	quantityField.textAlignment = UITextAlignmentCenter;
    quantityField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    if (orderItem && [orderItem allowQuantityChange] == NO) {
        quantityField.enabled = NO;
    } else {
        // Enable editing
        quantityField.clearsOnBeginEditing = NO;
        quantityField.tagName = @"ItemQuantity";
        
        quantityField.returnKeyType = UIReturnKeyGo;
        quantityField.keyboardType = UIKeyboardTypeDecimalPad;
        [self addDoneAndCancelToolbarForTextField:quantityField];
    }
    
    // Is it editable
	[orderItemView addSubview:quantityField];
	[quantityField release];
	
	unitOfMeasureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	unitOfMeasureLabel.backgroundColor = [UIColor clearColor];
	unitOfMeasureLabel.textColor = [UIColor blackColor];
	unitOfMeasureLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	[orderItemView addSubview:unitOfMeasureLabel];
	[unitOfMeasureLabel release];
	
	itemTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	itemTotalLabel.backgroundColor = [UIColor clearColor];
	itemTotalLabel.textColor = [UIColor blackColor];
	itemTotalLabel.textAlignment = UITextAlignmentCenter;
	itemTotalLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	[orderItemView addSubview:itemTotalLabel];
	[itemTotalLabel release];
    
    // Add the convert to boxes control
    convertToBoxesSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
    [convertToBoxesSwitch addTarget:self action:@selector(handleConvertToBoxesSwitch:) forControlEvents:UIControlEventValueChanged];
    convertToBoxesSwitch.on = YES;
    convertToBoxesSwitch.hidden = YES;
    [orderItemView addSubview:convertToBoxesSwitch];
    [convertToBoxesSwitch release];
    
    convertToBoxesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    convertToBoxesLabel.text = @"Full Boxes";
    convertToBoxesLabel.textAlignment = UITextAlignmentRight;
    convertToBoxesLabel.backgroundColor = [UIColor clearColor];
	convertToBoxesLabel.textColor = [UIColor blackColor];
	convertToBoxesLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
    convertToBoxesLabel.hidden = YES;
    [orderItemView addSubview:convertToBoxesLabel];
	[convertToBoxesLabel release];
    
	[self.view addSubview:orderItemView];
	[orderItemView release];
	
	deleteButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
	[deleteButton setupAsRedButton];
	deleteButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
	[self.view addSubview:deleteButton];
	[deleteButton release];
	
    // Request to re-open item or close and adjust price
    if (orderItem && [orderItem isClosed]) {
        openButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
        [openButton setupAsBlackButton];
        openButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [openButton setTitle:@"Open" forState:UIControlStateNormal];
        [self.view addSubview:openButton];
        [openButton release];
    } else {
        closeLineButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
        [closeLineButton setupAsGreenButton];
        closeLineButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [closeLineButton setTitle:@"Close Line" forState:UIControlStateNormal];
        
        // Is the close line allowed with current quantity or not ?
        if (orderItem && ![orderItem allowClose]) {
            closeLineButton.enabled = NO;
        }
        
        [self.view addSubview:closeLineButton];
        [closeLineButton release];
    
        priceButton = [[MOGlassButton alloc] initWithFrame:CGRectZero];
        [priceButton setupAsBlueButton];
        priceButton.titleLabel.textAlignment = UITextAlignmentCenter;
        [priceButton setTitle:@"Price" forState:UIControlStateNormal];
        
        [self.view addSubview:priceButton];
        [priceButton release];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	self.delegate = self;
	quantityField.delegate = self;
    
	[deleteButton addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    
    if (orderItem && [orderItem isClosed]) {
        [openButton addTarget:self action:@selector(handleOpenButton:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [closeLineButton addTarget:self action:@selector(handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [priceButton addTarget:self action:@selector(handlePriceButton:) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self updateDisplayValues];
    
    [self layoutView:[UIApplication sharedApplication].statusBarOrientation];
	
	// Call super last
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super first
	[super viewDidAppear:animated];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutView:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark ExtUIViewController delegates
- (void) extTextFieldFinishedEditing:(ExtUITextField *) textField {
	if (textField.text != nil) {
		NSDecimalNumber *newQuantity = (NSDecimalNumber *)[quantityFormatter numberFromString:textField.text];
		if (newQuantity != nil) {
            // Has the value even changed??
            if (![textField.text isEqualToString:[self.orderItem getQuantityForDisplay]]) {
                [self.orderItem setQuantity:newQuantity];
                
                // Can I still attempt a close of item based on current item availability when the item was retrieved
                // for the order 
                if ([orderItem allowClose] && closeLineButton) {
                    closeLineButton.enabled = YES;
                } else {
                    closeLineButton.enabled = NO;
                }
            }
			[self updateDisplayValues];
		}
	}
}

#pragma mark -
#pragma mark UIButton/UISwitch handlers
- (void) handleOpenButton:(id)sender {
    [orderItem setStatusToOpen];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) handleCloseButton:(id)sender {
    if (![orderCart closeItem:orderItem]) {
        [AlertUtils showModalAlertMessage:@"Cannot close line.  Stock not available."];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) handleDeleteButton:(id)sender {
	[orderCart removeItem:self.orderItem];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) handlePriceButton:(id)sender {
    PriceAdjustViewController *priceAdjust = [[[PriceAdjustViewController alloc] initWithOrderItem:self.orderItem] autorelease];
	[self.navigationController pushViewController:priceAdjust animated:YES];
}

- (void) handleConvertToBoxesSwitch: (id) sender {
    if (orderItem != nil) {
        orderItem.doConversionToFullBoxes = convertToBoxesSwitch.on;
        
        [self updateDisplayValues];
    }
}

#pragma mark -
#pragma mark Layout View
- (void) layoutView:(UIInterfaceOrientation) orientation {
    
    CGRect viewBounds = [UIScreen rectForScreenView:orientation isNavBarVisible:YES];
    self.view.frame = viewBounds;
    
    CGRect productViewRect = CGRectZero;
    CGRect itemViewRect = CGRectZero;
    CGRect actionListRect = CGRectZero;
    
    // Layout Logic
    CGRectDivide(viewBounds, &productViewRect, &itemViewRect, LABEL_HEIGHT * 4.0, CGRectMinYEdge);
    CGRectDivide(itemViewRect, &itemViewRect, &actionListRect, itemViewRect.size.height * 0.4, CGRectMinYEdge);
    
    // productItemView (uomExchangeButton, skuLabel, descLabel, priceLabel)
    productItemView.frame = productViewRect;
    
    CGRect labelsRect = CGRectZero;
    CGRect uomExchangeButtonRect = CGRectZero;
    CGRect skuLabelRect = CGRectZero;
    CGRect descLabelRect = CGRectZero;
    CGRect priceLabelRect = CGRectZero;
    
    CGRectDivide(productViewRect, &labelsRect, &uomExchangeButtonRect, productViewRect.size.width - UOM_EXCHANGE_BUTTON_SIZE, CGRectMinXEdge);
    CGRectDivide(labelsRect, &skuLabelRect, &descLabelRect, labelsRect.size.height * 0.4, CGRectMinYEdge);
    CGRectDivide(descLabelRect, &descLabelRect, &priceLabelRect, descLabelRect.size.height * 0.5, CGRectMinYEdge);
    
    uomExchangeButtonRect.size.height = UOM_EXCHANGE_BUTTON_SIZE;
    skuLabelRect.size.width += UOM_EXCHANGE_BUTTON_SIZE;
    descLabelRect.size.width += UOM_EXCHANGE_BUTTON_SIZE;
    priceLabelRect.size.width += UOM_EXCHANGE_BUTTON_SIZE;
    
    uomExchangeButton.frame = uomExchangeButtonRect;
    skuLabel.frame = skuLabelRect;
    descLabel.frame = descLabelRect;
    priceLabel.frame = priceLabelRect;
    
    // orderItemView (quantityField, unitOfMeasureLabel, itemTotalLabel, convertToBoxesSwitch, convertToBoxesLabel)
    orderItemView.frame = itemViewRect;
    
    CGRect itemRect = CGRectZero;
    CGRect convertToBoxesRect = CGRectZero;
    
    CGRect itemQuantityRect = CGRectZero;
    CGRect itemUnitsRect = CGRectZero;
    CGRect itemTotalRect = CGRectZero;
    
    CGRect convertBoxLabelRect = CGRectZero;
    CGRect convertBoxSwitchRect = CGRectZero; 
    
    itemViewRect.origin.y = 0;
    CGRectDivide(itemViewRect, &itemRect, &convertToBoxesRect, itemViewRect.size.height * 0.5, CGRectMinYEdge);
    CGRectDivide(itemRect, &itemQuantityRect, &itemUnitsRect, itemRect.size.width * 0.4, CGRectMinXEdge);
    CGRectDivide(itemUnitsRect, &itemUnitsRect, &itemTotalRect, itemUnitsRect.size.width * 0.5, CGRectMinXEdge);
    
    quantityField.frame = CGRectMake(itemQuantityRect.size.width - TEXT_FIELD_WIDTH - MARGIN_ITEM, 
                                     (itemQuantityRect.size.height - TEXT_FIELD_HEIGHT)/2, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT);
    unitOfMeasureLabel.frame = itemUnitsRect;
    itemTotalLabel.frame = itemTotalRect;
    
    CGRectDivide(convertToBoxesRect, &convertBoxLabelRect, &convertBoxSwitchRect, convertToBoxesRect.size.width * 0.5, CGRectMinXEdge);
    
    convertToBoxesLabel.frame = convertBoxLabelRect;
    convertToBoxesSwitch.frame = CGRectMake(convertBoxSwitchRect.origin.x + MARGIN_ITEM, 
                                            convertBoxSwitchRect.origin.y + (convertToBoxesRect.size.height - convertToBoxesSwitch.frame.size.height)/2, 
                                            convertBoxSwitchRect.size.width, 0);
    
    // The buttons (deleteButton, openButton, closeLineButton, priceButton)
    CGFloat buttonHeight = BUTTON_HEIGHT;
    CGFloat buttonSpace = BUTTON_SPACE;
    
    if (viewBounds.size.width > viewBounds.size.height) {
        buttonHeight = BUTTON_HEIGHT_LANDSCAPE;
        buttonSpace -= 3;
    }
    
    deleteButton.frame = CGRectMake((viewBounds.size.width - BUTTON_WIDTH)/2, actionListRect.origin.y + buttonSpace, BUTTON_WIDTH, buttonHeight);
        
    if (openButton) {
        openButton.frame = CGRectMake((viewBounds.size.width - BUTTON_WIDTH)/2, deleteButton.frame.origin.y + buttonSpace + buttonHeight, BUTTON_WIDTH, buttonHeight);
    } else {
        closeLineButton.frame = CGRectMake((viewBounds.size.width - BUTTON_WIDTH)/2, deleteButton.frame.origin.y + buttonSpace + buttonHeight, BUTTON_WIDTH, buttonHeight);
        priceButton.frame = CGRectMake((viewBounds.size.width - BUTTON_WIDTH)/2, closeLineButton.frame.origin.y + buttonSpace + buttonHeight, BUTTON_WIDTH, buttonHeight);
    }
}

#pragma mark -
#pragma mark View Update methods
- (void) updateDisplayValues {
	if (self.orderItem != nil) {
		skuLabel.text = self.orderItem.item.sku;
		descLabel.text = self.orderItem.item.description;
		priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [self.orderItem getSellingPriceForDisplay], [self.orderItem getUOMForDisplay]];
		quantityField.text = [self.orderItem getQuantityForDisplay];
		unitOfMeasureLabel.text = [self.orderItem getUOMForDisplay];
		NSDecimalNumber *lineTotal = [self.orderItem calcLineSubTotal];
		itemTotalLabel.text = [NSString formatDecimalNumberAsMoney:lineTotal];
        
        // De we hide or show the default to box (only when item needs conversion)
        if ([orderItem isConversionNeeded]) {
        
            // The switch on/off is based on the order item flag
            convertToBoxesSwitch.on = orderItem.doConversionToFullBoxes;
        
            convertToBoxesLabel.hidden = NO;
            convertToBoxesSwitch.hidden = NO;
        } else {
            convertToBoxesLabel.hidden = YES;
            convertToBoxesSwitch.hidden = YES;
        }
        
        // Do we show or hide exchange button
        if ([orderItem.item isUOMConversionRequired]) {
            uomExchangeButton.hidden = NO;
        } else {
            uomExchangeButton.hidden = YES;  
        }
	}
}

#pragma mark -
#pragma mark Private Methods
-(void) switchSelectedUOM:(id)selector {
    [uomExchangeButton rotateView:nextRotationDegreesForExchangeButton animated:YES];    
    
    if (nextRotationDegreesForExchangeButton == 180) {
        nextRotationDegreesForExchangeButton = 0;
    } else {
        nextRotationDegreesForExchangeButton = 180;
    }
    
    // Toggle the item
    [orderItem.item toggleUOM];
    [self updateDisplayValues];
}


@end
