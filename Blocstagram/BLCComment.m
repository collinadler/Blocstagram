//
//  BLCComment.m
//  Blocstagram
//
//  Created by Collin Adler on 10/31/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCComment.h"
#import "BLCUser.h"

@implementation BLCComment

- (instancetype) initWithDictionary:(NSDictionary *)commentDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = commentDictionary[@"id"];
        self.from = [[BLCUser alloc] initWithDictionary:commentDictionary[@"from"]];
        self.text = commentDictionary[@"text"];
    }
    return self;
}

@end
