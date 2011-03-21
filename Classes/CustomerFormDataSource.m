//
//  CustomerFormDataSource.m
//  iPOS
//
//  Created by Steven McCoole on 3/19/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "CustomerFormDataSource.h"
#import "NSString+StringFormatters.h"
#import "IBATextFormField.h"
#import "IBAPickListFormField.h"
#import "Address.h"

#pragma mark -
#pragma mark Private Interface
@interface CustomerFormDataSource ()
@end

#pragma mark -
@implementation CustomerFormDataSource

#pragma mark Constructors
- (id) initWithModel:(id)aModel {
	self = [super initWithModel:aModel];
	if (self != nil) {
		NSString *title = [NSString stringWithFormat:@"Phone: %@", [NSString formatAsUSPhone:[aModel valueForKey:@"phoneNumber"]]];
		IBAFormSection *customerFormSection = [self addSectionWithHeaderTitle:title footerTitle:nil];
		
		IBAFormFieldStyle *style = [[[IBAFormFieldStyle alloc] init] autorelease];
		style.labelTextColor = [UIColor blackColor];
		style.labelFont = [UIFont systemFontOfSize:14.0f];
		style.valueFont = [UIFont systemFontOfSize:14.0f];
		style.labelTextAlignment = UITextAlignmentLeft;
		style.valueTextAlignment = UITextAlignmentRight;
		style.valueTextColor = [UIColor darkGrayColor];
		style.activeColor = [UIColor colorWithRed:0.893 green:0.976 blue:0.976 alpha:1.000];
		
		customerFormSection.formFieldStyle = style;
		
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"firstName" title:@"First"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"lastName" title:@"Last"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"emailAddress" title:@"Email"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"addressLine1" title:@"Address 1"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"addressLine2" title:@"Address 2"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"addressLine3" title:@"Address 3"] autorelease]];
		[customerFormSection addFormField:[[[IBATextFormField alloc] initWithKeyPath:@"city" title:@"City"] autorelease]];
		
		NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[Address usStateCodes]];
		IBAPickListFormOptionsStringTransformer *transformer = [[[IBAPickListFormOptionsStringTransformer alloc] initWithPickListOptions:pickListOptions] autorelease];
		[customerFormSection addFormField:[[[IBAPickListFormField alloc] initWithKeyPath:@"stateProv"
																			   title:@"State"
																	valueTransformer:transformer
																	   selectionMode:IBAPickListSelectionModeSingle
																			 options:pickListOptions] autorelease]];
		
		IBATextFormField *zipFormField = [[IBATextFormField alloc] initWithKeyPath:@"zipPostalCode" title:@"Zip"];
		zipFormField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeNumberPad;
		[customerFormSection addFormField:[zipFormField autorelease]];
		
	}
	
	return self;
}

- (void) dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark Methods

- (void)setModelValue:(id)value forKeyPath:(NSString *)keyPath {
	[super setModelValue:value forKeyPath:keyPath];
	
	NSLog(@"%@", [self.model description]);
}

@end
