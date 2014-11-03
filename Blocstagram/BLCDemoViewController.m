//
//  BLCDemoViewController.m
//  Blocstagram
//
//  Created by Collin Adler on 11/3/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//

#import "BLCDemoViewController.h"

@interface BLCDemoViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIColor *footerViewColor;
@property (nonatomic, assign) CGRect footerViewFrame;
@end

@implementation BLCDemoViewController

- (instancetype)initWithFooterViewFrame:(CGRect)rect andColor:(UIColor *)color {
    self = [super init];
    if (self) {
        self.footerViewColor = color;
        self.footerViewFrame = rect;
    }
    return self;
}

- (instancetype)initWithFooterViewColor:(UIColor *)color {
    return [self initWithFooterViewFrame:CGRectZero andColor:color];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:footerView];
    footerView.backgroundColor = self.footerViewColor;
    self.footerView = footerView;
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat height = CGRectGetHeight(self.view.bounds)/2;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    self.tableView.frame = CGRectMake(0, 0, width, height);
    self.footerView.frame = self.footerViewFrame;
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
