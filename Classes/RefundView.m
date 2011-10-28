//
//  RefundView.m
//  iPOS
//
//  Created by Torey Lomenda on 10/26/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//

#import "RefundView.h"
#import "RefundItemTableCell.h"

#import "NSString+StringFormatters.h"

#import "Refund.h"

#define MARGIN 10.0f
#define TOOLBAR_HEIGHT 44.0f
#define LABEL_HEIGHT 18.0f
#define LABEL_FONT_SIZE 16.0f
#define REFUNDTITLE_WIDTH 150.0f

@interface RefundView()

- (void) handleNotesButton: (id) sender;
- (void) handleApplyRefundButton: (id) sender;

- (void) updateDisplayValues;

@end

@implementation RefundView

@synthesize delegate;
@synthesize order;
@synthesize refundTitle;
@synthesize refundTotalLabel;
@synthesize refundToolbar;
@synthesize refundAmountsTableView;

#pragma mark - 
#pragma mark init/dealloc Methods
- (id)initWithFrame:(CGRect)frame andOrder:(Order *)anOrder {
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOrder:anOrder];
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Build the labels
        refundTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        refundTitle.backgroundColor = [UIColor clearColor];
        refundTitle.text = @"Total Refund";
        refundTitle.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        refundTitle.textAlignment = UITextAlignmentLeft;
        
        refundTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        refundTotalLabel.backgroundColor = [UIColor clearColor];
        refundTotalLabel.text = @"$0.00";
        refundTotalLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        refundTotalLabel.textAlignment = UITextAlignmentLeft;
        
        // The table view
        refundAmountsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        refundAmountsTableView.backgroundColor = [UIColor clearColor];
        refundAmountsTableView.dataSource = self;
        refundAmountsTableView.delegate = self;
        
        // The toolbar
        refundToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        refundToolbar.barStyle = UIBarStyleBlack;
        
        UIBarButtonItem *tbFlex = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *tbFixed = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
        tbFixed.width = 10.0f;
        
        // Buttons
        UIBarButtonItem *notesButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"notes.png"] 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(handleNotesButton:)];
        UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"applyCheck.png"] 
                                                                        style:UIBarButtonItemStylePlain 
                                                                       target:self 
                                                                       action:@selector(handleApplyRefundButton:)];
        
        [refundToolbar setItems:[NSArray arrayWithObjects:notesButton, tbFlex, applyButton, nil]];
        [applyButton release];
        [notesButton release];
        
        [self addSubview:refundTitle];
        [self addSubview:refundTotalLabel];
        [self addSubview:refundAmountsTableView];
        [self addSubview:refundToolbar];
        
        [self updateDisplayValues];
    }
    
    return self;
}

- (void)dealloc {
    [refundTitle release];
    refundTitle = nil;
    [refundTotalLabel release];
    refundTotalLabel = nil;
    [refundToolbar release];
    refundToolbar = nil;
    [refundAmountsTableView release];
    refundAmountsTableView = nil;
    
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods
//=========================================================== 
// - setOrder:
//=========================================================== 
- (void)setOrder:(Order *)anOrder {
    if (order != anOrder) {
        order = anOrder;
        
        // Update values
        [self updateDisplayValues];
    }
}



#pragma mark - 
#pragma mark Layout Subviews
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewBounds = self.bounds;
    
    // Layout the labels
    refundTitle.frame = CGRectMake(MARGIN, MARGIN, REFUNDTITLE_WIDTH, LABEL_HEIGHT);
    refundTotalLabel.frame = CGRectMake(MARGIN + REFUNDTITLE_WIDTH, MARGIN, viewBounds.size.width - MARGIN*2 - REFUNDTITLE_WIDTH, LABEL_HEIGHT);
    
    // Layout the table
    refundAmountsTableView.frame = CGRectMake(0, 2*MARGIN + LABEL_HEIGHT, 
                                              viewBounds.size.width, 
                                              viewBounds.size.height - TOOLBAR_HEIGHT - LABEL_HEIGHT - MARGIN*2);
    
    // Layout the toolbar
    refundToolbar.frame = CGRectMake(0, viewBounds.size.height - TOOLBAR_HEIGHT, 
                                              viewBounds.size.width, 
                                              TOOLBAR_HEIGHT);
}

#pragma mark -
#pragma mark UITableViewDataSource methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (order == nil) {
        return 0;
    }
    
    Refund *refund = [order getRefundInfo];
    
    return refund.refundItems == nil ? 0: [refund.refundItems count];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Refund Items";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *refundItemTableIdentifier = [NSString stringWithFormat:@"RefundItemTableIdentifier-%d", indexPath.row];
	RefundItemTableCell *cell = (RefundItemTableCell *)[tableView dequeueReusableCellWithIdentifier:refundItemTableIdentifier];
    
    NSInteger row = indexPath.row;
    Refund *refund = [order getRefundInfo];
    
    if (refund && cell == nil) {
        cell = [[[RefundItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refundItemTableIdentifier] autorelease];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = NO;
    
    cell.refundItem = [refund.refundItems objectAtIndex:row];
    
    return cell;
}

#pragma mark - 
#pragma mark UITableViewDelegate methods

#pragma mark -
#pragma mark Private Methods
- (void) handleApplyRefundButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(applyRefund:)]) {
        [delegate applyRefund:self];
    }
}

- (void) handleNotesButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(editOrderNotes:)]) {
        [delegate editOrderNotes:self];
    }
}

- (void) updateDisplayValues {
    if (order) {
        // The total label text
        refundTotalLabel.text = [NSString formatDecimalNumberAsMoney: [order calcRefundTotal]];
        
        // reload the table data
        [refundAmountsTableView reloadData];
    }
}


@end
