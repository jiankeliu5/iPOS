//
//  ItemDetailView.m
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemDetailView.h"

#define AVAILABILITY_VIEW_HEIGHT 56.0f

@interface ItemDetailView()

- (void) updateDisplayValues;

@end


@implementation ItemDetailView

@synthesize item;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialize the price formatter
        priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [priceFormatter release];
    priceFormatter = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setItem:(ProductItem *) anItem {
    // We are just assigning the item
    item = anItem;
    
    // Need to update the UI views
    if ([self.subviews count] > 0) {
        [self updateDisplayValues];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Layout
- (void) layoutSubviews {
    CGSize bounds = self.frame.size;
    
    // Keep track of how far down we are in the view
	CGFloat cy = 10.0f;
    
	if (skuLabel == nil) {
		skuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, BIG_LABEL_HEIGHT)];
		skuLabel.backgroundColor = [UIColor clearColor];
		skuLabel.textColor = [UIColor blackColor];
		skuLabel.textAlignment = UITextAlignmentCenter;
		skuLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		skuLabel.text = @"NA";
		[self addSubview:skuLabel];
		[skuLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (descriptionLabel == nil) {
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, BIG_LABEL_HEIGHT)];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor blackColor];
		descriptionLabel.textAlignment = UITextAlignmentCenter;
		descriptionLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		descriptionLabel.text = @"NA";
		[self addSubview:descriptionLabel];
		[descriptionLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (priceLabel == nil) {
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, BIG_LABEL_HEIGHT)];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.textColor = [UIColor blackColor];
		priceLabel.textAlignment = UITextAlignmentCenter;
		priceLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		priceLabel.text = @"NA";
		[self addSubview:priceLabel];
		[priceLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT + 10.0f;
	
	if (storeInfoView == nil) {
		storeInfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, AVAILABILITY_VIEW_HEIGHT)];
		[self addSubview:storeInfoView];
		[storeInfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;
    
	if (dc1InfoView == nil) {
		dc1InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, AVAILABILITY_VIEW_HEIGHT)];
		[self addSubview:dc1InfoView];
		[dc1InfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;
    
	if (dc2InfoView == nil) {
		dc2InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, AVAILABILITY_VIEW_HEIGHT)];
		[self addSubview:dc2InfoView];
		[dc2InfoView release];
	}
	
	cy += AVAILABILITY_VIEW_HEIGHT;
	
	if (dc3InfoView == nil) {
		dc3InfoView = [[AvailabilityView alloc] initWithFrame:CGRectMake(0.0f, cy, self.frame.size.width, AVAILABILITY_VIEW_HEIGHT)];
		[self addSubview:dc3InfoView];
		[dc3InfoView release];
	}
    
    [self updateDisplayValues];
}

#pragma mark -
#pragma mark Private Methods
- (void) updateDisplayValues {
    if (item) {
        skuLabel.text = item.sku;
		descriptionLabel.text = item.description;
		priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [priceFormatter stringFromNumber:item.retailPrice], item.primaryUnitOfMeasure];
		
		[storeInfoView setStoreAvailabilityAtStoreId:item.store.storeId withAvailable:item.store.availability];
		
		if ([item.distributionCenterList count] > 0) {
			DistributionCenter *dc1 = (DistributionCenter *)[item.distributionCenterList objectAtIndex:0];
			[dc1InfoView setDistributionCenter:dc1];
		}
		
		if ([item.distributionCenterList count] > 1) {
			DistributionCenter *dc2 = (DistributionCenter *)[item.distributionCenterList objectAtIndex:1];
			[dc2InfoView setDistributionCenter:dc2];
		}
		
		if ([item.distributionCenterList count] > 2) {
			DistributionCenter *dc3 = (DistributionCenter *)[item.distributionCenterList objectAtIndex:2];
			[dc3InfoView setDistributionCenter:dc3];
		}        
    }
}

@end
