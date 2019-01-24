//
//  EditableViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/24.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "EditableViewController.h"
#import "UITableViewCell+Laboratory.h"
#import "HomeEditTableCell.h"

@interface EditableViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) NSArray *editableArray;
@property (nonatomic, retain) UITableView *editable;
@end

@implementation EditableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"排序table";
}

- (void)lab_addDataSource {
    _editableArray = @[@"南", @"朝", @"四", @"百", @"八", @"十", @"寺"];
}

- (void)lab_addSubViews {
    _editable = [UITableView lab_initTableFrame:CGRectMake(0, LABTopHeight, SCREENWIDTH, SCREENHEIGHT - LABTopHeight)];
    _editable.delegate = self;
    _editable.dataSource = self;
    [self.view addSubview:_editable];
    _editable.editing = YES;
    
    self.labNavgationBar.rightNavigationBarItem.hidden = NO;
}

#pragma mark - logic

- (void)lab_rightBarItemHandler {
    [_editable setEditing:!_editable.editing animated:YES];
}



#pragma mark - delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    // tableCell不缩进
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *sourceTitle = _editableArray[sourceIndexPath.row];

    NSMutableArray *mutableTitleArray = [_editableArray mutableCopy];
    [mutableTitleArray removeObjectAtIndex:sourceIndexPath.row];
    [mutableTitleArray insertObject:sourceTitle atIndex:destinationIndexPath.row];
    _editableArray = [[NSArray alloc] initWithArray:mutableTitleArray];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeEditTableCell *cell = [HomeEditTableCell lab_tableView:tableView dequeueReusableIdentifier:@"editableIdentity"];
    cell.textLabel.text = _editableArray[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _editableArray.count;
}

@end
