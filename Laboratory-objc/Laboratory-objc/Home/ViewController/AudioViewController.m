//
//  AudioViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "AudioViewController.h"
//#import "LABAudioManager.h"

@interface AudioViewController ()/*<LABAudioManagerDelegate>*/

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

//    [LABAudioManager sharedInstance].audioDelegate = self;
}

/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 [[NSNotificationCenter defaultCenter] postNotificationName:AVAudioSessionInterruptionNotification object:nil];
 [self.view addSubview:self.playButton];
 //    [[LABAudioManager sharedInstance] configureRecorderDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Audio/Record"]];
 
 }
 
 - (void)recordButtonHandler:(UIButton *)button {
 if (button == _recordButton) {
 if (button.highlighted) {
 NSLog(@"高亮");
 }else {
 NSLog(@"不高亮");
 }
 
return;
}

if (button == _playButton) {
    button.selected = !button.selected;
    if (button.selected) {
        [[LABAudioManager sharedInstance] audioPlay:self.recordFilePath completion:^(NSError *error) {
            if (!error) {
                button.selected = NO;
            }else {
                button.selected = YES;
                NSLog(@"文件不存在");
            }
        }];
    }else {
        [[LABAudioManager sharedInstance] audioStop];
    }
}
}

- (void)buttonDown:(UIButton *)button {
    NSLog(@"按下录音");
    [[LABAudioManager sharedInstance] startRecord:@"" completion:nil];
    [_recordButton setTitle:@"播放录音" forState:UIControlStateNormal];
}

- (void)buttonUp:(UIButton *)button {
    if ([LABAudioManager sharedInstance].recorder) {
        [[LABAudioManager sharedInstance] stopRecord:nil];
        [button setTitle:nil forState:UIControlStateHighlighted];
        [button removeTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        return;
    }
    
    button.selected = !button.selected;
    if (button.selected) {
        NSLog(@"显示停止播放");
        [[LABAudioManager sharedInstance] audioPlay:self.recordFilePath completion:nil];
    }else {
        NSLog(@"显示播放录音");
        [[LABAudioManager sharedInstance] audioStop];
    }
}

- (void)buttonCancel:(UIButton *)button {
    NSLog(@"取消了嘛");
    if ([LABAudioManager sharedInstance].recorder) {
        [[LABAudioManager sharedInstance] stopRecord:nil];
        [button setTitle:@"长按录音" forState:UIControlStateNormal];
    }else {
        
    }
}

- (UIButton *)recordButton {
    return _recordButton ?: ({
        _recordButton = [UIButton lab_initButtonTitile:@"长按录音" font:[UIFont systemFontOfSize:18] titleColor:[UIColor whiteColor] backgroundColor:LabColor(@"#52c797")];
        _recordButton.frame = CGRectMake(50, LABNavBarHeight + 100, 100, 100);
        [_recordButton setTitle:@"停止录音" forState:UIControlStateSelected];
        [_recordButton setTitle:@"正在录音" forState:UIControlStateHighlighted];
        [_recordButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchDragOutside];
        _recordButton.labCenterX = self.view.labWidth / 2;
        [_recordButton lab_addRoundingCorners:UIRectCornerAllCorners cornerRadii:1];
        
        _recordButton;
    });
}


#pragma mark - delegate
- (void)audioPlaying:(NSTimeInterval)currentTime totalTimes:(NSTimeInterval)totalTime {
    NSLog(@"正在播放: %ld", (long)currentTime);
}

- (void)audioPlayedFailure:(NSError *)error {
    NSLog(@"播放失败: %@", error.domain);
    _recordButton.selected = NO;
}

- (void)audioPlayedSuccess {
    NSLog(@"播放完成");
    _recordButton.selected = NO;
}

- (void)audioPlayedInterruped {
    NSLog(@"播放中断");
    _recordButton.selected = NO;
}

- (void)audioRecording:(NSTimeInterval)currentTime {
    NSLog(@"正在录制: %ld", (long)currentTime);
}

- (void)audioRecordPaused {
    NSLog(@"录制暂停");
}

- (void)audioRecordContinued:(NSTimeInterval)currentTimer {
    NSLog(@"继续录制, %ld", (long)currentTimer);
}

- (void)audioRecordInterruped {
    NSLog(@"录音中断");
}

- (void)audioRecordSuccess:(NSString *)recordFilePath totalTime:(NSTimeInterval)totalTime {
    NSLog(@"录制完成:%@, 总时间 %ld", recordFilePath, (long)totalTime);
    self.recordFilePath = recordFilePath;
}

- (void)audioRecordFailure:(NSError *)error {
    NSLog(@"录制失败:%@", error.domain);
    _recordButton.selected = NO;
    [_recordButton setTitle:@"长按录音" forState:UIControlStateNormal];
    [_recordButton setTitle:@"正在录音" forState:UIControlStateHighlighted];
    _recordButton.adjustsImageWhenHighlighted = YES;
    [_recordButton addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
}
 */


@end
