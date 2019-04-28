//
//  AudioViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "AudioViewController.h"
#import "LABAudioManager.h"

@interface AudioViewController ()

@property (nonatomic, retain) UIButton *recordButton;
@property (nonatomic, retain) UIButton *playButton;
/**
 录音文件路径
 */
@property (nonatomic, copy) NSString *recordFilePath;

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LabColor(@"ffffff");
    
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.playButton];
    
}

- (void)recordButtonHandler:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button == _recordButton) {
        if (button.selected) {
            [[LABAudioManager sharedInstance] startRecord:@"" completion:^(NSError *error) {
                if (!error) {
                    button.selected = NO;
                }
            }];
        }else {
            WeakSelf(self)
            [[LABAudioManager sharedInstance] stopRecord:^(NSString *filePath, NSTimeInterval recordTime) {
                NSLog(@"文件路径:%@, 时间:%ld", filePath, (long)recordTime);
                weakself.recordFilePath = filePath;
            }];
        }
        return;
    }
    
    if (button == _playButton) {
        if (button.selected) {
            [[LABAudioManager sharedInstance] audioPlay:self.recordFilePath completion:^(NSError *error) {
                if (!error) {
                    button.selected = NO;
                }
            }];
        }else {
            [[LABAudioManager sharedInstance] audioStop];
        }
    }
}


- (UIButton *)recordButton {
    return _recordButton ?: ({
        _recordButton = [UIButton lab_initButtonTitile:@"开始录音" font:[UIFont systemFontOfSize:18] titleColor:[UIColor whiteColor] backgroundColor:LabColor(@"#52c797")];
        _recordButton.frame = CGRectMake(50, LABNavBarHeight + 100, 100, 100);
        [_recordButton setTitle:@"停止录音" forState:UIControlStateSelected];
        [_recordButton buttonClick:self selector:@selector(recordButtonHandler:)];
        _recordButton.labCenterX = self.view.labWidth / 2;
        [_recordButton lab_addRoundingCorners:UIRectCornerAllCorners cornerRadii:1];
        
        _recordButton;
    });
}

- (UIButton *)playButton {
    return _playButton ?: ({
        _playButton = [UIButton lab_initButtonTitile:@"播放录音" font:[UIFont systemFontOfSize:18] titleColor:[UIColor whiteColor] backgroundColor:LabColor(@"#ff6b54")];
        _playButton.frame = CGRectMake(50, _recordButton.labBottom + 50, 100, 100);
        [_playButton setTitle:@"停止播放" forState:UIControlStateSelected];
        [_playButton buttonClick:self selector:@selector(recordButtonHandler:)];
        _playButton.labCenterX = self.view.labWidth / 2;
        [_playButton lab_addRoundingCorners:UIRectCornerAllCorners cornerRadii:1];
        
        _playButton;
    });
}

@end
