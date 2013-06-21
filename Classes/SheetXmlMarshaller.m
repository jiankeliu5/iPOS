//
//  RoomXmlMarshaller.m
//  selSheet
//
//  Created by Joshua Walker on 2/16/12.
//  Copyright (c) 2012 Telvent DTN. All rights reserved.
//

#import "SheetXmlMarshaller.h"

#import "Room.h"
#import "Area.h"
#import "ProductItem.h"
#import "SelectionSheet.h"

static NSString * const ORDER_STATUS_ROOT = @"<OrderStatus";

static NSString * const ROOMS_XML = @"<Room>"
"<RoomID>%d</RoomID>"
"<RoomDescription>%@</RoomDescription>"
"</Room>";

static NSString * const AREA_XML = @"<Area>"
"<RoomID>%d</RoomID>"
"<AreaID>%d</AreaID>"
"<AreaDescription>%@</AreaDescription>"
"<AreaNote>%@</AreaNote>"
"</Area>";

static NSString * const ITEM_XML = @"<Item>"
"<RoomID>%d</RoomID>"
"<AreaID>%d</AreaID>"
"<ItemID>%d</ItemID>"
"<StoreID>%@</StoreID>"
"<ItemNumber>%@</ItemNumber>"
"<ItemDescription>%@</ItemDescription>"
"<ItemUOM>%@</ItemUOM>"
"<ItemQty>%@</ItemQty>"
"</Item>";


static NSString * const NEW_SHEET_XML = @""
"<SELSessionDataSet xmlns=\"http://tempuri.org/SELSessionDataSet.xsd\">"
"%@" //Client
"%@" //Contractor
"%@" // Rooms
"<Project>"
"<ProjectName>%@</ProjectName>"
"<DateCreated>%@</DateCreated>"
"<DateUpdated>%@</DateUpdated>"
"<SalesPersonId>%@</SalesPersonId>"
"<StoreId>%@</StoreId>"
"<ClientName>%@</ClientName>"
"<ContractorName>%@</ContractorName>"
"<StatusID>2</StatusID>"
"<Version>2.0</Version>"
"<Archived>false</Archived>"
"<Deleted>false</Deleted>"
"<ProjectUID>%@</ProjectUID>"
"<StatusDescription>Open</StatusDescription>"
"</Project>"
"%@" // Areas
"%@" // Items
"<SessionLog>"
"<SessionID>%@</SessionID>"
"<SysUserID>SEL%@</SysUserID>"
"<ClerkID>%@</ClerkID>"
"<StoreID>%@</StoreID>"
"<EntryDate>%@</EntryDate>"
"</SessionLog>"
"</SELSessionDataSet>";

static NSString * const EXISTING_SHEET_XML = @""
"<SELSessionDataSet xmlns=\"http://tempuri.org/SELSessionDataSet.xsd\">"
"%@" //Client
"%@" //Contractor
"%@" // Rooms
"<Project>"
"<ProjectName>%@</ProjectName>"
"<SalesPersonId>%@</SalesPersonId>"
"<StoreId>%@</StoreId>"
"<ClientName>%@</ClientName>"
"<ContractorName>%@</ContractorName>"
"<StatusID>2</StatusID>"
"<Version>2.0</Version>"
"<Archived>%@</Archived>"
"<Deleted>false</Deleted>"
"<ProjectUID>%@</ProjectUID>"
"<StatusDescription>Open</StatusDescription>"
"</Project>"
"%@" // Areas
"%@" // Items
"<SessionLog>"
"<SessionID>%@</SessionID>"
"<SysUserID>SEL%@</SysUserID>"
"<ClerkID>%@</ClerkID>"
"<StoreID>%@</StoreID>"
"<EntryDate>%@</EntryDate>"
"</SessionLog>"
"</SELSessionDataSet>";



@implementation SheetXmlMarshaller 

#pragma mark -
-(NSArray *) toObjectList:(NSString *)xmlString {
    
    if (xmlString == nil) {
        return nil;
    }
    
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    //NSDictionary *sheetListDict = [[NSDictionary alloc] init];
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    
    // Add the items to the list
    for (CXMLElement *node in [root elementsForName:@"SelectionList"]) {
        //roomDetails = [[Room alloc] init];
        NSDictionary *sheetDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [node elementStringValue:@"ClientName"], @"client",
                                   [node elementStringValue:@"ContractorName"], @"contractor",
                                   [node elementStringValue:@"ProjectName"], @"project",
                                   [node elementStringValue:@"DateCreated"], @"date",
                                   [node elementStringValue:@"ProjectID"], @"projId",
                                   [node elementStringValue:@"ProjectUID"], @"projUid",
                                   nil];
        
        
        [itemList addObject:sheetDict];
        
        [sheetDict release];
        sheetDict = nil;
    }
    
    return itemList;
}


