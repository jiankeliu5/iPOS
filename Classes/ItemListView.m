//
//  ItemListView.m
//  iPOS
//
//  Created by Torey Lomenda on 5/5/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ItemListView.h"

#import "ItemTableCell.h"

#define MAX_SEARCH_RESULT 200

#define MARGIN_TOP 0.0f
#define MATCHES_LABEL_FONT_SIZE 14.0f
#define MATCHES_LABEL_HEIGHT 16.0f

#define TABLE_HEIGHT 276.0f

@interface ItemListView()

- (void) updateDisplayValues;

@end

@implementation ItemListView

@synthesize itemList, viewDelegate;

#pragma mark -
#pragma mark Contructor/Deconstructor
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // Add the label to the view
        matchesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        matchesLabel.font = [UIFont boldSystemFontOfSize:MATCHES_LABEL_FONT_SIZE];
        matchesLabel.textAlignment = UITextAlignmentCenter;
        matchesLabel.backgroundColor = [UIColor colorWithRed:170.0f/255.0f green:204.0f/255.0f blue:0.0f alpha:1.0f];
        
        [self addSubview:matchesLabel];
        [matchesLabel release];
        
        // Add the table
        itemListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        itemListTable.backgroundColor = [UIColor clearColor];
        itemListTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

        itemListTable.delegate = self;
        itemListTable.dataSource = self;
        
        [self addSubview:itemListTable];
        [itemListTable release];
    }
    return self;
}

#pragma mark -
#pragma mark Accessors

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors
- (void) setItemList:(NSArray *) anItemList {
    itemList = anItemList;
    
    if ([self.subviews count] > 0) {
        [self updateDisplayValues];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Public Methods
- (void) deselectTableRow {
    NSIndexPath* selection = [itemListTable indexPathForSelectedRow];
	if (selection) {
		[itemListTable deselectRowAtIndexPath:selection animated:YES];
	}
}


#pragma mark -
#pragma mark Layout the subview
- (void) layoutSubviews {
    CGSize bounds = self.frame.size;
    
    // Layout the label and the table
    matchesLabel.frame = CGRectMake(0, MARGIN_TOP, bounds.width, MATCHES_LABEL_HEIGHT);
    itemListTable.frame = CGRectMake(0, MARGIN_TOP + MATCHES_LABEL_HEIGHT, bounds.width, TABLE_HEIGHT);
    
    [self updateDisplayValues];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ProductItem *item = [self.itemList objectAtIndex:indexPath.row];
    
    if (viewDelegate) {
        [viewDelegate selectItem:item];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.itemList == nil) ? 0 : [self.itemList count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ProductItem *item = [self.itemList objectAtIndex:indexPath.row];
	NSString *itemCellIdentifier = item.sku;
	
	ItemTableCell *cell = (ItemTableCell *)[tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
	
	if (cell == nil) {
		cell = [[[ItemTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:itemCellIdentifier] autorelease];
	}
    
	cell.item = item;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}

#pragma mark -
#pragma mark Private Methods
- (void) updateDisplayValues {
    if (self.itemList) {
        int count = [itemList count];
        
        if (count < MAX_SEARCH_RESULT) {
            matchesLabel.text = [NSString stringWithFormat:@"%d matches found", count];
        } else {
            matchesLabel.text = @"More than 200 matches.  Refine search.";
        }
    } else {
        matchesLabel.text = @"No matches found";
    }
    
    // Reload the table data
    [itemListTable reloadData];
}

@end
