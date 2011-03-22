//
//  Customer.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Customer.h"


@implementation Customer

@synthesize customerId, customerType, customerTypeId, firstName, lastName, phoneNumber, emailAddress, store, address, errorList, taxExempt;

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
    [firstName release];
    [lastName release];
    [phoneNumber release];
    [emailAddress release];
    
    [store release];
    [address release];
    
    if (errorList != nil) {
        [errorList release];
    }
    
    if (customerId != nil) {
        [customerId release];
    }
    [super dealloc];
}

@end
