//
//  Customer.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Customer.h"
#import "CustomerXmlMarshaller.h"


@implementation Customer

@synthesize customerId, customerType, customerTypeId, priceLevelId, firstName, lastName, phoneNumber, emailAddress, store, address, taxExempt, holdStatus,holdStatusText, creditLimit, creditBalance;
@synthesize termsTypeId, amountAppliedOnAccount;

#pragma mark Initializer and Memory Mgmt
-(id) init {
    self = [super init];
    
    if (self == nil) {
        
        return nil;
    }
    
    return self;
}

- (id) initWithModel:(id)aModel {
	self = [super init];

	if (self == nil) {
		return nil;
	}
	
	[self setCustomerId:[aModel valueForKey:@"customerId"]];
	[self setCustomerType:[aModel valueForKey:@"customerType"]];
	[self setCustomerTypeId:[aModel valueForKey:@"customerTypeId"]];
    [self setPriceLevelId:[aModel valueForKey:@"priceLevelId"]];
	[self setFirstName:[aModel valueForKey:@"firstName"]];
	[self setLastName:[aModel valueForKey:@"lastName"]];
	[self setPhoneNumber:[aModel valueForKey:@"phoneNumber"]];
	[self setEmailAddress:[aModel valueForKey:@"emailAddress"]];
    	
	Store *s = [[[Store alloc] init] autorelease];
	[s setStoreId:[aModel valueForKey:@"storeId"]];
	[self setStore:s];
	
	Address *addr = [[[Address alloc] init] autorelease];
	[addr setLine1:[aModel valueForKey:@"addressLine1"]];
	[addr setLine2:[aModel valueForKey:@"addressLine2"]];
	[addr setCity:[aModel valueForKey:@"city"]];
	[addr setStateProv:[aModel valueForKey:@"stateProv"]];
	// Use the code below if the state is a pick list
	/*
	if ([aModel valueForKey:@"stateProv"] != nil) {
		NSMutableSet *st = (NSMutableSet *)[aModel valueForKey:@"stateProv"];
		if ([st count] > 0) {
			NSArray *a = [st allObjects];
			[addr setStateProv:[a objectAtIndex:0]];
		}
	}
	 */
	[addr setZipPostalCode:[aModel valueForKey:@"zipPostalCode"]];
	[addr setCountry:[aModel valueForKey:@"country"]];
	[self setAddress:addr];
	
	NSNumber *taxExemptWrapper = [aModel valueForKey:@"taxExempt"];
	if (taxExemptWrapper != nil) {
		BOOL b = [taxExemptWrapper boolValue];
		[self setTaxExempt:b];
	}
	
	return self;
	
}

- (id) modelFromCustomer {
	NSMutableDictionary *aModel = [[NSMutableDictionary alloc] init];
	[aModel setValue:[self customerId] forKey:@"customerId"];
	[aModel setValue:[self customerType] forKey:@"customerType"];
	[aModel setValue:[self customerTypeId] forKey:@"customerTypeId"];
    [aModel setValue:[self priceLevelId] forKey:@"priceLevelId"];
	[aModel setValue:[self firstName] forKey:@"firstName"];
	[aModel setValue:[self lastName] forKey:@"lastName"];
	[aModel setValue:[self phoneNumber] forKey:@"phoneNumber"];
	[aModel setValue:[self emailAddress] forKey:@"emailAddress"];
	
	if ([self store] != nil) {
		[aModel setValue:[self.store storeId] forKey:@"storeId"];
	}
	
	if ([self address] != nil) {
		[aModel setValue:[self.address line1] forKey:@"addressLine1"];
		[aModel setValue:[self.address line2] forKey:@"addressLine2"];
		[aModel setValue:[self.address city] forKey:@"city"];
		[aModel setValue:[self.address stateProv] forKey:@"stateProv"];
		// Use the code below for state if it is a pick list
		/*
		if ([self.address stateProv] != nil) {
			NSMutableSet *st = [[[NSMutableSet alloc] initWithCapacity:1] autorelease];
			[st addObject:[self.address stateProv]];
			[aModel setValue:st forKey:@"stateProv"];
		}
		*/
		[aModel setValue:[self.address zipPostalCode] forKey:@"zipPostalCode"];
		[aModel setValue:[self.address country] forKey:@"country"];
	}
	
	[aModel setValue:[NSNumber numberWithBool:[self taxExempt]] forKey:@"taxExempt"];
	
	return [aModel autorelease];
}

