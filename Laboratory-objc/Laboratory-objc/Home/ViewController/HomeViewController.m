//
//  HomeViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "HomeViewController.h"
#import "UITableViewCell+Laboratory.h"
#import "HomeTableViewCell.h"

#import "HomeModel.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSArray *childVC;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    _childVC = [HomeModel tableDatasource];
    self.table = [UITableView lab_initTable];
    self.table.frame = CGRectMake(0, LABTopHeight, SCREENWIDTH, SCREENHEIGHT - LABTopHeight - LABTabBarHeight);
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorColor = [UIColor colorWithHexString:@"509AD7"];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.table];
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _childVC.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *homeCell = [HomeTableViewCell lab_tableView:tableView dequeueReusableIdentifier:@"homeReusableIdentifier"];
    HomeModel *model = _childVC[indexPath.row];
    homeCell.textLabel.text = model.title;
    homeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return homeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model = _childVC[indexPath.row];
    if ([model.childViewControllerClassName isEqualToString:NSStringFromClass([LABIMTabViewController class])]) {
        LABIMTabViewController *imTab = [[LABIMTabViewController alloc] init];
        [self.navigationController presentViewController:imTab animated:YES completion:nil];
        return;
    }
    [self lab_pushChildViewControllerName:model.childViewControllerClassName];
}

@end
