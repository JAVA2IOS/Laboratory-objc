//
//  HomeViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeModel.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) NSArray *childVC;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _childVC = [HomeModel tableDatasource];
    self.table = [UITableView lab_initTable];
    self.table.frame = CGRectMake(0, LABTopHeight, SCREENWIDTH, SCREENHEIGHT - LABTopHeight - LABTabBarHeight);
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorColor = [UIColor colorWithHexString:@"509AD7"];
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homeReusableIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"homeReusableIdentifier"];
    }
    HomeModel *model = _childVC[indexPath.row];
    cell.textLabel.text = model.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model = _childVC[indexPath.row];
    [self lab_pushChildViewControllerName:model.childViewControllerClassName];
}
@end
