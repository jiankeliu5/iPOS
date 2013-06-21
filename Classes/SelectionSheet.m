//
//  OrderCart.m
//  iPOS
//
//  Created by Torey Lomenda on 4/7/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//
#import "SelectionSheet.h"
#import "PreviousOrder.h"
#import "iPOSFacade.h"
#import "AlertUtils.h"
#import "SheetXmlMarshaller.h"

@implementation SelectionSheet

@synthesize rooms;
@synthesize customer;
@synthesize contractor;
@synthesize newSheet;
@synthesize projectId, projectUid, projectName, dateCreated, dateUpdated, salesPersonId, archived, storeId;

static SelectionSheet *sheet = nil;

static SelectionSheet *otherSheet = nil;

#pragma mark Singleton Initializer
+ (SelectionSheet *) sharedInstance {
    if (sheet == nil) {
        sheet = [[super allocWithZone:nil] init];
    } 
    
    if (otherSheet == nil) {
        otherSheet = [[super allocWithZone:nil] init];
    } 
    
    return sheet;
    
}

+(id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

+(void) switchSheets {
    SelectionSheet *tempSheet = sheet;
    sheet = otherSheet;
    otherSheet = tempSheet;
}

#pragma mark -
#pragma mark Constructort/Deconstructor
- (id) init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    // Set the facade
    facade = [iPOSFacade sharedInstance];
    
    // Default to working with the new order
    self.newSheet = YES;
    self.projectName = @"Selection Sheet";
    self.archived = NO;
    self.dateCreated = [[NSDate alloc] init];
    self.dateUpdated = [[NSDate alloc] init];
    self.rooms = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) dealloc {
    [rooms release];
    rooms = nil;
    [customer release];
    [contractor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods



-(void) clearSheet {
    if (rooms != nil) {
        [rooms release];
    }
    customer = nil;
    contractor = nil;
    self.projectName = nil;
    self.projectId = nil;
    self.projectUid = nil;
    self.dateCreated = nil;
    self.dateUpdated = nil;
    
}


- (BOOL) saveSheet {
    
    // Save the order
    [facade saveSheet:sheet];
    
    if ([[self errorList] count] == 0 && sheet.rooms != nil) {
        return YES;
    }
    
    // [AlertUtils showModalAlertForErrors:cartOrder.errorList withTitle:@"iPOS"];
    return NO;    
}

/*- (BOOL) saveSheetAndEmail {
 Order *cartOrder = [self getOrder];
 
 // Make sure I can change this to a quote
 if ([cartOrder isNewOrder] || [cartOrder isQuote]) {
 [cartOrder setAsQuote];
 }
 // Save the order
 [facade saveOrder:cartOrder];
 
 if ([cartOrder.errorList count] == 0 && cartOrder.orderId != nil) {
 return YES;
 }
 
 [AlertUtils showModalAlertForErrors:cartOrder.errorList withTitle:@"iPOS"];
 return NO;    
 }*/

#pragma mark -
#pragma mark Room XML Marshalling
+ (NSArray *) listFromXml:(NSString *)xmlString {
    SheetXmlMarshaller *marshaller = [[[SheetXmlMarshaller alloc] init] autorelease];
    return (NSArray *) [marshaller toObjectList:xmlString];    
}
+ (SelectionSheet *) fromXml:(NSString *)xmlString {
    SheetXmlMarshaller *marshaller = [[[SheetXmlMarshaller alloc] init] autorelease];
    return [marshaller toObject:xmlString];    
}

- (NSString *) toXml {
    SheetXmlMarshaller *marshaller = [[[SheetXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];    
}

@end
