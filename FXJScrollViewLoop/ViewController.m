//
//  ViewController.m
//  FXJScrollViewLoop
//
//  Created by myApplePro01 on 16/6/19.
//  Copyright © 2016年 LSH. All rights reserved.
//

#import "ViewController.h"
#import "FXJLoopScrollView.h"
@interface ViewController ()

@property (nonatomic, strong) FXJLoopScrollView     *ScrollView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *imageArray = @[@"http://dev.res.lsh123.com/img/bb/f1502c3c0d3d7bc5673f22",
                            @"http://dev.res.lsh123.com/img/bb/ff65887c35b2fb0f965669",
                            @"http://dev.res.lsh123.com/img/bb/393125b1639eaca15669ed",
                            [UIImage imageNamed:@"000.jpg"],[UIImage imageNamed:@"001.jpg"],[UIImage imageNamed:@"002.jpg"],[UIImage imageNamed:@"003.jpg"]];
    
    NSArray *titleArray = @[@"第0张图片",@"第一张图片", @"第二张图片", @"第三张",@"第四张",@"第五张",@"第六张"];
    
    self.ScrollView = [[FXJLoopScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width - 100) imageArray:imageArray titleArray:titleArray placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    [self.ScrollView setClickImageViewBlock:^(NSInteger index) {
        NSLog(@"%zd",index);
    }];

    [self.ScrollView setPageImage:[UIImage imageNamed:@"pagImage"] andCurrentImage:[UIImage imageNamed:@"currentImage"]];

    [self.ScrollView setPageColor:[UIColor purpleColor] andCurrentPageColor:[UIColor orangeColor]];
    
    self.ScrollView.titleLabelTextColor = [UIColor redColor];
    
    self.ScrollView.titleFont = [UIFont systemFontOfSize:12];
    
    self.ScrollView.remainTime = 1.5;
    
    self.ScrollView.pageStyle = PageContolStyleAnimated;
    
    self.ScrollView.titleIsHiden = YES;

    self.ScrollView.pageControlPosition = PageControlPositionHide;
    
    [self.view addSubview:_ScrollView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
