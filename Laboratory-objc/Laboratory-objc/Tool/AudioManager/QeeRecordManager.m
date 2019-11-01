//
//  QeeRecordManager.m
//  hhjz
//
//  Created by qeeniao35 on 2019/4/29.
//  Copyright © 2019 Peng Data. All rights reserved.
//

#if DEBUG
#define QRLog(fmt, ...) NSLog((@"%s:%d:" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define QRLog(...)
#endif


NSString *const QeeDefaultRecorderFileDirctory = @"Audio/Recorder";

float const QeeMaxAudioRecorderDuration = 60.f;
float const QeeMinAudioRecorderDuration = 0.f;

#import "QeeRecordManager.h"
//#import "AYFile.h"
//#import "LameForMP3.h"

@interface QeeRecordManager()<AVAudioRecorderDelegate, AVAudioPlayerDelegate/*, LameForMp3Delegate*/>
@property (nonatomic, retain) AVAudioSession *recordSession;
@property (nonatomic, retain, readwrite) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign, readwrite) NSTimeInterval audioPlayerTimes;
/**
 计时用的时间，毫秒级
 */
@property (nonatomic, assign) NSInteger countingTimesMS;

@property (nonatomic, retain) CADisplayLink *recorderTimer;
@property (nonatomic, retain) CADisplayLink *playerTimer;
@property (nonatomic, retain, readwrite) AVAudioRecorder *recorder;
@property (nonatomic, assign, readwrite) NSInteger *recordingSeconds;
@property (nonatomic, copy, readwrite) NSString *recorderDirectory;
/**
 播放回调方法
 */
//@property (nonatomic, copy) QeeRecordPlayHandler playBlock;
//
//@property (nonatomic, copy) QeeRecordingHandler recordingBlock;
//
//@property (nonatomic, copy) QeeRecordFinishHandler recorderFinishedBlock;

@property (nonatomic, assign) BOOL cancelRecorderStatus;

@end

static QeeRecordManager *manager = nil;

/* 文件后缀名 */
static NSString *const kQeeAudioSuffix = @"wav";
/* 文件目录路径 */
static NSString *const kQeeAudioDirectiory = @"Audio/Recorder";


@implementation QeeRecordManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
//        [LameForMP3 sharedInstance].delegate = manager;
    });
    
    return manager;
}

- (void)configureRecorderDirectory:(NSString *)directory {
    if (directory == nil || directory.length <= 0) {
        directory = QeeDefaultRecorderFileDirctory;
    }
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    // 移除documents路径
    directory = [directory stringByReplacingOccurrencesOfString:documentsDirectory withString:@""];
    directory = [documentsDirectory stringByAppendingPathComponent:directory];
    // 文件目录标准化
    if ([directory pathExtension].length > 0) {
        directory = [directory stringByDeletingLastPathComponent];
    }
    
    QRLog(@"最新目录路径: %@", directory);
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _recorderDirectory = directory;
}

+ (BOOL)checkMicroPhoneAuthorization {
    dispatch_semaphore_t semphore = dispatch_semaphore_create(0);
    __block BOOL accessAuthorization = NO;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        accessAuthorization = granted;
        dispatch_semaphore_signal(semphore);
    }];
    dispatch_semaphore_wait(semphore, DISPATCH_TIME_FOREVER);
    
    return accessAuthorization;
}


