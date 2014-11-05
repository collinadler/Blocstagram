//
//  BLCDataSource.h
//  Blocstagram
//
//  Created by Collin Adler on 10/31/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BLCMedia;

typedef void (^BLCNewItemCompletionBlock)(NSError *error);

@interface BLCDataSource : NSObject

//access by calling [BLCDataSource sharedInstance];
+(instancetype) sharedInstance;

//publicly (to other classes) this will be a readonly property
@property (nonatomic, strong, readonly) NSArray *mediaItems;

//adds a public method to let other classes delete a media item
-(void) deleteMediaItem:(BLCMedia *)item;

-(void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;
-(void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler;


@end
