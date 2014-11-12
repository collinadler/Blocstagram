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
#import <UICKeyChainStore.h>
#import <AFNetworking/AFNetworking.h>

@interface BLCDataSource () {
    NSMutableArray *_mediaItems;
}

@property (nonatomic, strong, readwrite) NSString *accessToken;
//we'll redefine this privately so that only this class can modify it
@property (nonatomic, strong, readwrite) NSArray *mediaItems;

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingOlderItems;
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;

//add a property for the manager
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;

@end

@implementation BLCDataSource



+ (instancetype) sharedInstance {
    
    //To make sure we only create a single instance of this class we use a function called dispatch_once. This function takes a block of code and ensures that it only runs once
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:@"https://api.instagram.com/v1/"];
        //init the operation manager and provide a Base URL, which is automatically prepended to any relative URLs we provide later.
        self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        
        AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
        imageSerializer.imageScale = 1.0;
        
        //Since some requests return JSON and others return images, we create a AFCompoundResponseSerializer - saves us from having to specify for each request the type of object we want; AFNetworking will figure it out automatically
        AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
        self.instagramOperationManager.responseSerializer = serializer;
        
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];

                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        for (BLCMedia *mediaItem in self.mediaItems) {
                            if (!mediaItem.image) {
                                [self downloadImageForMediaItem:mediaItem];                                
                            }
                        }
                        [self didChangeValueForKey:@"mediaItems"];
                        [[BLCDataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];
                    } else {
                        // there was nothing saved, so initiate the normal sequence of getting data
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
        }
    }
    return self;
}

//Immediately after the login controller posts the specified notification, the block provided will run
- (void) registerForAccessTokenNotification {
    [[NSNotificationCenter defaultCenter] addObserverForName:BLCLoginViewControllerDidGetAccessTokenNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
        self.accessToken = note.object;
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        //once we get notice of the access token, populate the data
        [self populateDataWithParameters:nil completionHandler:nil];
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

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        NSMutableDictionary *mutableParameters = [@{@"access_token" : self.accessToken} mutableCopy];

        //in the event other parameters (like min_id or max_id) might be passed in
        [mutableParameters addEntriesFromDictionary:parameters];

        //get the resource and, if successful, send it to the parseDataFromFeedDictionary method for parsing
        [self.instagramOperationManager GET:@"users/self/feed"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                            
                                            if (completionHandler) {
                                                completionHandler(nil);
                                            }
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Failure");
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
    }
}

- (void) parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        BLCMedia *mediaItem = [[BLCMedia alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem];
        }
    }
    //informs the KVO system that self.mediaItems is about to be replaced - trigers the notification to the table view to reload the data
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        //this was a pull-to-refresh request
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
    } else if (parameters[@"max_id"]) {
        //this was an infinite scroll request
        if (tmpMediaItems.count == 0) {
            //disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
        }
        [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }
    
    if (tmpMediaItems.count > 0) {
        //write the changes to disk. similar to connecting to teh internet, reading / writing to the disk can be slow so its best to dispatch_async onto a background queue to do the work you need
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];

            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            //then save it as an NSData to the disk
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
            NSError *dataError;
            // the two options ensures the complete file is save and encryts it, respecitvely
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
    }
}

- (void) downloadImageForMediaItem:(BLCMedia *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {  //i.e. we have a url, but no image yet
        mediaItem.downloadState = BLCMediaDownloadStateDownloadInProgress;
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            mediaItem.downloadState = BLCMediaDownloadStateHasImage;
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                        } else {
                                            mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                        mediaItem.downloadState = BLCMediaDownloadStateNonRecoverableError;
                                        
                                        //ALWAYS CHECK THAT THE ERROR.DOMAIN IS WHAT YOU'RE EXPECTING, AS OPPOSED TO, SAY, A NSCOCOAERRORDOMAIN
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            //it is a networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == NSURLErrorInternationalRoamingOff ||
                                                error.code == NSURLErrorCallIsActive ||
                                                error.code == NSURLErrorDataNotAllowed ||
                                                error.code == NSURLErrorRequestBodyStreamExhausted) {
                                                
                                                //it might work if we try again
                                                mediaItem.downloadState = BLCMediaDownloadStateNeedsImage;
                                            }
                                        }
                                    }];
    }
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
//    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
//    [temporaryMutableArray insertObject:object atIndex:index];
//    self.mediaItems = temporaryMutableArray;
    [_mediaItems insertObject:object atIndex:index];
}

-(void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
//    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
//    [temporaryMutableArray removeObjectAtIndex:index];
//    self.mediaItems = temporaryMutableArray;
    [_mediaItems removeObjectAtIndex:index];
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
//    NSMutableArray *temporaryMutableArray = [self.mediaItems mutableCopy];
//    [temporaryMutableArray replaceObjectAtIndex:index withObject:object];
//    self.mediaItems = temporaryMutableArray;
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Completion Handler

-(void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    self.thereAreNoMoreOlderMessages = NO;
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        //use the MIN_ID parameter to let Instagram know we're only interested in items with a higher ID (i.e., newer items)
        NSString *minID = [[self.mediaItems firstObject] idNumber];
        
        if (minID) {
            NSDictionary *parameters = @{@"min_id" : minID};
            
            [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
                self.isRefreshing = NO;
                
                if (completionHandler) {
                    completionHandler(error);
                }
            }];
        }
    }
}

-(void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO) {
        self.isLoadingOlderItems = YES;
        
        NSString *maxID = [[self.mediaItems lastObject] idNumber];
        NSDictionary *parameters = @{@"max_id" : maxID};
        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isLoadingOlderItems = NO;
            
            if (completionHandler) {
                completionHandler(error);
            }
        }];
    }
}

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(BLCMedia *)mediaItem {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token" : self.accessToken};
    
    if (mediaItem.likeState == BLCLikeStateNotLiked) {
        //this will show the circular animation
        mediaItem.likeState = BLCLikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = BLCLikeStateLiked;
            mediaItem.likeCount +=1;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            [self reloadMediaItem:mediaItem];
        }];
    } else if (mediaItem.likeState == BLCLikeStateLiked) {
        mediaItem.likeState = BLCLikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = BLCLikeStateNotLiked;
            mediaItem.likeCount -=1;
            [self reloadMediaItem:mediaItem];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = BLCLikeStateLiked;
            [self reloadMediaItem:mediaItem];
        }];
    }
    [self reloadMediaItem:mediaItem];
}

- (void) reloadMediaItem:(BLCMedia *)mediaItem {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
}

#pragma mark - NSKeyedArchiver

//method creates the full path to a file given a filename
- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

@end





