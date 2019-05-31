//
//  LameForMP3.h
//  Laboratory-objc
//
//  Created by huangqing on 2019/5/1.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LameForMp3Delegate <NSObject>

@optional

- (void)transcodingFinished:(NSString *)filePath audioTimes:(NSTimeInterval)times;

- (void)transcodingFailured;

@end

/**
 编码状态

 - LameTranscodeStatusNone: 未知
 - LameTranscodeStatusTranscoding: 正在转码
 - LameTranscodeStatusPaused: 暂停转码
 - LameTranscodeStatusFinished: 转码完成
 - LameTranscodeStatusCanceled: 转码取消
 - LameTranscodeStatusFailured: 转码失败
 */
typedef NS_ENUM(NSInteger, LameTranscodeStatus) {
    LameTranscodeStatusNone,
    LameTranscodeStatusTranscoding,
    LameTranscodeStatusPaused,
    LameTranscodeStatusFinished,
    LameTranscodeStatusCanceled,
    LameTranscodeStatusFailured,
};

/**
 将音频文件转码为mp3文件
 主要为录音文件.wav .pcm .caf
 */
@interface LameForMP3 : NSObject

/**
 转码状态
 */
@property (nonatomic, assign, readonly) LameTranscodeStatus status;
/**
 源文件地址
 */
@property (nonatomic, copy, readonly) NSString *sourceFilePath;
/**
 编码后的mp3文件地址
 */
@property (nonatomic, copy, readonly) NSString *mp3FilePath;
/**
 时间长度
 */
@property (nonatomic, assign, readonly) NSTimeInterval mp3Times;
/**
 录音文件的子目录路径
 放在 documents下, 默认 /Documents/Audio/Recorder
 */
@property (nonatomic, copy, readonly) NSString *MP3Directory;
/**
 转码响应委托协议对象
 */
@property (nonatomic, weak) id<LameForMp3Delegate> delegate;

/**
 单例对象

 @return 初始化单例对象
 */
+ (instancetype)sharedInstance;

/**
 配置转码后的mp3文件路径
 
 @param directory 保存的文件路径目录
 */
- (void)configureMP3Directory:(NSString *)directory;

/**
 将源文件转码mp3文件

 @param sourcePcmFilePath 源文件地址
 @param sampleRate 编码率(保持源文件和mp3文件的额编码率一致)
 */
- (void)transcodingMP3File:(NSString *)sourcePcmFilePath sampleRate:(NSInteger)sampleRate;

/**
 完成转码
 */
- (void)finishTranscoding;

/**
 取消转码
 */
- (void)cancelTranscoding;

/**
 删除源文件
 */
- (void)deleteSourceFile;

/**
 删除mp3文件
 */
- (void)deleteMp3File;

@end

