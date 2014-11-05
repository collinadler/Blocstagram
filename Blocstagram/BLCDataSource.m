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

@interface BLCDataSource () {
    NSMutableArray * _mediaItems;
}

//we'll redefine this privately so that only this class can modify it
@property (nonatomic, strong) NSArray *mediaItems;

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
        [self addRandomData];
    }
    return self;
}


-(void) addRandomData {
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            BLCMedia *media = [[BLCMedia alloc] init];
            media.user = [self randomUser];
            media.image = image;
            
            //arc4random_uniform() returns a random number between 0 and the number supplied to it
            NSUInteger commentCount = arc4random_uniform(10);
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 0; i <= commentCount; i++) {
                BLCComment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
            }
            
            media.comments = randomComments;
            
            BLCComment *caption = [self randomComment];
            media.caption = caption.text;
            
            [randomMediaItems addObject:media];
        }
    }
    self.mediaItems = randomMediaItems;
}

-(BLCUser *) randomUser {
    BLCUser *user = [[BLCUser alloc] init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10)];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7)];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12)];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
}

-(BLCComment *) randomComment {
    BLCComment *comment = [[BLCComment alloc] init];
    
    comment.from = [self randomUser];
    
    NSUInteger wordCount = arc4random_uniform(20);
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@ ", randomWord];
    }
    comment.text = randomSentence;
    
    return comment;
}

-(NSString *) randomSentenceWithMaximumNumberOfWords:(unsigned int)words {
    
    NSUInteger wordCount = arc4random_uniform(words);
    
    NSMutableString *randomSentence = [[NSMutableString alloc] init];
    
    for (int i = 0; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12)];
        [randomSentence appendFormat:@"%@", randomWord];
    }
    return randomSentence;
}

-(NSString *) randomStringOfLength:(NSUInteger) len {
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [NSString stringWithString:s];
}

//Why we use mutableArrayValueForKey: instead of modifying the _mediaItems array directly? This is done so KVO updates are sent to the observers. If we remove the item from our underlying data source without going through KVC methods, no one (including BLCImagesTableViewController) will receive an update.
-(void) deleteMediaItem:(BLCMedia *)item {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
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
    [_mediaItems insertObject:object atIndex:index];
}

-(void)removeObjectFromMediaItemsAtIndex:(NSUInteger)index {
    [_mediaItems removeObjectAtIndex:index];
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Completion Handler

-(void) requestNewItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
        //create a new random media object and append it to the front of our KVC array. We place the media item at index 0 because that is the index which appears at the top-most table cell
        BLCMedia *media = [[BLCMedia alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"10.jpg"];
        media.caption = [self randomSentenceWithMaximumNumberOfWords:7];
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO insertObject:media atIndex:0];
        
        self.isRefreshing = NO;
        
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

-(void) requestOldItemsWithCompletionHandler:(BLCNewItemCompletionBlock)completionHandler {
    if (self.isLoadingOlderItems == NO) {
        self.isLoadingOlderItems = YES;
        
        BLCMedia *media = [[BLCMedia alloc] init];
        media.user = [self randomUser];
        media.image = [UIImage imageNamed:@"1.jpg"];
        media.caption = [self randomSentenceWithMaximumNumberOfWords:7];
        
        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
        [mutableArrayWithKVO addObject:media];
        
        self.isLoadingOlderItems = NO;
        
        if (completionHandler ) {
            completionHandler(nil);
        }
        
    }
}

@end





