//
//  BLCMedia.h
//  Blocstagram
//
//  Created by Collin Adler on 10/31/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//This code declares BLCMediaDownloadState as equivalent to NSInteger, with four predefined values (0, 1, 2, and 3.) A BLCMediaDownloadState can theoretically be used anywhere an NSInteger can, since it's the same. If you don't set a default value in code, the default will be 0 (BLCMediaDownloadStateNeedsImgage). 
typedef NS_ENUM(NSInteger, BLCMediaDownloadState) {
    BLCMediaDownloadStateNeedsImage = 0,
    BLCMediaDownloadStateDownloadInProgress = 1,
    BLCMediaDownloadStateNonRecoverableError = 2,
    BLCMediaDownloadStateHasImage = 3
};


//We could import "BLCUser.h", but it is poor practice to import custom classes inside a header file
@class BLCUser;

@interface BLCMedia : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) BLCUser *user;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSArray *comments;

//keep track of a media item's download state in a property
@property (nonatomic, assign) BLCMediaDownloadState downloadState;

- (instancetype) initWithDictionary:(NSDictionary *)mediaDictionary;

@end
