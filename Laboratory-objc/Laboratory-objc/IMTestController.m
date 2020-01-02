//
//  IMTestController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/12/11.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "IMTestController.h"
#import "QHKeyboardView.h"


@interface IMTestController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) UITableView *table;
/// 发送消息按钮
@property (nonatomic, retain) UIButton *sendButton;
/// 关闭按钮
@property (nonatomic, retain) UIButton *closeButton;
/// 重连按钮
@property (nonatomic, retain) UIButton *reconnectButton;


@property (nonatomic, retain) UITextView *textView;

@end

@implementation IMTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RocketSocket测试";
    [self.view addSubview:self.sendButton];
    [self.view addSubview:self.closeButton];
    [self.view addSubview:self.reconnectButton];
    UILabel *label = [UILabel lab_initFrame:CGRectMake(10, _reconnectButton.labBottom + 10, self.view.labWidth - 10 * 2, 50) titleColor:[UIColor whiteColor] backgroundColor:[UIColor randomColor] font:[UIFont systemFontOfSize:16]];
    [self.view addSubview:label];
    [[IMSocket sharedInstance] receivedMessage:^(id  _Nonnull message) {
        label.text = message;
    }];
    
    
    [self.view addSubview:self.textView];
    self.textView.labY = label.labBottom + 10;
}


#pragma mark - logic
- (void)sendMessage {
    [IMSocket sendMessage:@"haha"];
}

- (void)closeConnect {
    [IMSocket close];
}

- (void)connect {
    [IMSocket connect];
}


#pragma mark - getter
- (UIButton *)sendButton {
    return _sendButton ?: ({
        _sendButton = [UIButton lab_initButton:CGRectMake(0, LABTopHeight + 10, 100, 30) title:@"发送消息" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor randomColor]];
        [_sendButton buttonClick:self selector:@selector(sendMessage)];

        _sendButton;

    });
}

- (UIButton *)closeButton {
    return _closeButton ?: ({
        _closeButton = [UIButton lab_initButton:CGRectMake(_sendButton.labRight + 10, _sendButton.labY, 100, 30) title:@"关闭连接" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor randomColor]];
        [_closeButton buttonClick:self selector:@selector(closeConnect)];

        _closeButton;
    });
}

- (UIButton *)reconnectButton {
    return _reconnectButton ?: ({
        _reconnectButton = [UIButton lab_initButton:CGRectMake(_sendButton.labRight + 10, _sendButton.labBottom + 10, 100, 30) title:@"重新连接" font:[UIFont systemFontOfSize:18] titleColor:[UIColor randomColor] backgroundColor:[UIColor whiteColor]];
        [_reconnectButton buttonClick:self selector:@selector(connect)];

        _reconnectButton;
    });
}

- (UITextView *)textView {
    return _textView ?: ({
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.view.labWidth - 10 * 2, 100)];
        QHKeyboardView *keyboard = [[QHKeyboardView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 375)];
        keyboard.backgroundColor = [UIColor randomColor];
        _textView.inputView = keyboard;

        _textView;
    });
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    HomeTableViewCell *homeCell = [HomeTableViewCell lab_tableView:tableView dequeueReusableIdentifier:@"homeReusableIdentifier"];
//    HomeModel *model = _childVC[indexPath.row];
//    homeCell.textLabel.text = model.title;
//    homeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//
//    return homeCell;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    HomeModel *model = _childVC[indexPath.row];
//    [self lab_pushChildViewControllerName:model.childViewControllerClassName];
}
@end
