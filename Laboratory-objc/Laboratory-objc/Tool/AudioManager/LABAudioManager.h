//
//  LABAudioManager.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^LabRecordFinishHandler)(NSString *filePath, NSTimeInterval recordTime);
typedef void(^LabRecordPlayHandler)(NSError *error);
typedef void(^LabRecordingHandler)(NSError *error);
/**
 音频管理
 */
@interface LABAudioManager : NSObject
@property (nonatomic, retain, readonly) AVAudioRecorder *recorder;
/**
 录音的时间
 */
@property (nonatomic, assign, readonly) NSInteger *recordingSeconds;

+ (instancetype)sharedInstance;

/**
 停止录音或者播放
 */
- (void)stopRecordOrAudio;

#pragma mark - 权限
/**
 麦克风授权

 @return YES/NO
 */
+ (BOOL)checkMicroPhoneAuthorization;


#pragma mark - 录音
/**
 开始录音
 */
- (void)startRecord:(NSString *)fileName completion:(LabRecordingHandler)completion;

/**
 停止录音
 */
- (void)stopRecord:(LabRecordFinishHandler)completion;

/**
 暂停录音
 */
- (void)pauseRecord;

/**
 继续录音
 */
- (void)continueRecord:(LabRecordingHandler)completion;


#pragma mark - 录音设置
/**
 删除录音
 */
- (BOOL)deleteRecord:(NSString *)recordPath;


#pragma mark - 播放
- (void)audioPlay:(NSString *)filePath completion:(LabRecordPlayHandler)completion;

- (void)audioStop;

/**
 暂停播放
 */
- (void)audioPaused;

/**
 播放继续
 */
- (void)audioContinued;

@end

