//
//  CustomerViewController.m
//  iPOS
//
//  Created by Steven McCoole on 2/10/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerViewController.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIView+ViewLayout.h"
#import "NSString+StringFormatters.h"
#import "AlertUtils.h"
#import "CustomerFormDataSource.h"
#import "CustomerEditViewController.h"
#import "CartItemsViewController.h"

@interface CustomerViewController()
- (void) handleSearchButton:(id)sender;
- (void) handleConfirmButton:(id)sender;
- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect;
- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect;
- (void) updateViewLayout;
- (void)updateKeyboardButtonFor:(ExtUITextField *)textField;
- (void)keyboardDidShow:(NSNotification *)note;
- (void)numberPadDoneButton:(id)sender;
- (void)formatInput:(ExtUITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange;
- (void) editExistingCustomer:(id)sender;
@end

@implementation CustomerViewController

@synthesize phoneMask, currentFirstResponder; 
@synthesize numberPadDoneImageNormal, numberPadDoneImageHighlighted, numberPadDoneButton;
@synthesize customer;

#pragma mark Constructors
- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    
	// Set up the items that will appear in a navigation controller bar if
	// this view controller is added to a UINavigationController.
	[[self navigationItem] setTitle:@"Customer"];

	// Set up the right side button if desired, edit button for example.
	//[[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
	
	facade = [iPOSFacade sharedInstance];
	[self setPhoneMask:@"999-999-9999"];
	self.numberPadDoneImageNormal = [UIImage imageNamed:@"DoneUp3.png"];
	self.numberPadDoneImageHighlighted = [UIImage imageNamed:@"DoneDown3.png"];

    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self]; 
	[self setPhoneMask:nil];
	[self setCurrentFirstResponder:nil];
	[self setNumberPadDoneImageNormal:nil];
    [self setNumberPadDoneImageHighlighted:nil];
    [self setNumberPadDoneButton:nil];
	[self setCustomer:nil];
	
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

	UIView *custView = [[UIView alloc] initWithFrame:CGRectZero];
	custView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	[self setView:custView];
	[custView release];
	
	custPhoneField = [[ExtUITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, TEXT_FIELD_WIDTH, TEXT_FIELD_HEIGHT)];
	custPhoneField.textColor = [UIColor blackColor];
	custPhoneField.borderStyle = UITextBorderStyleRoundedRect;
	custPhoneField.textAlignment = UITextAlignmentCenter;
	custPhoneField.clearsOnBeginEditing = YES;
	custPhoneField.placeholder = @"Phone Number";
	custPhoneField.tagName = @"CustPhone";
	custPhoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	custPhoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
	custPhoneField.returnKeyType = UIReturnKeyGo;
	custPhoneField.keyboardType = UIKeyboardTypeNumberPad;
	
	[self.view addSubview:custPhoneField];
	[custPhoneField release];
	
	custSearchButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[custSearchButton setupAsSmallBlackButton];
	custSearchButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[custSearchButton setTitle:@"Search" forState:UIControlStateNormal];
	[self.view addSubview:custSearchButton];
	[custSearchButton release];
	
	// Set up the detail view for showing customer summary information when fetched by the search.
	detailView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT)];
	
	CGFloat dy = LABEL_SPACING;
	firstLabel = [self createNormalLabel:@"First" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstLabel];
	[firstLabel release];
	firstName = [self createBoldLabel:nil withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:firstName];
	[firstName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	lastLabel = [self createNormalLabel:@"Last" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastLabel];
	[lastLabel release];
	lastName = [self createBoldLabel:nil withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:lastName];
	[lastName release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	emailLabel = [self createNormalLabel:@"Email" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:emailLabel];
	[emailLabel release];
	email = [self createBoldLabel:nil withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:email];
	[email release];
	
	dy += LABEL_HEIGHT + LABEL_SPACING;
	zipLabel = [self createNormalLabel:@"Zip" withRect:CGRectMake(DETAIL_LABEL_X, dy, DETAIL_LABEL_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zipLabel];
	[zipLabel release];
	zip = [self createBoldLabel:nil withRect:CGRectMake(DETAIL_DATA_X, dy, DETAIL_DATA_WIDTH, LABEL_HEIGHT)];
	[detailView addSubview:zip];
	[zip release];
	
	detailView.hidden = YES;
	[self.view addSubview:detailView];
	[detailView release];
	
	confirmButton = [[MOGlassButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[confirmButton setupAsSmallBlackButton];
	confirmButton.titleLabel.textAlignment = UITextAlignmentCenter;
	[confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
	confirmButton.hidden = YES;
	[self.view addSubview:confirmButton];
	[confirmButton release];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
    [super viewDidLoad];
	
	if (self.navigationController != nil) 
	{
		[self.navigationController setNavigationBarHidden:NO];
	}
	
	custPhoneField.delegate = self;
	[custSearchButton addTarget:self action:@selector(handleSearchButton:) forControlEvents:UIControlEventTouchUpInside];
	[confirmButton addTarget:self action:@selector(handleConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cust" style:UIBarButtonItemStyleBordered target:nil action:nil];
	}
	
	[self updateViewLayout];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(keyboardDidShow:) 
												 name:UIKeyboardDidShowNotification 
											   object:nil];
	
	if (self.customer == nil) {
		custPhoneField.text = nil;
		custDetailsOpen = NO;
		if (self.navigationItem.rightBarButtonItem != nil) {
			[self.navigationItem setRightBarButtonItem:nil];
		}
	} else {
		custPhoneField.text = [NSString formatAsUSPhone:[self.customer phoneNumber]];
	}

	[self updateViewLayout];
	
	// Do this last
	[super viewWillAppear:animated];
	
}

- (void) viewDidAppear:(BOOL)animated {
	// Call super at the beginning
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:UIKeyboardDidShowNotification 
												  object:nil]; 
	// Do this at the end
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	// Do this at the end
	[super viewDidDisappear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -
#pragma mark Keyboard Managment
- (void)updateKeyboardButtonFor:(ExtUITextField *)textField {
	
    // Remove any previous button
    [self.numberPadDoneButton removeFromSuperview];
    self.numberPadDoneButton = nil;
	
    // Does the text field use a number pad?
    if (textField.keyboardType != UIKeyboardTypeNumberPad)
        return;
	
    // If there's no keyboard yet, don't do anything
    if ([[[UIApplication sharedApplication] windows] count] < 2)
        return;
    UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
	
    // Create new custom button
    self.numberPadDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.numberPadDoneButton.frame = CGRectMake(0, 163, 106, 53);
    self.numberPadDoneButton.adjustsImageWhenHighlighted = FALSE;
    [self.numberPadDoneButton setImage:self.numberPadDoneImageNormal forState:UIControlStateNormal];
    [self.numberPadDoneButton setImage:self.numberPadDoneImageHighlighted forState:UIControlStateHighlighted];
    [self.numberPadDoneButton addTarget:self action:@selector(numberPadDoneButton:) forControlEvents:UIControlEventTouchUpInside];
	
    // Locate keyboard view and add button
    for (UIView *subView in keyboardWindow.subviews) {
        if ([[subView description] hasPrefix:@"<UIPeripheralHost"]) {
            [subView addSubview:self.numberPadDoneButton];
            [self.numberPadDoneButton addTarget:self action:@selector(numberPadDoneButton:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (void)keyboardDidShow:(NSNotification *)note {
    [self updateKeyboardButtonFor:self.currentFirstResponder];
}

#pragma mark -
#pragma mark ExtUITextField delegates
- (BOOL)textFieldShouldBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = textField;
	[self updateKeyboardButtonFor:textField];
}

- (void)textFieldDidEndEditing:(ExtUITextField *)textField {
	self.currentFirstResponder = nil;
	
}

- (BOOL)textFieldShouldReturn:(ExtUITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)formatInput:(ExtUITextField*)aTextField string:(NSString*)aString range:(NSRange)aRange {
    //Copying the contents of UITextField to an variable to add new chars later
    NSString* value = aTextField.text;
	
    NSString* formattedValue = value;
	
    //Make sure to retrieve the newly entered char on UITextField
    aRange.length = 1;
	
    NSString* _mask = [self.phoneMask substringWithRange:aRange];
	
    //Checking if there's a char mask at current position of cursor
    if (_mask != nil) {
        NSString *regex = @"[0-9]*";
		
        NSPredicate *regextest = [NSPredicate
                                  predicateWithFormat:@"SELF MATCHES %@", regex];
        //Checking if the character at this position isn't a digit
        if (! [regextest evaluateWithObject:_mask]) {
            //If the character at current position is a special char this char must be appended to the user entered text
            formattedValue = [formattedValue stringByAppendingString:_mask];
        }
		
        if (aRange.location + 1 < [self.phoneMask length]) {
			_mask =  [self.phoneMask substringWithRange:NSMakeRange(aRange.location + 1, 1)];
			if([_mask isEqualToString:@" "])
                formattedValue = [formattedValue stringByAppendingString:_mask];
        }
    }
    //Adding the user entered character
    formattedValue = [formattedValue stringByAppendingString:aString];
	
    //Refreshing UITextField value      
    aTextField.text = formattedValue;
}

// Watch the phone field as typed and insert extra characters according to the mask.
- (BOOL)textField:(ExtUITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //If the length of used entered text is equals to mask length the user input must be cancelled
    if ([textField.text length] == [self.phoneMask length]) {
        if(! [string isEqualToString:@""])
            return NO;
        else
            return YES;
    }
    //If the user has started typing text on UITextField the formatting method must be called
    else if ([textField.text length] || range.location == 0) {
        if (string) {
            if(! [string isEqualToString:@""]) {
                [self formatInput:textField string:string range:range];
                return NO;
            }
            return YES;
        }
        return YES;
    }
	
    return YES;
}

#pragma mark -
#pragma mark UIButton callbacks
- (void)handleSearchButton:(id)sender {
	
	[self.navigationItem setRightBarButtonItem:nil];
	[self setCustomer:nil];
	
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
	
	NSString *searchString = [custPhoneField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
	NSString *regex = @"[0-9]{10}";
	NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	if ([regextest evaluateWithObject:searchString] == YES) {
		[self setCustomer:[facade lookupCustomerByPhone:searchString]];
		
		if (customer == nil) {
			NSMutableDictionary *customerFormModel = [[[NSMutableDictionary alloc] init] autorelease];
			[customerFormModel setValue:[NSString stringWithString:searchString] forKey:@"phoneNumber"];
			CustomerFormDataSource *customerFormDataSource = [[[CustomerFormDataSource alloc] initWithModel:customerFormModel] autorelease];
			CustomerEditViewController *customerEditViewController = [[[CustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource] autorelease];
			[customerEditViewController setTitle:@"Customer Edit"];
			[[self navigationController] pushViewController:customerEditViewController animated:TRUE];
		} else {
			if (custDetailsOpen == NO) {
				custDetailsOpen = YES;
			} 
			
			UIBarButtonItem *editButton = [[UIBarButtonItem alloc] init];
			editButton.title = @"Edit";
			editButton.target = self;
			[editButton setAction:@selector(editExistingCustomer:)];
			self.navigationItem.rightBarButtonItem = editButton;
			[editButton release];
			
			[self updateViewLayout];
		}
	} else {
		[AlertUtils showModalAlertMessage:@"Please enter a 10 digit phone number"];
	}
}

- (void) editExistingCustomer:(id)sender {
	if (self.customer != nil) {
		NSMutableDictionary *customerFormModel = [self.customer modelFromCustomer];
		CustomerFormDataSource *customerFormDataSource = [[[CustomerFormDataSource alloc] initWithModel:customerFormModel] autorelease];
		CustomerEditViewController *customerEditViewController = [[[CustomerEditViewController alloc] initWithNibName:nil bundle:nil formDataSource:customerFormDataSource] autorelease];
		[customerEditViewController setTitle:@"Customer Edit"];
		[[self navigationController] pushViewController:customerEditViewController animated:TRUE];
	} else {
		NSLog(@"Should not be trying to edit if customer is nil");
	}

}


- (void) handleConfirmButton:(id)sender {
	NSLog(@"Got confirm button press");
	if (self.customer != nil) {
		NSMutableDictionary *cpy = [self.customer modelFromCustomer];
		Customer *custCpy = [[[Customer alloc] initWithModel:cpy] autorelease];
		[facade setCurrentCustomer:custCpy];
		[self setCustomer:nil];
		CartItemsViewController *cart = [[CartItemsViewController alloc] init];
		[[self navigationController] pushViewController:cart animated:TRUE];
		[cart release];
	}
}

- (void)numberPadDoneButton:(id)sender {
	if (self.currentFirstResponder != nil && [self.currentFirstResponder canResignFirstResponder]) {
		[self.currentFirstResponder resignFirstResponder];
	}
}

#pragma mark -
#pragma mark UILabel creation
- (UILabel *) createNormalLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label;
	label = [[UILabel alloc] initWithFrame:rect];
	label.text = text;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor blackColor];
	label.textAlignment = UITextAlignmentLeft;
	label.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

- (UILabel *) createBoldLabel:(NSString *)text withRect:(CGRect)rect {
	UILabel *label = [self createNormalLabel:text withRect:rect];
	label.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
	return label;
}

#pragma mark -
#pragma mark UIView update
- (void) updateViewLayout {
	
	if (customer != nil) {
		firstName.text = customer.firstName;
		lastName.text = customer.lastName;
		email.text = customer.emailAddress;
		zip.text = customer.address.zipPostalCode;
	}

	CGFloat width = self.view.bounds.size.width;
	
	CGFloat cy = START_Y;
	custPhoneField.center = [self.view centerAt:cy];
	
	if (custDetailsOpen == NO) {
		cy += TEXT_FIELD_HEIGHT + SPACING;
		detailView.hidden = YES;
		confirmButton.hidden = YES;
		custSearchButton.center = [self.view centerAt:cy];
	} else {
		cy += TEXT_FIELD_HEIGHT;
		detailView.frame = CGRectMake(DETAIL_VIEW_X, cy, DETAIL_VIEW_WIDTH, DETAIL_VIEW_HEIGHT);
		detailView.hidden = NO;
		cy += DETAIL_VIEW_HEIGHT + SPACING;
		CGFloat buttonSpace = floorf((width - BUTTON_WIDTH * 2.0f) / 3.0f);
		custSearchButton.frame = CGRectMake(buttonSpace, cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		confirmButton.frame = CGRectMake(((buttonSpace * 2.0f) + BUTTON_WIDTH), cy, BUTTON_WIDTH, BUTTON_HEIGHT);
		confirmButton.hidden = NO;
	}
}

@end
