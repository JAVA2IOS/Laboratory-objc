//
//  QeeRecordManager.h
//  hhjz
//
//  Created by qeeniao35 on 2019/4/29.
//  Copyright © 2019 Peng Data. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

FOUNDATION_EXTERN NSString *const QeeDefaultRecorderFileDirctory;

FOUNDATION_EXPORT float const QeeMaxAudioRecorderDuration;

FOUNDATION_EXPORT float const QeeMinAudioRecorderDuration;


typedef NS_ENUM(NSInteger, QeeRecordManagerErrorCode) {
    QeeRecordManagerErrorCodeFileNotFound = 1001,
    QeeRecordManagerErrorCodeNoAuthorization,
};



/**
 音频管理
 录音的暂停和继续存在问题，主要在转码mp3出现问题
 */
@interface QeeRecordManager : NSObject
@property (nonatomic, retain, readonly) AVAudioRecorder *recorder;
@property (nonatomic, retain, readonly) AVAudioPlayer *audioPlayer;
/**
 播放时长
 */
@property (nonatomic, assign, readonly) NSTimeInterval audioPlayerTimes;
/**
 录音文件的子目录路径, 放在 documents下, 默认 /Documents/Audio/Recorder
 */
@property (nonatomic, copy, readonly) NSString *recorderDirectory;
/**
 委托协议
 */
//@property (nonatomic, weak) id<QeeAudioManagerDelegate> audioDelegate;

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

/**
 取消录音
 */
- (void)cancelRecroder;

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
- (void)startRecord:(NSString *)fileName;

/**
 停止录音
 */
- (void)stopRecord;

/**
 暂停录音
 */
- (void)pauseRecord;

/**
 继续录音
 */
//- (void)continueRecord:(QeeRecordingHandler)completion;


#pragma mark - 录音设置
/**
 删除录音
 */
- (BOOL)deleteRecord:(NSString *)recordPath;


#pragma mark - 播放
/**
 配置播放参数

 @param filePath 播放的文件地址
 @param completion block回调
 */
//- (void)configureAudioPlayer:(NSString *)filePath completion:(void(^)(BOOL success))completion;
//
//- (void)audioPlay:(NSString *)filePath completion:(QeeRecordPlayHandler)completion;
//
//- (void)audioPlay:(NSString *)filePath playHandler:(QeeRecordPlayHandler)playHandler completion:(QeeRecordFinishHandler)completion;

- (void)audioStop;

/**
 暂停播放
 */
- (void)audioPaused;

/**
 播放继续
 */
- (void)audioContinued;

+ (NSArray<UIImage *> *)recorderPlayedImages;

/**
 移除所有的音频文件，如果使用过
 */
- (void)removeAllAudioFiles;


@end


/**
 下载管理
 服务文件缓存到本地文件为
 /Documents/Audio/Audit/fileName
 */
@interface QeeRecordManager (Download)

#pragma mark - 下载
- (void)dl_downloadAudioFile:(NSString *)serverFilePath completion:(void(^)(NSString *filePath, NSString *downloadUrl, NSError *error))completion;

/**
 播放音频文件
 播放包括了下载和播放两部分

 @param serverFilePath 服务器文件地址，根据服务器文件找到其映射的本地文件
 @param identifier 文件的播放标志符，用来判别文件的唯一性
 */
- (void)dl_playAudioFile:(NSString *)serverFilePath identifier:(id)identifier playHandler:(void(^)(NSError *error))playHandler completion:(void(^)(NSString *filePath, NSString *downloadUrl, NSError *error))completion;

/**
 移除所有本地的审核音频文件
 */
- (void)dl_removeAllLocalCacheAudio;

@end