- (void) dealloc {
    [customerType release];
    [customerTypeId release];
    [priceLevelId release];
    [firstName release];
    [lastName release];
    [phoneNumber release];
    [emailAddress release];
    [holdStatus release];
    [holdStatusText release];
    [creditBalance release];
    [creditLimit release];
    
    [store release];
    [address release];
    
    if (customerId != nil) {
        [customerId release];
    }
    [super dealloc];
}

#pragma mark -
#pragma mark Methods
- (BOOL) isValidCustomer:(BOOL)newCustomer {
	
	if (newCustomer == YES && self.customerId != nil) {
		// Attach an error
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Customer is already created.";
		error.reference = self;
		
		[self addError:error];
		
	}  else if (newCustomer == NO && (self.customerId == nil || [self.customerId isEqualToNumber:[NSNumber numberWithInt:0]])) {
        // Attach an error
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Invalid Customer id.";
		error.reference = self;
		
		[self addError:error];
        
    }
	
   if (self.firstName == nil && self.lastName == nil) {
 		// Attach an error
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"First or Last name must be set.";
		error.reference = self;
		
		[self addError:error];
	} else {
		NSInteger firstLen = (self.firstName == nil) ? 0 : [self.firstName length];
		NSInteger lastLen = (self.lastName == nil) ? 0 : [self.lastName length];
		if ((firstLen + lastLen) > 40) {
			Error *error = [[[Error alloc] init] autorelease];
			
			error.message = @"First and Last name must total under 40 chars.";
			error.reference = self;
			
			[self addError:error];
		}
	}
	
	if (self.phoneNumber == nil) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Phone number must be set.";
		error.reference = self;
		
		[self addError:error];
	} else {
		NSString *regex = @"[0-9]{10}";
		NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
		if ([regextest evaluateWithObject:self.phoneNumber] == NO) {
			Error *error = [[[Error alloc] init] autorelease];
			
			error.message = @"Phone number must 10 digits.";
			error.reference = self;
			
			[self addError:error];
		}
	}
	
	if (self.address != nil && self.address.zipPostalCode != nil) {
		NSString *regex = @"[0-9]{5}";
		NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
		if ([regextest evaluateWithObject:self.address.zipPostalCode] == NO) {
			Error *error = [[[Error alloc] init] autorelease];
			
			error.message = @"Zip code must be 5 digits.";
			error.reference = self;
			
			[self addError:error];
		}
	} else {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Zip code must be set.";
		error.reference = self;
		
		[self addError:error];
	}
	
	if(self.emailAddress != nil && [self.emailAddress length ] > 100) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Email address must be less than 100 chars.";
		error.reference = self;
		
		[self addError:error];
	}
	
	if (self.address != nil && self.address.line1 != nil && [self.address.line1 length] > 40) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Address line 1 must be less than 40 chars.";
		error.reference = self;
		
		[self addError:error];
	}
	
	if (self.address != nil && self.address.line2 != nil && [self.address.line2 length] > 40) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"Address line 2 must be less than 40 chars.";
		error.reference = self;
		
		[self addError:error];
	}
	
	if (self.address != nil && self.address.city != nil && [self.address.city length] > 25) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"City must be less than 25 chars.";
		error.reference = self;
		
		[self addError:error];
	}
	
	if (self.address != nil && self.address.stateProv != nil && [self.address.stateProv length] > 2) {
		Error *error = [[[Error alloc] init] autorelease];
		
		error.message = @"State must be less than 2 chars.";
		error.reference = self;
		
		[self addError:error];
    }
	
	if (self.errorList && [self.errorList count] > 0) {
		return NO;
	}
	
	return YES;
}

