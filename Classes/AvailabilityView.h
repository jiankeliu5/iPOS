//
//  AvailabilityView.h
//  iPOS
//
//  Created by Steven McCoole on 2/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DistributionCenter.h"

#define AVAILABLE_COLOR [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f]
#define UNAVAILABLE_COLOR [UIColor colorWithRed:255.0f/255.0f green:70.0f/255.0f blue:0.0f alpha:1.0f]
#define LARGE_FONT_SIZE 16.0f
#define SMALL_FONT_SIZE 14.0f
#define BIG_LABEL_HEIGHT 16.0f
#define SMALL_LABEL_HEIGHT 14.0f

@interface AvailabilityView : UIView 
{
	// We will either display for a distribution center or a store.
	// TODO Make one object to hold both store and distribution center availability info?
	DistributionCenter *distributionCenter;
	
	NSNumber *storeId;
	NSDecimalNumber *storeAvailability;
	NSDecimalNumber *storeOnHand;
	
	UILabel *locationIdLabel;
	UILabel *locationAvailableLabel;
	UILabel *locationOnHandLabel;
	UILabel *etaLabel;
	
	NSNumberFormatter *priceFormatter;
	NSNumberFormatter *availableFormatter;
}

@property (nonatomic, retain) DistributionCenter *distributionCenter;
@property (nonatomic, retain) NSNumber *storeId;
@property (nonatomic, retain) NSDecimalNumber *storeAvailability;
@property (nonatomic, retain) NSDecimalNumber *storeOnHand;

- (void) setStoreAvailabilityAtStoreId:(NSNumber *)sId withAvailable:(NSDecimalNumber *)sAvail andOnHand:(NSDecimalNumber *)sOnHand;

@end
