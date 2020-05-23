//
//  OperationViewController.m
//  Laboratory-objc
//
//  Created by huangqing on 2020/5/23.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "OperationViewController.h"
#import "QueueManager.h"

@interface OperationViewController ()
@end

@implementation OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *statButton = [UIButton lab_initButton:CGRectMake(20, LABNavBarHeight + 30, 100, 50) title:@"开始" font:[UIFont systemFontOfSize:13] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [statButton addTarget:self action:@selector(startQueue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:statButton];

    UIButton *endButton = [UIButton lab_initButton:CGRectMake(20, statButton.labBottom + 30, 100, 50) title:@"结束" font:[UIFont systemFontOfSize:13] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [endButton addTarget:self action:@selector(endQueue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:endButton];
}

- (void)startQueue {
    [QueueManager statQueue];
}

- (void)endQueue {
    [QueueManager endQueue];
}

@end