-(id) toObject:(NSString *)xmlString {
    
    if (xmlString == nil) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // The T literal needs to be escaped as 'T' or the match will not work.
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    SelectionSheet *tempSheet = [[[SelectionSheet alloc] init] autorelease];
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    
    CXMLElement *node = [xmlParser rootElement];
    
    NSLog(@"Namespaces %@",[node namespaces]); 
    
    tempSheet.archived = [node elementBoolValue:@"Archived"];
    tempSheet.projectUid = [node elementStringValue:@"ProjectUID"];
    tempSheet.projectId = [node elementStringValue:@"ProjectID"];
    tempSheet.projectName = [node elementStringValue:@"ProjectName"];
    tempSheet.dateCreated = [dateFormatter dateFromString:[node elementStringValue:@"DateCreated"]];
    tempSheet.dateUpdated = [dateFormatter dateFromString:[node elementStringValue:@"DateUpdated"]];
    
    // CXMLElement *contNode = [node 
    for (CXMLElement *custNode in [node elementsForName:@"Contact"]) {
        
        tempSheet.customer = [Customer fromXml:[[custNode childAtIndex:0] XMLString]];
        if ([custNode childCount] > 1) {
            tempSheet.contractor = [Customer fromXml:[[custNode childAtIndex:1] XMLString]];
        }
    }
    
    /* THIS SHOULD BE DONE BY PASSING OFF TO EACH OBJECT TYPES OWN XML MARSHALLER, BUT AS THERE ARE NO INDIVIDUAL CALLS, I MADE IT DO IT ALL IN ONE */
    
    CXMLElement *roomsNode = [node firstElementNamed:@"Rooms"];
    for (CXMLElement *roomNode in [roomsNode elementsForName:@"Room"]) {
        
        Room *tempRoom = [[Room alloc] init];
        
        tempRoom.description = [roomNode elementStringValue:@"RoomDescription"];
        
        CXMLElement *areasNode = [roomNode firstElementNamed:@"Areas"];
        for (CXMLElement *areaNode in [areasNode elementsForName:@"Area"]) {
            
            Area *tempArea = [[Area alloc] init];
            
            tempArea.description = [areaNode elementStringValue:@"AreaDescription"];
            tempArea.note = [areaNode elementStringValue:@"AreaNote"];
            
            
            CXMLElement *itemsNode = [areaNode firstElementNamed:@"Items"];
            
            for (CXMLElement *itemNode in [itemsNode elementsForName:@"Item"]) {
                
                [tempArea.items addObject:[ProductItem fromXml:itemNode.XMLString]];
            }
            
            [tempRoom.areas addObject:tempArea];
            [tempArea release];
            
        }
        
        [tempSheet.rooms addObject:tempRoom];
        [tempRoom release];
    }
    
    return tempSheet;
}


-(NSString *) toXml:(id)marshalObj {
    NSString *sheetXml = @"";
    
    if (marshalObj && [marshalObj isMemberOfClass:[SelectionSheet class]]) {
        SelectionSheet *sheet = (SelectionSheet *) marshalObj;
        
        NSString *clientName = [NSString stringWithFormat:@"%@ %@",sheet.customer.firstName, (sheet.customer.lastName == nil?@"" : sheet.customer.lastName)];
        
        NSString *contractorName = @"";
        if (sheet.contractor != nil) {
            contractorName = [NSString stringWithFormat:@"%@ %@",sheet.contractor.firstName, (sheet.contractor.lastName == nil?@"" : sheet.contractor.lastName)];
        }
        NSString *client = [NSString stringWithFormat:@"<Contact><CustomerName>%@</CustomerName><IsClient>true</IsClient></Contact>",clientName];
        
        NSString *contractor = @"";
        if (sheet.contractor != nil) {
            contractor = [NSString stringWithFormat:@"<Contact><CustomerName>%@</CustomerName><IsClient>false</IsClient></Contact>",contractorName];
        }
        
        NSMutableString *rooms = [[NSMutableString alloc] init];
        NSMutableString *areas = [[NSMutableString alloc] init];
        NSMutableString *items = [[NSMutableString alloc] init];
        
        for (int x=0; x < sheet.rooms.count; x++) {
            Room *room = [sheet.rooms objectAtIndex:x];
            [rooms appendString:[NSString stringWithFormat:ROOMS_XML, x+1, [room description]]];
            for (int y=0; y < room.areas.count; y++) {
                Area *area = [room.areas objectAtIndex:y];
                [areas appendString:[NSString stringWithFormat:AREA_XML, x+1, y+1, [area  description], [area note]]];
                for (int z=0; z < area.items.count; z++) {
                    ProductItem *item = [area.items objectAtIndex:z];
                    [items appendString:[NSString stringWithFormat:ITEM_XML, x+1, y+1, z+1, item.store.storeId, item.sku, item.description, item.primaryUnitOfMeasure, item.itemQty]];//item.itemId, item.description, item.secondaryUnitOfMeasure]];
                }
            }
            
        }
        
        NSDate *createdDate = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        // The T literal needs to be escaped as 'T' or the match will not work.
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        NSString *dateNow = [dateFormatter stringFromDate:createdDate];
        
        // Create the XML (new or previous)
        if (sheet.projectId != nil) {
            sheetXml = [NSString stringWithFormat: EXISTING_SHEET_XML, 
                        client, contractor, rooms, sheet.projectName, sheet.salesPersonId, sheet.storeId, clientName, contractorName, sheet.archived ? @"true" : @"false", sheet.projectUid, areas, items, [self getDynamicUUID], sheet.storeId, sheet.salesPersonId, sheet.storeId, dateNow];
        } else {
            NSString *newUUID = [self getDynamicUUID];
            NSLog(@"UUID is %@",newUUID);
            sheetXml = [NSString stringWithFormat: NEW_SHEET_XML, 
                        client, contractor, rooms, sheet.projectName, (sheet.dateCreated == nil? @"" : [dateFormatter stringFromDate:sheet.dateCreated]), dateNow, sheet.salesPersonId, sheet.storeId, clientName, contractorName, newUUID, areas, items, [self getDynamicUUID],
                        sheet.storeId, sheet.salesPersonId, sheet.storeId, dateNow];
        }
        
        [rooms release];
        [areas release];
        [items release];
    }
    
    return sheetXml;
}

-(NSString*)getDynamicUUID 
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}


@end
