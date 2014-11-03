//
//  BLCDemoViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/3/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCDemoViewController : UIViewController

- (instancetype)initWithFooterViewColor:(UIColor *)color;
- (instancetype)initWithFooterViewFrame:(CGRect)rect andColor:(UIColor *)color; // Designated Initialzer

@end
