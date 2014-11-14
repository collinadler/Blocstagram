//
//  BLCImageLibraryCollectionViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/13/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCImageLibraryCollectionViewController;

@protocol BLCImageLibraryCollectionViewControllerDelegate <NSObject>

- (void) imageLibraryViewController:(BLCImageLibraryCollectionViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image;

@end

@interface BLCImageLibraryCollectionViewController : UICollectionViewController

@property (nonatomic, weak) NSObject <BLCImageLibraryCollectionViewControllerDelegate> *delegate;

@end
