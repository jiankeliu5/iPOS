//
//  ASIHTTPRequest+validateResponse.m
//  iPOS
//
//  Created by Torey Lomenda on 3/25/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "ASIHTTPRequest+Validate.h"

#import "Error.h"

@implementation ASIHTTPRequest (Validate)

- (NSArray *) validateAsXmlContent {
    NSMutableArray *errorList = [NSMutableArray arrayWithCapacity:0];
    
    // Is the status code NOT 200 ??
    if ([self error]) {
        Error *appError = [[[Error alloc] init] autorelease];
        appError.errorId = @"Service Error";
        appError.message = [NSString stringWithFormat:@"Service error.  Status code '%d'.  Description: %@", [self responseStatusCode], error.localizedDescription];
        [errorList addObject:appError];
    } else {
        // I am expecting xml to be returned        
        NSString *contentType = (NSString *) [[self responseHeaders] objectForKey:@"Content-Type"];
        NSString *responseStr = [self responseString];
        NSRange contentTypeText = [[contentType lowercaseString] rangeOfString:@"xml" ];
        NSRange htmlText = [[responseStr lowercaseString] rangeOfString:@"<html>" ];

        if (contentTypeText.location == NSNotFound || htmlText.location != NSNotFound) {
            Error *appError = [[[Error alloc] init] autorelease];
            appError.errorId = @"ERR_CONTENT_TYPE";
            appError.message = [NSString stringWithFormat:@"Service error '%d'.  Expected XML content.", [self responseStatusCode]];
            [errorList addObject:appError];
        }
    }
    
    return errorList;
    
}
@end
