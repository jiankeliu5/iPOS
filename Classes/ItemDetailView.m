//
//  ItemDetailView.m
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemDetailView.h"
#import "UIView+ViewLayout.h"

#define UOM_EXCHANGE_BUTTON_WIDTH 37.0f
#define UOM_EXCHANGE_BUTTON_HEIGHT 37.0f

#define DESCRIPTION_HEIGHT BIG_LABEL_HEIGHT
#define MARGIN 2.0f

@interface ItemDetailView()

- (void) updateDisplayValues;
- (void) switchSelectedUOM: (id) selector;

@end


@implementation ItemDetailView

@synthesize delegate;
@synthesize item, nextRotationDegreesForExchangeButton;

#pragma mark -
#pragma mark Constructor/Deconstructor
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        nextRotationDegreesForExchangeButton = 180;
        
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
    CGSize bounds = self.bounds.size;
    
    // Keep track of how far down we are in the view
	CGFloat cy = MARGIN;
    
	if (skuLabel == nil) {
		skuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, BIG_LABEL_HEIGHT)];
		skuLabel.backgroundColor = [UIColor clearColor];
		skuLabel.textColor = [UIColor blackColor];
		skuLabel.textAlignment = NSTextAlignmentCenter;
		skuLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		skuLabel.text = @"NA";
		[self addSubview:skuLabel];
		[skuLabel release];
	}
	
	cy += BIG_LABEL_HEIGHT;
	
	if (descriptionLabel == nil) {
		descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, DESCRIPTION_HEIGHT)];
		descriptionLabel.backgroundColor = [UIColor clearColor];
		descriptionLabel.textColor = [UIColor blackColor];
		descriptionLabel.textAlignment = NSTextAlignmentCenter;
		descriptionLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		descriptionLabel.text = @"NA";
		[self addSubview:descriptionLabel];
		[descriptionLabel release];
	}
	
	cy += DESCRIPTION_HEIGHT;
	
	if (priceLabel == nil) {
		priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, cy, bounds.width, BIG_LABEL_HEIGHT)];
		priceLabel.backgroundColor = [UIColor clearColor];
		priceLabel.textColor = [UIColor blackColor];
		priceLabel.textAlignment = NSTextAlignmentCenter;
		priceLabel.font = [UIFont boldSystemFontOfSize:LARGE_FONT_SIZE];
		priceLabel.text = @"NA";
		[self addSubview:priceLabel];
		[priceLabel release];
	}
    
    if (uomExchangeButton == nil) {
        uomExchangeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - UOM_EXCHANGE_BUTTON_WIDTH, 0.0f, UOM_EXCHANGE_BUTTON_HEIGHT, UOM_EXCHANGE_BUTTON_HEIGHT)];
        [uomExchangeButton setImage:[UIImage imageNamed:@"exchange.png"] forState:UIControlStateNormal];
        [uomExchangeButton addTarget:self action:@selector(switchSelectedUOM:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:uomExchangeButton];
        uomExchangeButton.hidden = NO;
        [uomExchangeButton release];
    }
	
	// Divide the item rect into 5 rows
	if (storeInfoView == nil) {
		storeInfoView = [[AvailabilityView alloc] initWithFrame:CGRectZero];
		[self addSubview:storeInfoView];
		[storeInfoView release];
	}
	
	if (dc1InfoView == nil) {
		dc1InfoView = [[AvailabilityView alloc] initWithFrame:CGRectZero];
		[self addSubview:dc1InfoView];
		[dc1InfoView release];
	}
	
	if (dc2InfoView == nil) {
		dc2InfoView = [[AvailabilityView alloc] initWithFrame:CGRectZero];
		[self addSubview:dc2InfoView];
		[dc2InfoView release];
	}
	
	if (dc3InfoView == nil) {
		dc3InfoView = [[AvailabilityView alloc] initWithFrame:CGRectZero];
		[self addSubview:dc3InfoView];
		[dc3InfoView release];
	}
    
    CGRect detailRect = CGRectZero;
    CGRect storeInfoRect = CGRectZero;
    CGRect dcInfoRect1 = CGRectZero;
    CGRect dcInfoRect2 = CGRectZero;
    CGRect dcInfoRect3 = CGRectZero;
	
    CGRectDivide(self.bounds, &detailRect, &storeInfoRect, self.bounds.size.height * 0.2, CGRectMinYEdge);
    CGRectDivide(storeInfoRect, &storeInfoRect, &dcInfoRect1, storeInfoRect.size.height * 0.25, CGRectMinYEdge);
    CGRectDivide(dcInfoRect1, &dcInfoRect1, &dcInfoRect2, dcInfoRect1.size.height * 0.33, CGRectMinYEdge);
    CGRectDivide(dcInfoRect2, &dcInfoRect2, &dcInfoRect3, dcInfoRect2.size.height * 0.5, CGRectMinYEdge);
    
    storeInfoView.frame = storeInfoRect;
    dc1InfoView.frame = dcInfoRect1;
    dc2InfoView.frame = dcInfoRect2;
    dc3InfoView.frame = dcInfoRect3;
    
    [self updateDisplayValues];
}

#pragma mark -
#pragma mark Private Methods
- (void) updateDisplayValues {
    if (item) {
        skuLabel.text = item.sku;
		descriptionLabel.text = item.description;
        
        // TODO: If primary and secondary UOM is different display the UOM switch
        NSDecimalNumber *retailPriceForDisplay = [NSDecimalNumber decimalNumberWithString:[item getRetailPriceForDisplay]];
		priceLabel.text = [NSString stringWithFormat:@"%@ / %@", [priceFormatter stringFromNumber:retailPriceForDisplay], [item getSelectedUOMForDisplay]];
		
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
        
        // Do we show or hide exchange button
        if ([item isUOMConversionRequired]) {
            uomExchangeButton.hidden = NO;
        } else {
            uomExchangeButton.hidden = YES;  
        }
    }
}

-(void) switchSelectedUOM:(id)selector {
    [uomExchangeButton rotateView:nextRotationDegreesForExchangeButton animated:YES];    
    
    if (nextRotationDegreesForExchangeButton == 180) {
        nextRotationDegreesForExchangeButton = 0;
    } else {
        nextRotationDegreesForExchangeButton = 180;
    }
    
    // Toggle the item (the change of state automatically triggers a layout of the subview).  Interesting.
    [item toggleUOM];
    
    if (delegate) {
        [delegate unitOfMeasureExchange:self selectedUOM:[item getSelectedUOMForDisplay]];
    }
}

@end
