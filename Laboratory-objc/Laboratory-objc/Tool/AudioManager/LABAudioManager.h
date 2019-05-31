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

@protocol LABAudioManagerDelegate <NSObject>

@optional

- (void)audioRecordSuccess:(NSString *)recordFilePath totalTime:(NSTimeInterval)totalTime;

- (void)audioRecordFailure:(NSError *)error;

- (void)audioRecordInterruped;

/**
 录音暂停
 */
- (void)audioRecordPaused;

/**
 录音继续
 */
- (void)audioRecordContinued:(NSTimeInterval)currentTimer;

- (void)audioRecording:(NSTimeInterval)currentTime;

- (void)audioPlayedSuccess;

- (void)audioPlayedFailure:(NSError *)error;

- (void)audioPlayedInterruped;
/**
 播放过程

 @param currentTime 播放的当前时间
 @param totalTime 音频总时长
 */
- (void)audioPlaying:(NSTimeInterval)currentTime totalTimes:(NSTimeInterval)totalTime;

@end



/**
 音频管理
 */
@interface LABAudioManager : NSObject
@property (nonatomic, retain, readonly) AVAudioRecorder *recorder;
/**
 录音的时间
 */
@property (nonatomic, assign, readonly) NSInteger *recordingSeconds;

/**
 委托协议
 */
@property (nonatomic, weak) id<LABAudioManagerDelegate> audioDelegate;
/***
 录音文件的子目录路径, 放在 documents下, 默认 /Documents/Audio/Recorder
 */
@property (nonatomic, copy, readonly) NSString *recorderDirectory;

+ (instancetype)sharedInstance;

/**
 配置录制音频的保存的文件路径

 @param directory 保存的文件路径目录
 */
- (void)configureRecorderDirectory:(NSString *)directory;

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