#pragma mark - 录音
- (void)startRecord:(NSString *)fileName {
    // 权限判断
    if (![[self class] checkMicroPhoneAuthorization]) {
        QRLog(@"没有麦克风权限");
        return;
    }
    
    if (fileName.length <= 0 || fileName == nil) {
        QRLog(@"文件配置不存在");
        return;
    }
    
    // 添加后缀.wav
    [fileName stringByDeletingPathExtension];
    fileName = [fileName stringByAppendingPathExtension:kQeeAudioSuffix];
    fileName = [fileName lastPathComponent];
    fileName = [_recorderDirectory stringByAppendingPathComponent:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
    }
    
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
    
    [self.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [self.recordSession setActive:YES error:nil];
    
    self.recorder = [self configureAudioRecorder:fileName];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    if (self.recorder) {
        @try {
            if ([self.recorder prepareToRecord]) {
                [self.recorder record];
                [self startTimer:self.recorderTimer];
//                [[LameForMP3 sharedInstance] transcodingMP3File:file.path sampleRate:[weakself.recorder.settings[AVSampleRateKey] integerValue]];
            }
        } @catch (NSException *exception) {
            //                DDLog(@"录音异常:%@", exception.reason);
        } @finally {}
    }else {
//        [self recordFailure:@"录音开启失败" code:QeeRecorderErrorRecorderConfigureFailure];
    }
}

- (void)stopRecord {
    if (_recorder && [_recorder isRecording]) {
        [_recorder stop];
    }
}


- (AVAudioRecorder *)configureAudioRecorder:(NSString *)filePath {
    NSError *recordError = nil;
    //设置录音参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,
                                   nil];
    
    AVAudioRecorder *record = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSetting error:&recordError];
    if (recordError) {
        QRLog(@"录音文件初始化错误:%@", recordError.domain);
        return nil;
    }
    
    return record;
}

- (AVAudioSession *)recordSession {
    return [AVAudioSession sharedInstance];
}

- (CADisplayLink *)recorderTimer {
    if (!_recorderTimer) {
        [_recorderTimer invalidate];
        _recorderTimer = nil;
        _countingTimesMS = 0;
        _recorderTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(recordingCounter)];
    }
    
    return _recorderTimer;
}



