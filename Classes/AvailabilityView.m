//
//  AvailabilityView.m
//  iPOS
//
//  Created by Steven McCoole on 2/27/11.
//  Copyright 2011 NA. All rights reserved.
//

#import "AvailabilityView.h"
#import <QuartzCore/QuartzCore.h>

#define MARGIN 2.0f

#pragma mark -
#pragma mark Private Interface
@interface AvailabilityView ()
- (void) updateDisplayValues;
@end

#pragma mark -
@implementation AvailabilityView

@synthesize distributionCenter;
@synthesize storeId;
@synthesize storeAvailability;
@synthesize storeOnHand;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
	priceFormatter = [[NSNumberFormatter alloc] init];
	[priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	availableFormatter = [[NSNumberFormatter alloc] init];
	[availableFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[availableFormatter setMaximumFractionDigits:2];
	[availableFormatter setMinimumFractionDigits:2];
	
    return self;
}

- (void) dealloc {
	
	[priceFormatter release];
	priceFormatter = nil;
	
	[availableFormatter release];
	availableFormatter = nil;
	
	[self setStoreId:nil];
	[self setStoreAvailability:nil];
	[self setStoreOnHand:nil];
	[self setDistributionCenter:nil];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (DistributionCenter *) distributionCenter {
	return distributionCenter;
}

- (void) setDistributionCenter:(DistributionCenter *)distCenter {
	if (distributionCenter != distCenter) {
		[distributionCenter release];
		distributionCenter = [distCenter retain];
	}
    
    if ([self.subviews count] > 0) {
        [self updateDisplayValues];
        [self setNeedsDisplay];
    }
}

// We don't do a redisplay on the individual setters just due to efficiency
// If one needs to be set and updated, the caller should invoke setNeedsDisplay
// on the AvailabilityView themselves.

- (NSNumber *) storeId {
	return storeId;
}

- (void) setStoreId:(NSNumber *)sId {
	if (storeId != sId) {
		[storeId release];
		storeId = [sId retain];
	}
}

- (NSDecimalNumber *) storeAvailability {
	return storeAvailability;
}

- (void) setStoreAvailability:(NSDecimalNumber *)sAvail {
	if (storeAvailability != sAvail) {
		[storeAvailability release];
		storeAvailability = [sAvail retain];
	}
}

- (NSDecimalNumber *) storeOnHand {
	return storeOnHand;
}

- (void) setStoreOnHand:(NSDecimalNumber *)sOnHand {
	if (storeOnHand != sOnHand) {
		[storeOnHand release];
		storeOnHand = [sOnHand retain];
	}
}

// We do a setNeedsDisplay here because we set them all in one go.
- (void) setStoreAvailabilityAtStoreId:(NSNumber *)sId withAvailable:(ItemAvailability *)sAvail {
	[self setStoreId:sId];
	[self setStoreAvailability:[sAvail getSelectedAvailability]];
	[self setStoreOnHand:[sAvail getSelectedOnHand]];
	
    if ([self.subviews count] > 0) {
        [self updateDisplayValues];
        [self setNeedsDisplay];
    }
}
											
#pragma mark -
#pragma mark Methods

- (void) layoutSubviews {
	self.backgroundColor = AVAILABLE_COLOR;
	[self.layer setBorderWidth:1.0f];
	[self.layer setBorderColor:[[UIColor blackColor] CGColor]];
	
	CGFloat y = MARGIN;
	
	if (locationIdLabel == nil) {
		locationIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, self.frame.size.width, SMALL_LABEL_HEIGHT)];
		locationIdLabel.backgroundColor = [UIColor clearColor];
		locationIdLabel.textColor = [UIColor blackColor];
		locationIdLabel.textAlignment = NSTextAlignmentCenter;
		locationIdLabel.font = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
		locationIdLabel.text = @"NA";
		[self addSubview:locationIdLabel];
		[locationIdLabel release];
	}
	
	y += SMALL_LABEL_HEIGHT;
	
	if (locationAvailableLabel == nil) {
		locationAvailableLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, self.frame.size.width, SMALL_LABEL_HEIGHT)];
		locationAvailableLabel.backgroundColor = [UIColor clearColor];
		locationAvailableLabel.textColor = [UIColor blackColor];
		locationAvailableLabel.textAlignment = NSTextAlignmentCenter;
		locationAvailableLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
		locationAvailableLabel.text = @"NA";
		[self addSubview:locationAvailableLabel];
		[locationAvailableLabel release];
	}
	
	y += SMALL_LABEL_HEIGHT;
	
	if (locationOnHandLabel == nil) {
		locationOnHandLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, y, self.frame.size.width, SMALL_LABEL_HEIGHT)];
		locationOnHandLabel.backgroundColor = [UIColor clearColor];
		locationOnHandLabel.textColor = [UIColor blackColor];
		locationOnHandLabel.textAlignment = NSTextAlignmentCenter;
		locationOnHandLabel.font = [UIFont systemFontOfSize:SMALL_FONT_SIZE];
		locationOnHandLabel.text = @"NA";
		[self addSubview:locationOnHandLabel];
		[locationOnHandLabel release];
	}	
	
	[self updateDisplayValues];
}

