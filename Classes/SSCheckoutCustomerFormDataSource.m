//
//  SSCheckoutCustomerFormDataSourceViewController.m
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "SSCheckoutCustomerFormDataSource.h"
#import "NSString+StringFormatters.h"
#import "IBATextFormField.h"
#import "IBAReadOnlyTextFormField.h"
#import "IBAPickListFormField.h"
#import "Address.h"

#pragma mark -
#pragma mark Private Interface
@interface SSCheckoutCustomerFormDataSource ()
@end

#pragma mark -
@implementation SSCheckoutCustomerFormDataSource

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
		style.labelTextAlignment = NSTextAlignmentLeft;
		style.valueTextAlignment = NSTextAlignmentRight;
		style.valueTextColor = [UIColor darkGrayColor];
		style.activeColor = [UIColor colorWithRed:0.893 green:0.976 blue:0.976 alpha:1.000];
		
		customerFormSection.formFieldStyle = style;
		
        
        if ([(NSDictionary *)aModel count] > 1)
        {
            IBAReadOnlyTextFormField *firstFormField = [[IBAReadOnlyTextFormField alloc] initWithKeyPath:@"firstName" title:@"First"];           
            [customerFormSection addFormField:[firstFormField autorelease]];
            
            IBAReadOnlyTextFormField *lastFormField = [[IBAReadOnlyTextFormField alloc] initWithKeyPath:@"lastName" title:@"Last"];
            [customerFormSection addFormField:[lastFormField autorelease]];
            
        }
        else
        {
            IBATextFormField *firstFormField = [[IBATextFormField alloc] initWithKeyPath:@"firstName" title:@"First"];
            [firstFormField setMaxLength:[NSNumber numberWithInt:40]];
            [customerFormSection addFormField:[firstFormField autorelease]];
            
            IBATextFormField *lastFormField = [[IBATextFormField alloc] initWithKeyPath:@"lastName" title:@"Last"];
            [lastFormField setMaxLength:[NSNumber numberWithInt:40]];
            [customerFormSection addFormField:[lastFormField autorelease]];
        }
        
        
		IBATextFormField *emailFormField = [[IBATextFormField alloc] initWithKeyPath:@"emailAddress" title:@"Email"];
        [customerFormSection addFormField:[emailFormField autorelease]];
		[emailFormField setMaxLength:[NSNumber numberWithInt:100]];
		emailFormField.textFormFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        // Fixed to ensure no autocorrect on e-mail [Defect:  2011-06-01]
        emailFormField.textFormFieldCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		emailFormField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
		
		
		IBATextFormField *addrLine1Field = [[IBATextFormField alloc] initWithKeyPath:@"addressLine1" title:@"Address 1"];
		[addrLine1Field setMaxLength:[NSNumber numberWithInt:40]];
		[customerFormSection addFormField:[addrLine1Field autorelease]];
		
		IBATextFormField *addrLine2Field = [[IBATextFormField alloc] initWithKeyPath:@"addressLine2" title:@"Address 2"];
		[addrLine2Field setMaxLength:[NSNumber numberWithInt:40]];
		[customerFormSection addFormField:[addrLine2Field autorelease]];
		
		IBATextFormField *cityField = [[IBATextFormField alloc] initWithKeyPath:@"city" title:@"City"];
		[cityField setMaxLength:[NSNumber numberWithInt:25]];
		[customerFormSection addFormField:[cityField autorelease]];
		
		IBATextFormField *stateFormField = [[IBATextFormField alloc] initWithKeyPath:@"stateProv" title:@"State"];
        [customerFormSection addFormField:[stateFormField autorelease]];
		[stateFormField setMaxLength:[NSNumber numberWithInt:2]];
		stateFormField.textFormFieldCell.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		
		/*
         NSArray *pickListOptions = [IBAPickListFormOption pickListOptionsForStrings:[Address usStateCodes]];
         IBAPickListFormOptionsStringTransformer *transformer = [[[IBAPickListFormOptionsStringTransformer alloc] initWithPickListOptions:pickListOptions] autorelease];
         [customerFormSection addFormField:[[[IBAPickListFormField alloc] initWithKeyPath:@"stateProv"
         title:@"State"
         valueTransformer:transformer
         selectionMode:IBAPickListSelectionModeSingle
         options:pickListOptions] autorelease]];
         */
		IBATextFormField *zipFormField = [[IBATextFormField alloc] initWithKeyPath:@"zipPostalCode" title:@"Zip"];
        [customerFormSection addFormField:[zipFormField autorelease]];
		[zipFormField setMaxLength:[NSNumber numberWithInt:5]];
		zipFormField.textFormFieldCell.textField.keyboardType = UIKeyboardTypeNumberPad;
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
