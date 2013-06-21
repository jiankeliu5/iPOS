//
//  AreasViewController.h
//  selSheet
//
//  Created by Joshua Walker on 2/10/12.
//  Copyright (c) 2012 Object Partners Inc. All rights reserved.
//


#import "AbstractTableViewController.h"
#import "AddFromListViewController.h"
#import "Room.h"

@interface AreasViewController : AbstractTableViewController <UITableViewDataSource, UITableViewDelegate, ModalViewControllerDelegate> {
    
}

@property (nonatomic, retain) Room *parentRoom;
@property (nonatomic, retain) NSArray *addAreaList;

- (id)initWithRoom:(Room *)room;

@end