//
//  PlaceHolderView.m
//  HealthDemo
//
//  Created by Steven McCoole on 10/12/10.
//  Copyright 2010 NA. All rights reserved.
//

#import "PlaceHolderView.h"

#pragma mark -
#pragma mark Private Interface
@interface PlaceHolderView ()
@end

#pragma mark -
@implementation PlaceHolderView

@synthesize strokeColor = _strokeColor;
@synthesize strokeWidth = _strokeWidth;
@synthesize bgColor = _bgColor;
@synthesize placeHolderItem = _placeHolderItem;
@synthesize placeHolderLabel = _placeHolderLabel;

#pragma mark Constructors
- (id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self == nil) {
		return nil;
	}
	
	_placeHolderLabel = [[UILabel alloc] init];
	
	// Just to see where the frame is for debugging.
	// [_placeHolderLabel setBackgroundColor:[UIColor greenColor]];
	
	[_placeHolderLabel setTextAlignment:UITextAlignmentCenter];
	[_placeHolderLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
	
	_strokeColor = PH_DEFAULT_STROKE_COLOR;
	_strokeWidth = PH_DEFAULT_STROKE_WIDTH;
	_bgColor = PH_DEFAULT_BG_COLOR;
	
	if (_placeHolderItem == nil) {
		[_placeHolderLabel setText:@"Place Holder"];
	} else {
		[_placeHolderLabel setText:[_placeHolderItem description]];
	}
	
	[self addSubview:_placeHolderLabel];
	
	return self;
}

- (void) dealloc
{
	[self setPlaceHolderLabel:nil];
	[self setStrokeColor:nil];
	[self setBgColor:nil];
	[self setPlaceHolderItem:nil];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (id) placeHolderItem
{
	return _placeHolderItem;
}

- (void) setPlaceHolderItem:(id)placeHolderItem
{
	if (_placeHolderItem != placeHolderItem) {
		[_placeHolderItem autorelease];
		_placeHolderItem = [placeHolderItem retain];
		
		// Get the description of the item into the label for the view.
		[_placeHolderLabel setText:[_placeHolderItem description]];
	}
}

#pragma mark -
#pragma mark Methods

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    
	CGRect borderRect = CGRectMake([self bounds].origin.x,
								   [self bounds].origin.y,
								   [self bounds].size.width,
								   [self bounds].size.height);
	
	CGContextAddRect(context, borderRect);
	CGContextDrawPath(context, kCGPathFillStroke);
	
}

- (void) layoutSubviews
{
	CGRect viewFrame = [self frame];
	CGRect labelRect = CGRectMake(0.0f + _strokeWidth, 
								  0.0f + _strokeWidth, 
								  floor((viewFrame.size.width - (_strokeWidth * 2)) * 0.9f),
								  floor((viewFrame.size.height - (_strokeWidth * 2)) * 0.9f));
	_placeHolderLabel.frame = labelRect;
	CGPoint labelCenter = CGPointMake(viewFrame.size.width / 2.0f, viewFrame.size.height / 2.0f);
	_placeHolderLabel.center = labelCenter;
	
}


@end