- (void) updateDisplayValues {
	
	// If we were given a distribution center
	if (self.distributionCenter != nil) {
		
		if (etaLabel != nil) {
			[etaLabel removeFromSuperview];
			etaLabel = nil;
			CGRect onHandFrame = locationOnHandLabel.frame;
			onHandFrame.origin.x = 0.0f;
			onHandFrame.size.width = self.frame.size.width;
			locationOnHandLabel.frame = onHandFrame;
		}
		
		NSMutableString *idText = [NSMutableString stringWithString:[self.distributionCenter.dcId stringValue]];
		if (self.distributionCenter.isPrimary) {
			[idText appendString:@"*"];
		}
		locationIdLabel.text = idText;
        
        
        NSDecimalNumber *selectedAvailability = [self.distributionCenter.availability getSelectedAvailability];
        NSDecimalNumber *selectedOnHand = [self.distributionCenter.availability getSelectedOnHand];
		locationAvailableLabel.text = [NSString stringWithFormat:@"%@ available", [availableFormatter stringFromNumber:selectedAvailability]];
		NSString *onHandText = [NSString stringWithFormat:@"%@ on hand", [availableFormatter stringFromNumber:selectedOnHand]];
		locationOnHandLabel.text = onHandText;
		
		if ([selectedAvailability compare:[NSDecimalNumber zero]] == NSOrderedSame
                || [selectedAvailability compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
			if (self.distributionCenter.availability.etaDateAsString != nil && 
				    [[self.distributionCenter.availability.etaDateAsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
				NSString *etaText = [NSString stringWithFormat:@" - ETA %@", self.distributionCenter.availability.etaDateAsString];
				CGSize etaSize = [etaText sizeWithFont: [UIFont boldSystemFontOfSize: SMALL_FONT_SIZE]];
				CGSize onHandSize = [onHandText sizeWithFont: [UIFont systemFontOfSize:SMALL_FONT_SIZE]];
				CGFloat startX = floorf((self.frame.size.width - (etaSize.width + onHandSize.width)) / 2.0f);
				CGRect onHandFrame = locationOnHandLabel.frame;
				onHandFrame.origin.x = startX;
				onHandFrame.size.width = onHandSize.width;
				locationOnHandLabel.frame = onHandFrame;
				if (etaLabel == nil) {
					etaLabel = [[UILabel alloc] initWithFrame:CGRectMake(startX + onHandSize.width, onHandFrame.origin.y, etaSize.width, SMALL_LABEL_HEIGHT)];
					etaLabel.backgroundColor = [UIColor clearColor];
					etaLabel.textColor = [UIColor blackColor];
					etaLabel.textAlignment = NSTextAlignmentCenter;
					etaLabel.font = [UIFont boldSystemFontOfSize:SMALL_FONT_SIZE];
					etaLabel.text = etaText;
					[self addSubview:etaLabel];
					[etaLabel release];
				}
			}
			self.backgroundColor = UNAVAILABLE_COLOR;
		} else {
			self.backgroundColor = AVAILABLE_COLOR;
		}

	}
	
	// If we have store information.  If there is distribution information as well it wins.
	if (self.storeId != nil && self.storeAvailability != nil && self.storeOnHand != nil && self.distributionCenter == nil) {
		locationIdLabel.text = [self.storeId stringValue];
		locationAvailableLabel.text = [NSString stringWithFormat:@"%@ available", [availableFormatter stringFromNumber:self.storeAvailability]];
		locationOnHandLabel.text = [NSString stringWithFormat:@"%@ on hand", [availableFormatter stringFromNumber:self.storeOnHand]];
		if ([self.storeAvailability compare:[NSDecimalNumber zero]] == NSOrderedSame) {
			self.backgroundColor = UNAVAILABLE_COLOR;
		} else {
			self.backgroundColor = AVAILABLE_COLOR;
		}

	}
}
	
@end
