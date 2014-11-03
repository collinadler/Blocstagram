//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Collin Adler on 10/31/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLCDataSource : NSObject

//access by calling [BLCDataSource sharedInstance];
+(instancetype) sharedInstance;

//publicly (to other classes) this will be a readonly property
@property (nonatomic, strong, readonly) NSArray *mediaItems;

@end