- (void) mergeWith:(Customer *) mergeCustomer {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergeCustomer.errorList && [mergeCustomer.errorList count] > 0) {
        self.errorList = [NSArray arrayWithArray: mergeCustomer.errorList];
        return;
    }
    
    // Merge other fields if customer ID is not 0.  This implies an "empty not found customer from the service.
    if (mergeCustomer.customerId && ![mergeCustomer.customerId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.customerId = mergeCustomer.customerId;
        
        if (mergeCustomer.firstName && ![mergeCustomer.firstName isEqualToString:self.firstName]) {
            self.firstName = mergeCustomer.firstName;
        }
        if (mergeCustomer.lastName && ![mergeCustomer.lastName isEqualToString:self.lastName]) {
            self.lastName = mergeCustomer.lastName;
        }
        if (mergeCustomer.emailAddress && ![mergeCustomer.emailAddress isEqualToString:self.emailAddress]) {
            self.emailAddress = mergeCustomer.emailAddress;
        }
        if (mergeCustomer.phoneNumber && ![mergeCustomer.phoneNumber isEqualToString:self.phoneNumber]) {
            self.phoneNumber = mergeCustomer.phoneNumber;
        }
		if (mergeCustomer.customerType && ![mergeCustomer.customerType isEqualToString:self.customerType]) {
			self.customerType = mergeCustomer.customerType;
		}
		if (mergeCustomer.customerTypeId && ![mergeCustomer.customerTypeId isEqualToNumber:[NSNumber numberWithInt:0]]) {
			self.customerTypeId = mergeCustomer.customerTypeId;
		}
        if (mergeCustomer.priceLevelId && ![mergeCustomer.priceLevelId isEqualToNumber:[NSNumber numberWithInt:0]]) {
			self.priceLevelId = mergeCustomer.priceLevelId;
		}
		
        self.holdStatus = mergeCustomer.holdStatus;
        self.creditLimit = mergeCustomer.creditLimit;
        self.creditBalance = mergeCustomer.creditBalance;
        self.termsTypeId = mergeCustomer.termsTypeId;
		self.taxExempt = mergeCustomer.taxExempt;
        
        // Merge Address information
        if (mergeCustomer.address) {
            if (self.address == nil) {
                self.address = [[[Address alloc] init] autorelease];
            }
            
            if (mergeCustomer.address.line1 && ![mergeCustomer.address.line1 isEqualToString:self.address.line1]) {
                self.address.line1 = mergeCustomer.address.line1;
            }
            if (mergeCustomer.address.line2 && ![mergeCustomer.address.line2 isEqualToString:self.address.line2]) {
                self.address.line2 = mergeCustomer.address.line2;            
            }
            if (mergeCustomer.address.city && ![mergeCustomer.address.city isEqualToString:self.address.city]) {
                self.address.city = mergeCustomer.address.city;            
            }
            if (mergeCustomer.address.stateProv && ![mergeCustomer.address.stateProv isEqualToString:self.address.stateProv]) {
                self.address.stateProv = mergeCustomer.address.stateProv;
            }
            if (mergeCustomer.address.zipPostalCode && ![mergeCustomer.address.zipPostalCode isEqualToString:self.address.zipPostalCode]) {
                self.address.zipPostalCode = mergeCustomer.address.zipPostalCode;
            }
        }
        
        // Merge Store information
        if (mergeCustomer.store) {
            if (self.store == nil) {
                self.store = [[[Store alloc] init] autorelease];
            }
            
            if (mergeCustomer.store.storeId && ![mergeCustomer.store.storeId isEqualToNumber: [NSNumber numberWithInt:0]]) {
                self.store.storeId = mergeCustomer.store.storeId;
            }
        }
    }    
}

#pragma mark -
#pragma mark Accessors
- (BOOL) isRetailCustomer {
    return [customerTypeId isEqualToNumber:[NSNumber numberWithInt:1]];
}

-(BOOL) isOnHold {
    
    if ([self.holdStatus integerValue] == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

//TODO: CHANGE TO NO, once I get more fake users added
-(BOOL) isPaymentOnAccountEligable {
    
    if (termsTypeId &&( [self.termsTypeId integerValue] == 2 || [self.termsTypeId integerValue] == 3 ||[self.termsTypeId integerValue] == 4 || [self.termsTypeId integerValue] == 5))
    {
        return YES;
    }
    
    return YES;  
}

-(NSDecimalNumber *) calculateAccountBalance {
    
    NSDecimalNumberHandler *bankersRoundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 
                                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    NSDecimalNumber *availCredit = [self.creditLimit decimalNumberByAdding:self.creditBalance];
    
    return [availCredit decimalNumberByRoundingAccordingToBehavior:bankersRoundingBehavior]; ;
    
}

#pragma mark -
#pragma mark Customer XML Marshalling
+ (Customer *) fromXml:(NSString *)xmlString {
    CustomerXmlMarshaller *marshaller = [[[CustomerXmlMarshaller alloc] init] autorelease];
    return (Customer *) [marshaller toObject:xmlString]; 
}

- (NSString *) toXml {
    CustomerXmlMarshaller *marshaller = [[[CustomerXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

@end
