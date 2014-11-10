//
//  BLCMediaFullScreenViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/8/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLCMedia;

@interface BLCMediaFullScreenViewController : UIViewController

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

//create a custom view controller initializer that passes a BLCMedia to display
- (instancetype) initWithMedia:(BLCMedia *)media;

- (void) centerScrollView;

@end
