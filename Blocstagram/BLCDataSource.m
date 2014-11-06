//
//  BLCDataSource.m
//  Blocstagram
//
//  Created by Collin Adler on 10/31/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCDataSource.h"
#import "BLCUser.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCLoginViewController.h"

@interface BLCDataSource ()

@property (nonatomic, strong) NSString *accessToken;
//we'll redefine this privately so that only this class can modify it
@property (nonatomic, strong, readwrite) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;

@end

@implementation BLCDataSource



+(instancetype) sharedInstance {
    
    //To make sure we only create a single instance of this class we use a function called dispatch_once. This function takes a block of code and ensures that it only runs once
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init {
    self = [super init];
    
    if (self) {
        [self registerForAccessTokenNotification];
    }
    return self;
}

//Immediately after the login controller posts the specified notification, the block provided will run
- (void)registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [self populateDataWithParameters:nil];
    }];
}

//Why we use mutableArrayValueForKey: instead of modifying the _mediaItems array directly? This is done so KVO updates are sent to the observers. If we remove the item from our underlying data source without going through KVC methods, no one (including BLCImagesTableViewController) will receive an update.
-(void) deleteMediaItem:(BLCMedia *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
}

#pragma mark - Instagram Methods

+(NSString *) instagramClientID {
    return @"ce7543fbb8a64901b3ed2a44fe0f122a";
}

- (void) populateDataWithParameters:(NSDictionary *)parameters {
    if (self.accessToken) {
        //with long-running work (network connections, etc.), you should do it in the background to allow the UI (which runs on teh main queue) to remain responsive
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/feed?access_token=%@", self.accessToken];
            for (NSString *parameterName in parameters) {
                //for example, if dictionary contains {count:30}, append "&count=50" to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                //You can use NSURLConnection to handle connecting to a server and downloading the data. NSURLConnection's method returns an NSData and "vends" an NSURLRequest and an NSError
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                NSError *jsonError;
                //NSJSONSerialization is a class that converts data into the more familiar NSDictionary and NSArray objects
                NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                if (feedDictionary) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        //done networking, so go back on the main thread
                        [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                    });
                }
            }
        });
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSLog(@"%@", feedDictionary);
}

#pragma mark - Key/Value Observing

//these methods will make the NSArray property key-value compliant (KVC)
- (NSUInteger) countOfMediaItems {
    return self.mediaItems.count;
}

-(id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
}

-(NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes {
    return [self.mediaItems objectsAtIndexes:indexes];
}

//next, add mutuable accessor methods - KVC methods which allow insertion and deletion of elements from mediaItems

-(void) insertObject:(BLCMedia *)object inMediaItemsAtIndex:(NSUInteger)index {
    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
    [temporaryMutableArray insertObject:object atIndex:index];
    self.mediaItems = temporaryMutableArray;
}

-(void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
    [temporaryMutableArray removeObjectAtIndex:index];
    self.mediaItems = temporaryMutableArray;
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
    [temporaryMutableArray replaceObjectAtIndex:index withObject:object];
    self.mediaItems = temporaryMutableArray;
}

#pragma mark - Completion Handler

-(void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        //NEED TO ADD IMAGES HERE
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

-(void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO) {
        self.isLoadingOlderItems = YES;
        
        //NEED TO ADD IMAGES HERE
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler ) {
            completionHandler(nil);
        }
    }
}

@end





