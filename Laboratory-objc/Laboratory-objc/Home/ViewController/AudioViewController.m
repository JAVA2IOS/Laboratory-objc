//
//  AudioViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "AudioViewController.h"
//#import "QeeRecordManager.h"

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
    
//    [[QeeRecordManager sharedInstance] configureRecorderDirectory:QeeDefaultRecorderFileDirctory];
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.playButton];

}

- (void)startRecorder {
//    [[QeeRecordManager sharedInstance] startRecord:@"hahah"];
}

- (void)stopRecorder {
//    [[QeeRecordManager sharedInstance] stopRecord];
}


#pragma mark - getter
- (UIButton *)recordButton {
    return _recordButton ?: ({
        _recordButton = [UIButton lab_initFrame:CGRectMake(0, LABTopHeight + 50, 100, 50) cornerRadius:25];
        [_recordButton buttonClick:self selector:@selector(startRecorder)];
        [_recordButton lab_title:@"录音"];
        [_recordButton setBackgroundColor:[UIColor randomColor]];
        
        _recordButton;
    });
}

- (UIButton *)playButton {
    return _playButton ?: ({
        _playButton = [UIButton lab_initFrame:CGRectMake(self.recordButton.labRight + 30, LABTopHeight + 50, 100, 50) cornerRadius:25];
        [_playButton buttonClick:self selector:@selector(stopRecorder)];
        [_playButton lab_title:@"停止录音"];
        [_playButton setBackgroundColor:[UIColor randomColor]];
        
        _playButton;
    });
}
@end
