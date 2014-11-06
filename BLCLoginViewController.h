//
//  BLCLoginViewController.h
//  Blocstagram
//
//  Created by Collin Adler on 11/4/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BLCLoginViewController : UIViewController

//anyone who wants to be notified when an access token is obtained will use this string
extern NSString *const BLCLoginViewControllerDidGetAccessTokenNotification;

@end
