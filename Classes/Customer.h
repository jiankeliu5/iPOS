//
//  Customer.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AbstractModel.h"
#import "Address.h"
#import "Store.h"
#import "Error.h"

@interface Customer : AbstractModel {
    NSNumber *customerId;
    NSString *customerType;
    NSNumber *customerTypeId;
    NSString *e1CustomerId;
    NSNumber *priceLevelId;
    NSNumber *holdStatus;
    NSString *holdStatusText;
    NSDecimalNumber *creditBalance;
    NSDecimalNumber *creditLimit;
    NSNumber *termsTypeId;
    
    NSString *firstName;
    NSString *lastName;
    NSString *phoneNumber;
    NSString *emailAddress;
    
    Store   *store;
    Address *address; 
    
    BOOL taxExempt;
}

@property (nonatomic, retain) NSNumber *customerId;
@property (nonatomic, retain) NSString *customerType;
@property (nonatomic, retain) NSNumber *customerTypeId;
@property (nonatomic, retain) NSString *e1CustomerId;
@property (nonatomic, retain) NSNumber *priceLevelId;
@property (nonatomic, retain) NSNumber *holdStatus;
@property (nonatomic, retain) NSString *holdStatusText;
@property (nonatomic, retain) NSDecimalNumber *creditBalance;
@property (nonatomic, retain) NSDecimalNumber *creditLimit;
@property (nonatomic, retain) NSNumber *termsTypeId;

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, retain) NSString *emailAddress;

@property (nonatomic, retain) Store *store;
@property (nonatomic, retain) Address *address;

@property                     BOOL taxExempt;

- (id) initWithModel:(id)aModel;
- (id) modelFromCustomer;
- (BOOL) isValidCustomer:(BOOL)newCustomer;
- (void) mergeWith: (Customer *) mergeCustomer;

#pragma mark -
#pragma mark Accessors
- (BOOL) isRetailCustomer;
//Enning Tang check if customer is contractor 1
- (BOOL) isContractor1;
- (BOOL) isContractor;
- (BOOL) isOnHold;
- (BOOL) isPaymentOnAccountEligable;
- (NSDecimalNumber *) calculateAccountBalance;

#pragma mark -
#pragma mark Marshalling methods
+ (NSArray *) listFromXml: (NSString *) xmlString;
+ (Customer *) fromXml: (NSString *) xmlString;
- (NSString *) toXml;

@end