#pragma mark - 定时器
- (void)startTimer:(CADisplayLink *)timer {
    [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)recordingCounter {
    if (_recorder) {
        if (_countingTimesMS == 0) {
            _countingTimesMS = _recorder.deviceCurrentTime;
        }
        QRLog(@"%f", _recorder.deviceCurrentTime - _countingTimesMS);
    }
}

- (void)invalidateRecorderTimer {
    [_recorderTimer invalidate];
    _recorderTimer = nil;
}



#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    QRLog(@"停止录音");
    [self invalidateRecorderTimer];
    [self recordingCounter];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    QRLog(@"录音出错");
    [self invalidateRecorderTimer];
    [self recordingCounter];
}
///**
// 开始录音
// */
//- (void)startRecord:(NSString *)fileName completion:(QeeRecordingHandler)completion {
//    if (fileName.length <= 0 || fileName == nil) {
////        fileName = [NSString stringWithFormat:@"00%@", [NSDate getTimeStampNowMS]];
//    }
//    
//    // 权限判断
//    if (![[self class] checkMicroPhoneAuthorization]) {
//        if (completion) {
//            completion([NSError errorWithDomain:@"没有麦克风权限" code:QeeRecorderErrorNoAuthorization userInfo:nil]);
//        }
//        [self recordFailure:@"没有麦克风权限" code:QeeRecorderErrorNoAuthorization];
//        return;
//    }
//    
//    // 添加后缀.wav
//    [fileName stringByDeletingPathExtension];
//    fileName = [fileName stringByAppendingPathExtension:kQeeAudioSuffix];
//    fileName = [fileName lastPathComponent];
//    
//    // documents/Audio/Record/xxxx.mp3
//    // 创建目录
//    NSString *directoryPath = [[AYFile documents].path stringByAppendingPathComponent:kQeeAudioDirectiory];
//    AYFile *directoryFile = [AYFile fileWithPath:directoryPath];
//    [directoryFile makeDirs];
//    // 文件完整路径
//    fileName = [directoryFile.path stringByAppendingPathComponent:fileName];
//    // 删除该路径下的文件
//    AYFile *file = [AYFile fileWithPath:fileName];
//    [file delete];
//    
//    // 删除此文件，防止重复
//    if (self.recorder) {
//        [self.recorder stop];
//        self.recorder = nil;
//    }
//    
//    self.cancelRecorderStatus = NO;
//    
//    // 开始录音
//    WeakSelf(self)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        weakself.recordSession = [AVAudioSession sharedInstance];
//        [weakself.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
//        [weakself.recordSession setActive:YES error:nil];
//        
//        weakself.recorder = [[self class] p_defaultNewRecord:file.path];
//        weakself.recorder.delegate = self;
//        weakself.recorder.meteringEnabled = YES;
//        if (weakself.recorder) {
//            @try {
//                if ([weakself.recorder prepareToRecord]) {
//                    [weakself p_addRecorderTimer];
//                    [weakself.recorder record];
//                    [[LameForMP3 sharedInstance] transcodingMP3File:file.path sampleRate:[weakself.recorder.settings[AVSampleRateKey] integerValue]];
//                }
//            } @catch (NSException *exception) {
////                DDLog(@"录音异常:%@", exception.reason);
//                if (completion) {
//                    completion([NSError errorWithDomain:@"录音出现问题" code:QeeRecorderErrorRecorderConfigureFailure userInfo:nil]);
//                }
//                [self recordFailure:@"录音出现问题" code:QeeRecorderErrorRecorderConfigureFailure];
//            } @finally {}
//        }else {
//            if (completion) {
//                completion([NSError errorWithDomain:@"录音开启失败" code:QeeRecorderErrorRecorderConfigureFailure userInfo:nil]);
//            }
//            [self recordFailure:@"录音开启失败" code:QeeRecorderErrorRecorderConfigureFailure];
//        }
//    });
//}
//
//- (void)cancelRecroder {
//    [self.recorderTimer invalidate];
//    self.recorderTimer = nil;
//    self.cancelRecorderStatus = YES;
//    
//    if ([self.recorder isRecording]) {
//        [self.recorder stop];
//        self.recorder = nil;
//    }
//}
//
//- (void)stopRecord:(QeeRecordFinishHandler)completion {
//    [self.recorderTimer invalidate];
//    self.recorderTimer = nil;
//    if (!self.recorder) {
//        if (completion) {
//            completion(nil, 0);
//        }
//        [[LameForMP3 sharedInstance] cancelTranscoding];
//        return;
//    }
//    if ([self.recorder isRecording]) {
//        _recorderFinishedBlock = completion;
//        [self.recorder stop];
//        self.recorder = nil;
//    }
//}
//
///**
// 暂停录制
// */
//- (void)pauseRecord {
//    if (self.recorder) {
//        [self.recorderTimer invalidate];
//        self.recorderTimer = nil;
//        if ([self.recorder isRecording]) {
//            [self.recorder pause];
//        }
//        [[LameForMP3 sharedInstance] cancelTranscoding];
//        [self recordhasPaused];
//    }
//}
//
//- (void)continueRecord:(QeeRecordingHandler)completion {
//    [self recordHasContinued];
//    if (self.recorder) {
//        if (completion) {
//            self.recordingBlock = completion;
//        }
//        self.recordSession = [AVAudioSession sharedInstance];
//        [self.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
//        [self.recordSession setActive:YES error:nil];
//        [self p_addRecorderTimer];
//        [self.recorder record];
//        [[LameForMP3 sharedInstance] transcodingMP3File:self.recorder.url.path sampleRate:[self.recorder.settings[AVSampleRateKey] integerValue]];
//    }
//}
//
//- (BOOL)deleteRecord:(NSString *)recordPath {
//    [self.recorderTimer invalidate];
//    self.recorderTimer = nil;
//    
//    if (recordPath.length <= 0 || recordPath == nil) {
//        return NO;
//    }
//    
//    [[AYFile fileWithPath:recordPath] delete];
//    
//    [[LameForMP3 sharedInstance] cancelTranscoding];
//    if (self.recorder) {
//        return [self.recorder deleteRecording];
//    }
//    
//    return NO;
//}
//
//#pragma mark 录音初始化
///**
// 新增一个录音
// 
// @param recordPath 录音保存的路径
// @return 新的录音实例对象
// */
//+ (AVAudioRecorder *)p_defaultNewRecord:(NSString *)recordPath {
//    NSError *recordError = nil;
//    //设置录音参数
//    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                   [NSNumber numberWithFloat: 8000],AVSampleRateKey,
//                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
//                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
//                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
//                                   [NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,
//                                   nil];
//    
//    AVAudioRecorder *record = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordPath] settings:recordSetting error:&recordError];
//    if (recordError) {
////        DDLog(@"%@", recordError);
//        return nil;
//    }
//    
//    return record;
//}
//
//#pragma mark 定时
///**
// 初始化开启一个定时器
// */
//- (void)p_addRecorderTimer {
//    [_recorderTimer invalidate];
//    _recorderTimer = nil;
//    _countingTimesMS = 0;
//    _recorderTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_recording)];
//    [_recorderTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//}
//
//
//#pragma mark - 播放
//- (void)configureAudioPlayer:(NSString *)filePath completion:(void(^)(BOOL success))completion {
//    _audioPlayerTimes = 0;
//    if (filePath <= 0 || filePath == nil) {
//        if (completion) {
//            completion(NO);
//        }
//        [self audioPlayedFailure:@"找不到播放文件"];
//        return;
//    }
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//        if (completion) {
//            completion(NO);
//        }
//        [self audioPlayedFailure:@"找不到播放文件"];
//        return;
//    }
//    
//    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filePath] options:nil];
//    CMTime audioDuration = audioAsset.duration;
//    _audioPlayerTimes = CMTimeGetSeconds(audioDuration);
//    self.recordSession = [AVAudioSession sharedInstance];
//    [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    NSError *error = nil;
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
//    if (error) {
//        [self audioPlayedFailure:@"找不到该文件"];
//        
//        if (completion) {
//            completion(NO);
//        }
//        return;
//    }
//    
//    _audioPlayer.delegate = self;
//    _audioPlayer.volume = 1;
//    [_audioPlayer prepareToPlay];
//    if (completion) {
//        completion(YES);
//    }
//}
//
//- (void)audioPlay:(NSString *)filePath playHandler:(QeeRecordPlayHandler)playHandler completion:(QeeRecordFinishHandler)completion {
//    [self configureAudioPlayer:filePath completion:nil];
//    
//    if (_audioPlayer == nil) {
//        [self audioPlayedFailure:@"初始化配置失败"];
//        if (playHandler) {
//            playHandler([NSError errorWithDomain:@"初始化配置失败" code:QeeRecorderErrorRecorderConfigureFailure userInfo:nil]);
//        }
//        return;
//    }
//    
//    WeakSelf(self)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @try {
//            weakself.playBlock = playHandler;
//            weakself.recorderFinishedBlock = completion;
//            [weakself.audioPlayer play];
//            [weakself p_addPlayerTimer];
//            if (playHandler) {
//                playHandler(nil);
//            }
//        } @catch (NSException *exception) {
////            DDLog(@"异常:%@", exception.reason);
//            [self audioPlayedFailure:@"播放出现问题"];
//        } @finally {}
//    });
//}
//
//- (void)audioPlay:(NSString *)filePath completion:(QeeRecordPlayHandler)completion {
//    if (_audioPlayer == nil) {
//        [self configureAudioPlayer:filePath completion:nil];
//    }
//    
//    if (_audioPlayer == nil) {
//        [self audioPlayedFailure:@"初始化配置失败"];
//        if (completion) {
//            completion([NSError errorWithDomain:@"初始化配置失败" code:QeeRecorderErrorRecorderConfigureFailure userInfo:nil]);
//        }
//        return;
//    }
//    
//    WeakSelf(self)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        @try {
//            weakself.playBlock = completion;
//            [weakself.audioPlayer play];
//            [weakself p_addPlayerTimer];
//        } @catch (NSException *exception) {
////            DDLog(@"异常:%@", exception.reason);
//            [self audioPlayedFailure:@"播放出现问题"];
//        } @finally {}
//    });
//    
//}
//
//- (void)audioStop {
//    [_playerTimer invalidate];
//    _playerTimer = nil;
//    
//    if (_audioPlayer) {
//        self.recordSession = [AVAudioSession sharedInstance];
//        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [_audioPlayer stop];
//        [self audioPlayedInterruption];
//    }
//}
//
//- (void)audioPaused {
//    [_playerTimer invalidate];
//    _playerTimer = nil;
//    
//    if (self.audioPlayer) {
//        if ([self.audioPlayer isPlaying]) {
//            [_audioPlayer pause];
//        }
//        [self audioPlayedInterruption];
//    }
//}
//
//- (void)audioContinued {
//    if (_audioPlayer) {
//        [self p_addRecorderTimer];
//        self.recordSession = [AVAudioSession sharedInstance];
//        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [_audioPlayer play];
//    }
//}
//
//#pragma mark 定时
///**
// 初始化开启一个定时器
// */
//- (void)p_addPlayerTimer {
//    [_playerTimer invalidate];
//    _playerTimer = nil;
//    _countingTimesMS = 0;
//    
//    _playerTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(audioPlaying)];
//    [_playerTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//}
//
//
//#pragma mark - delegate
//- (void)recordhasPaused {
//    if (_recorder) {
//        if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioRecordPaused)]) {
//            [_audioDelegate qeeAudioRecordPaused];
//        }
//    }
//}
//
//- (void)recordHasContinued {
//    if (_recorder) {
//        /*
//         时间计算可能存在问题
//         */
//        if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioRecordContinued:)]) {
//            [_audioDelegate qeeAudioRecordContinued:_recorder.currentTime];
//        }
//    }else {
//        // 文件地址也可能有问题
//        [self startRecord:@"" completion:nil];
//    }
//}
//
//- (void)recordSuccess:(AVAudioRecorder *)recorder {
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioRecordSuccess:totalTime:)]) {
//        [_audioDelegate qeeAudioRecordSuccess:[LameForMP3 sharedInstance].mp3FilePath totalTime:[LameForMP3 sharedInstance].mp3Times];
//    }
//}
//
//- (void)p_recording {
//    _countingTimesMS += 1;
//    NSTimeInterval time = (double)_countingTimesMS / 60;
//    if (self.recorder) {
//        time = self.recorder.currentTime;
//    }
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioRecording:)]) {
//        [_audioDelegate qeeAudioRecording:MAX(time, 0)];
//    }
//}
//
//- (void)recordFailure:(NSString *)errorString code:(NSInteger)code {
//    if (self.audioDelegate && [self.audioDelegate respondsToSelector:@selector(qeeAudioRecordFailure:)]) {
//        [self.audioDelegate qeeAudioRecordFailure:[NSError errorWithDomain:errorString code:code userInfo:nil]];
//    }
//}
//
//- (void)recordInterrupted {
//    if (self.audioDelegate && [self.audioDelegate respondsToSelector:@selector(qeeAudioRecordInterruped)]) {
//        [self.audioDelegate qeeAudioRecordInterruped];
//    }
//}
//
//- (void)audioPlayedSuccess {
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioPlayedSuccess:)]) {
//        [_audioDelegate qeeAudioPlayedSuccess:self.audioPlayer.currentTime];
//    }
//    
//    if (_recorderFinishedBlock) {
//        _recorderFinishedBlock(self.audioPlayer.url.path, self.audioPlayer.duration);
//    }
//}
//
//- (void)audioPlayedFailure:(NSString *)errorString {
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioPlayedFailure:)]) {
//        [_audioDelegate qeeAudioPlayedFailure:[NSError errorWithDomain:errorString code:500 userInfo:nil]];
//    }
//    
//    if (_playBlock) {
//        _playBlock([NSError errorWithDomain:errorString code:QeeRecorderErrorCodeFilePlayedFailure userInfo:nil]);
//    }
//}
//
//- (void)audioPlaying {
//    _countingTimesMS += 1;
//    NSTimeInterval time = (double)_countingTimesMS / 60;
//    if (self.audioPlayer) {
//        time = self.audioPlayer.currentTime;
//    }
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioPlaying:totalTimes:)]) {
//        [_audioDelegate qeeAudioPlaying:time totalTimes:_audioPlayerTimes];
//    }
//}
//
//- (void)audioPlayedInterruption {
//    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(qeeAudioPlayedInterruped)]) {
//        [_audioDelegate qeeAudioPlayedInterruped];
//    }
//    
//    if (_playBlock) {
//        _playBlock([NSError errorWithDomain:@"播放中断" code:QeeRecorderErrorCodeFilePlayedInterrupted userInfo:nil]);
//    }
//}
//
//
//- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
//    [_recorderTimer invalidate];
//    _recorderTimer = nil;
//    if (self.cancelRecorderStatus) {
//        self.cancelRecorderStatus = NO;
//        [[LameForMP3 sharedInstance] cancelTranscoding];
//        return;
//    }
//    
//    if (!flag) {
//        [[LameForMP3 sharedInstance] cancelTranscoding];
//    }else {
//        [[LameForMP3 sharedInstance] finishTranscoding];
//    }
//}
//
//- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
//    [_recorderTimer invalidate];
//    _recorderTimer = nil;
//    [[LameForMP3 sharedInstance] cancelTranscoding];
//}
//
//
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
//    [_playerTimer invalidate];
//    _playerTimer = nil;
//    if (flag) {
//        [self audioPlayedSuccess];
//    }else {
//        [self audioPlayedFailure:@"播放出现未知错误"];
//    }
//}
//
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
//    [self audioPlayedFailure:@"播放失败"];
//    
//    [_playerTimer invalidate];
//    _playerTimer = nil;
//}
//
//
//#pragma mark LameForMp3Delegate
//- (void)transcodingFailured {
//    [self recordFailure:@"转码失败" code:QeeRecorderErrorTranscodedFaulure];
//    if (self.recordingBlock) {
//        self.recordingBlock([NSError errorWithDomain:@"录音出现未知错误" code:QeeRecorderErrorTranscodedFaulure userInfo:nil]);
//        self.recordingBlock = nil;
//    }
//    
////    [[LameForMP3 sharedInstance] deleteMp3File];
////    [[LameForMP3 sharedInstance] deleteSourceFile];
//}
//
//- (void)transcodingFinished:(NSString *)filePath audioTimes:(NSTimeInterval)times {
//    /*
//     1. 是否转码完成，没有完成直接报录制失败
//     2. 如果完成，判断时间是否大于1秒，小于1秒，报失败(删除源文件和mp3文件)
//     3. 如果大于1秒，完成转码(删除源文件，保留mp3文件)
//     */
////    DDLog(@"转码完成，总时长:%f", times);
//    /*
//    if ([LameForMP3 sharedInstance].status == LameTranscodeStatusFinished) {
//        if ([LameForMP3 sharedInstance].mp3FilePath.length > 0) {
//            if (_recorderFinishedBlock) {
//                _recorderFinishedBlock(times > 1 ? filePath : nil, times > 1 ?: 0);
//            }
//            if (self.recordingBlock) {
//                self.recordingBlock(times > 1 ? nil : [NSError errorWithDomain:@"录制时长为0" code:QeeRecorderErrorRecorderLessTime userInfo:nil]);
//                self.recordingBlock = nil;
//            }
//            if (times < 1) {
//                [self recordFailure:@"录制时长为0" code:QeeRecorderErrorRecorderLessTime];
//                [[LameForMP3 sharedInstance] deleteMp3File];
//            }else {
//                [self recordSuccess:_recorder];
//            }
//        }
//    }else {
//        if (_recorderFinishedBlock) {
//            _recorderFinishedBlock(nil, 0);
//        }
//        if (self.recordingBlock) {
//            self.recordingBlock([NSError errorWithDomain:@"转码失败" code:QeeRecorderErrorTranscodedFaulure userInfo:nil]);
//            self.recordingBlock = nil;
//        }
//        [self recordFailure:@"转码失败" code:QeeRecorderErrorTranscodedFaulure];
//    }
//    
//    [[LameForMP3 sharedInstance] deleteSourceFile];
//     */
//}
//
//
//+ (NSArray<UIImage *> *)recorderPlayedImages {
//    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
//    for (int i = 1; i < 25; i ++) {
//        NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"audio_play_%d", i] ofType:@"png"];
//        
//        [dataArray addObject:[UIImage imageWithContentsOfFile:filePath]];
//    }
//    
//    return dataArray;
//}
//
//
//- (void)removeAllAudioFiles {
//    if (self.recorderDirectory) {
//        NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.recorderDirectory];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:directory]) {
//            [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
//        }
//    }
//    
//    NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:kQeeAudioDirectiory];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:directory]) {
//        [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
//    }
//    
//}

@end


@implementation QeeRecordManager (Download)

#pragma mark - 下载
//- (void)dl_downloadAudioFile:(NSString *)serverFilePath completion:(void(^)(NSString *filePath, NSString *downloadUrl, NSError *error))completion {
//    if (serverFilePath.length <= 0) {
//        if (completion) {
//            completion(nil, serverFilePath, [NSError errorWithDomain:@"文件被服务器扔掉了~" code:QeeRecorderErrorCodeFileNotFound userInfo:nil]);
//        }
//        return;
//    }
//    
//    NSString *path = [[AYFile documents].path stringByAppendingPathComponent:@"Audio/Audit"];
//    [[AYFile fileWithPath:path] makeDirs];
//    path = [path stringByAppendingPathComponent:[serverFilePath lastPathComponent]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        if (completion) {
//            completion(path, serverFilePath, nil);
//        }
//        return;
//    }
//    
//    // 不存在则下载
//    NSURL *URL = [NSURL URLWithString:serverFilePath];
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //AFN3.0+基于封住URLSession的句柄
//    /*
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    //请求
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    //下载Task操作
//    NSURLSessionDownloadTask *_downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        //进度
//        
//    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//       return [NSURL fileURLWithPath:path];
//    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
//        NSString *armFilePath = [filePath path];// 将NSURL转成NSString
//        if (completion) {
//            completion(armFilePath, serverFilePath, nil);
//        }
//    }];
//    
//    [_downloadTask resume];
//     */
//}
//
//- (void)dl_playAudioFile:(NSString *)serverFilePath identifier:(id)identifier playHandler:(void (^)(NSError *))playHandler completion:(void (^)(NSString *, NSString *, NSError *))completion {
//
//    [self dl_downloadAudioFile:serverFilePath completion:^(NSString *filePath, NSString *downloadUrl, NSError *error) {
//        if (error) {
//            if (playHandler) {
//                playHandler(error);
//            }
//        }else {
//
//            [self audioPlay:filePath playHandler:playHandler completion:^(NSString *filePath, NSTimeInterval recordTime) {
//                if (completion) {
//                    completion(filePath, serverFilePath, nil);
//                }
//            }];
//        }
//    }];
//}
//
//- (void)dl_removeAllLocalCacheAudio {
//    NSString *directory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Audio/Audit"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:directory]) {
//        [[NSFileManager defaultManager] removeItemAtPath:directory error:nil];
//    }
//}

@end
