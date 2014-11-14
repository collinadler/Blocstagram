//
//  BLCCropImageViewController.m
//  Blocstagram
//
//  Created by Collin Adler on 11/13/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCCropImageViewController.h"
#import "BLCCropBox.h"
#import "BLCMedia.h"
#import "UIImage+BLCImageUtilities.h"

@interface BLCCropImageViewController ()

@property (nonatomic, strong) BLCCropBox *cropBox;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@end

@implementation BLCCropImageViewController

- (instancetype) initWithImage:(UIImage *)sourceImage {
    self = [super init];
    
    if (self) {
        self.media = [[BLCMedia alloc] init];
        self.media.image = sourceImage;
        
        self.cropBox = [BLCCropBox new];
        self.topView = [UIToolbar new];
        self.bottomView = [UIToolbar new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //set this to yes so that the crop image doesn't overlap other controllers during navigation controller transitions
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:self.cropBox];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Crop", @"Crop command")
                                                                    style:UIBarButtonItemStyleDone
                                                                   target:self
                                                                   action:@selector(cropPressed:)];

    self.navigationItem.title = NSLocalizedString(@"Crop Image", nil);
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //disable UINavigationController's behvior of automatically adjusting scroll view insets (since we'll position it manually)
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    self.topView.barTintColor = [UIColor colorWithWhite:1.0 alpha:.15];
    self.bottomView.barTintColor = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
}

//this is only responsible for laying out the views we've added, and modifying any superclass behavior
- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //size and center cropBox
    CGRect cropRect = CGRectZero;
    
    CGFloat edgeSize = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    //this makes the cropRect size equal to the min of either the image's width or height
    cropRect.size = CGSizeMake(edgeSize, edgeSize);
    
    CGSize size = self.view.frame.size;
    
    self.cropBox.frame = cropRect;
    self.cropBox.center = CGPointMake(size.width / 2, size.height / 2);
    
    //reduce the scrollview's frame to the same as the crop box's
    self.scrollView.frame = self.cropBox.frame;
    //disable clipsToBound so the user can still see the image outside the crop box's
    self.scrollView.clipsToBounds = NO;
    
    [self recalculateZoomScale];
    
    if (self.hasLoadedOnce == NO) {
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        self.hasLoadedOnce = YES;
    }
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat heightOfTopView = CGRectGetMinY(self.cropBox.frame);
    self.topView.frame = CGRectMake(0, 0, width, heightOfTopView);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.cropBox.frame);
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
}

- (void) cropPressed:(UIBarButtonItem *)sender {
    CGRect visibleRect;
    float scale = 1.0f / self.scrollView.zoomScale / self.media.image.scale;
    visibleRect.origin.x = self.scrollView.contentOffset.x * scale;
    visibleRect.origin.y = self.scrollView.contentOffset.y * scale;
    visibleRect.size.width = self.scrollView.bounds.size.width * scale;
    visibleRect.size.height = self.scrollView.bounds.size.height * scale;
    
    //now, use our UIImage category methods
    UIImage *scrollViewCrop = [self.media.image imageWithFixedOrientation];
    scrollViewCrop = [scrollViewCrop imageCroppedToRect:visibleRect];
    
    [self.delegate cropControlFinishedWithImage:scrollViewCrop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
