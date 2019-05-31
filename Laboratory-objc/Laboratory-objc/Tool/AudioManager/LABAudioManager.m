//
//  LABAudioManager.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABAudioManager.h"
#import "AYFile.h"
#import "LameForMP3.h"

@interface LABAudioManager()<AVAudioRecorderDelegate, AVAudioPlayerDelegate, LameForMp3Delegate>
@property (nonatomic, retain) AVAudioSession *recordSession;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSTimer *recorderTimer;
@property (nonatomic, retain) NSTimer *playerTimer;
@property (nonatomic, retain, readwrite) AVAudioRecorder *recorder;
@property (nonatomic, assign, readwrite) NSInteger *recordingSeconds;
@property (nonatomic, copy, readwrite) NSString *recorderDirectory;
/**
 播放回调方法
 */
@property (nonatomic, copy) LabRecordPlayHandler playBlock;

@property (nonatomic, copy) LabRecordingHandler recordingBlock;

@property (nonatomic, copy) LabRecordFinishHandler recorderFinishedBlock;
@end

static LABAudioManager *manager = nil;

/* 文件后缀名 */
static NSString *const kLabAudioSuffix = @"wav";
/* 文件目录路径 */
static NSString *const kLabAudioDirectiory = @"Audio/Recorder";

@implementation LABAudioManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.recorderDirectory = kLabAudioDirectiory;
        [LameForMP3 sharedInstance].delegate = manager;
    });
    
    return manager;
}

- (void)configureRecorderDirectory:(NSString *)directory {
    if (directory == nil) {
        directory = kLabAudioDirectiory;
    }else if (directory.length <= 0) {
        directory = @"/";
    }
    // 文件目录标准化
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    if (!isDirectory) {
        directory = [directory stringByReplacingOccurrencesOfString:[directory lastPathComponent] withString:@""];
    }
    // 移除documents路径
    directory = [directory stringByReplacingOccurrencesOfString:[AYFile documents].path withString:@""];
    NSLog(@"子目录路径: %@", directory);
    
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

- (void)stopRecordOrAudio {
    [self pauseRecord];
    [self audioPaused];
}

#pragma mark - 录音
/**
 开始录音
 */
- (void)startRecord:(NSString *)fileName completion:(LabRecordingHandler)completion {
    if (fileName.length <= 0 || fileName == nil) {
        fileName = [NSString stringWithFormat:@"00%ld", (long)[NSDate lab_currentTimeStampMS]];
    }
    
    // 权限判断
    if (![[self class] checkMicroPhoneAuthorization]) {
        if (completion) {
            completion([NSError errorWithDomain:@"没有麦克风权限" code:500 userInfo:nil]);
        }
        [self recordFailure:@"没有麦克风权限"];
        return;
    }
    
    // 添加文件后缀
    [fileName stringByDeletingPathExtension];
    fileName = [fileName stringByAppendingPathExtension:kLabAudioSuffix];
    fileName = [fileName lastPathComponent];
    
    // documents/Audio/Record/xxxx.mp3
    // 创建目录
    NSString *directoryPath = [[AYFile documents].path stringByAppendingPathComponent:_recorderDirectory];
    AYFile *directoryFile = [AYFile fileWithPath:directoryPath];
    [directoryFile makeDirs];
    // 文件完整路径
    fileName = [directoryFile.path stringByAppendingPathComponent:fileName];
    // 删除该路径下的文件
    AYFile *file = [AYFile fileWithPath:fileName];
    [file delete];
    
    // 删除此文件，防止重复
    if (self.recorder) {
        [self.recorder stop];
        self.recorder = nil;
    }
    
    // 开始录音
    WeakSelf(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.recordSession = [AVAudioSession sharedInstance];
        [weakself.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [weakself.recordSession setActive:YES error:nil];
        
        weakself.recorder = [[self class] p_defaultNewRecord:file.path];
        weakself.recorder.delegate = self;
        weakself.recorder.meteringEnabled = YES;
        if (weakself.recorder) {
            @try {
                if ([weakself.recorder prepareToRecord]) {
                    [weakself p_addRecorderTimer];
                    [weakself.recorder record];
                }
            } @catch (NSException *exception) {
                NSLog(@"录音异常:%@", exception.reason);
                if (completion) {
                    completion([NSError errorWithDomain:@"录音出现问题" code:500 userInfo:nil]);
                }
                [self recordFailure:@"录音出现问题"];
            } @finally {}
            if ([weakself.recorder prepareToRecord]) {
                [weakself.recorder record];
                [[LameForMP3 sharedInstance] transcodingMP3File:file.path sampleRate:[weakself.recorder.settings[AVSampleRateKey] integerValue]];
            }
        }else {
            if (completion) {
                completion([NSError errorWithDomain:@"录音开启失败" code:500 userInfo:nil]);
            }
            [self recordFailure:@"录音开启失败"];
        }
    });
}

- (void)stopRecord:(LabRecordFinishHandler)completion {
    [self.recorderTimer invalidate];
    self.recorderTimer = nil;
    if (!self.recorder) {
        if (completion) {
            completion(nil, 0);
        }
        [self recordFailure:@"录制失败"];
        return;
    }
    
    if (completion) {
        completion(self.recorder.url.path, self.recorder.currentTime);
    }
    NSLog(@"%f", self.recorder.currentTime);
    if (self.recorder.currentTime < 1) {
        [self recordFailure:@"录制时长为0"];
        [self deleteRecord:self.recorder.url.path];
    }else {
        [self recordSuccess:self.recorder];
        [[LameForMP3 sharedInstance] cancelTranscoding];
        return;
    }
    _recorderFinishedBlock = completion;

    [self.recorder stop];
    self.recorder = nil;
}

/**
 暂停录制
 */
- (void)pauseRecord {
    if (self.recorder) {
        [self.recorderTimer invalidate];
        self.recorderTimer = nil;
        if ([self.recorder isRecording]) {
            [self.recorder pause];
        }
        [self recordhasPaused];
    }
}

- (void)continueRecord:(LabRecordingHandler)completion {
    [self recordHasContinued];
    if (self.recorder) {
        if (completion) {
            self.recordingBlock = completion;
        }
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [self.recordSession setActive:YES error:nil];
        [self p_addRecorderTimer];
        [self.recorder record];
    }
}

- (BOOL)deleteRecord:(NSString *)recordPath {
    [self.recorderTimer invalidate];
    self.recorderTimer = nil;
    
    if (recordPath.length <= 0 || recordPath == nil) {
        return NO;
    }
    
    [[AYFile fileWithPath:recordPath] delete];
    
    if (self.recorder) {
        return [self.recorder deleteRecording];
    }
    
    return NO;
}

#pragma mark 录音初始化
/**
 新增一个录音

 @param recordPath 录音保存的路径
 @return 新的录音实例对象
 */
+ (AVAudioRecorder *)p_defaultNewRecord:(NSString *)recordPath {
    NSError *recordError = nil;
    //设置录音参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,
                                   nil];
    
    AVAudioRecorder *record = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:recordPath] settings:recordSetting error:&recordError];
    if (recordError) {
        NSLog(@"%@", recordError);
        return nil;
    }
    
    return record;
}

#pragma mark 定时
/**
 初始化开启一个定时器
 */
- (void)p_addRecorderTimer {
    [_recorderTimer invalidate];
    _recorderTimer = nil;
    
    _recorderTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(p_recording) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_recorderTimer forMode:NSRunLoopCommonModes];
}


#pragma mark - 播放
- (void)audioPlay:(NSString *)filePath completion:(LabRecordPlayHandler)completion {
    if (filePath <= 0 || filePath == nil) {
        [self audioPlayedFailure:@"找不到播放文件"];
        return;
    }
    
    NSLog(@"播放文件:%@", filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (completion) {
            completion([NSError errorWithDomain:@"找不到该文件" code:500 userInfo:nil]);
        }
        return;
    }

    self.recordSession = [AVAudioSession sharedInstance];
    [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        NSLog(@"播放错误:%@", error);
        
        if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioPlayedFailure:)]) {
            [_audioDelegate audioPlayedFailure:[NSError errorWithDomain:@"找不到该文件" code:500 userInfo:nil]];
        }
        
        if (completion) {
            completion([NSError errorWithDomain:@"找不到该文件" code:500 userInfo:nil]);
        }
        return;
    }
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 1;
    @try {
        if ([_audioPlayer prepareToPlay]) {
            [self p_addPlayerTimer];
            [_audioPlayer play];
            self.playBlock = completion;
        }else {
            if (completion) {
                completion([NSError errorWithDomain:@"播放失败" code:500 userInfo:nil]);
            }
            [self audioPlayedFailure:@"播放失败"];
        }
    } @catch (NSException *exception) {
        NSLog(@"异常:%@", exception.reason);
        if (completion) {
            completion([NSError errorWithDomain:@"播放出现问题" code:500 userInfo:nil]);
        }
        [self audioPlayedFailure:@"播放出现问题"];
    } @finally {}
}

- (void)audioStop {
    [_playerTimer invalidate];
    _playerTimer = nil;
    
    if (_audioPlayer) {
//        [self audioPlayedInterruption];
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_audioPlayer stop];
    }
}

- (void)audioPaused {
    [_playerTimer invalidate];
    _playerTimer = nil;
    
    if (self.audioPlayer) {
        if ([self.audioPlayer isPlaying]) {
            [_audioPlayer pause];
        }
        [self audioPlayedInterruption];
    }
}

- (void)audioContinued {
    if (_audioPlayer) {
        [self p_addRecorderTimer];
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_audioPlayer play];
    }
}

#pragma mark 定时
/**
 初始化开启一个定时器
 */
- (void)p_addPlayerTimer {
    [_playerTimer invalidate];
    _playerTimer = nil;
    
    _playerTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audioPlaying) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_playerTimer forMode:NSRunLoopCommonModes];
}


#pragma mark - delegate
- (void)recordhasPaused {
    if (_recorder) {
        if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioRecordPaused)]) {
            [_audioDelegate audioRecordPaused];
        }
    }
}

- (void)recordHasContinued {
    if (_recorder) {
        if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioRecordContinued:)]) {
            [_audioDelegate audioRecordContinued:_recorder.currentTime];
        }
    }else {
        [self startRecord:@"" completion:nil];
    }
}

- (void)recordSuccess:(AVAudioRecorder *)recorder {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioRecordSuccess:totalTime:)]) {
        [_audioDelegate audioRecordSuccess:recorder.url.path totalTime:recorder.currentTime];
    }
}

- (void)p_recording {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioRecording:)]) {
        [_audioDelegate audioRecording:MAX(self.recorder.currentTime, 0)];
    }
}

- (void)recordFailure:(NSString *)errorString {
    if (self.audioDelegate && [self.audioDelegate respondsToSelector:@selector(audioRecordFailure:)]) {
        [self.audioDelegate audioRecordFailure:[NSError errorWithDomain:errorString code:500 userInfo:nil]];
    }
}

- (void)recordInterrupted {
    if (self.audioDelegate && [self.audioDelegate respondsToSelector:@selector(audioRecordInterruped)]) {
        [self.audioDelegate audioRecordInterruped];
    }
}

- (void)audioPlayedSuccess {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioPlayedSuccess)]) {
        [_audioDelegate audioPlayedSuccess];
    }
}

- (void)audioPlayedFailure:(NSString *)errorString {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioPlayedFailure:)]) {
        [_audioDelegate audioPlayedFailure:[NSError errorWithDomain:errorString code:500 userInfo:nil]];
    }
}

- (void)audioPlaying {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioPlaying:totalTimes:)]) {
        [_audioDelegate audioPlaying:_audioPlayer.currentTime totalTimes:0];
    }
}

- (void)audioPlayedInterruption {
    if (_audioDelegate && [_audioDelegate respondsToSelector:@selector(audioPlayedInterruped)]) {
        [_audioDelegate audioPlayedInterruped];
    }
}


- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [_recorderTimer invalidate];
    _recorderTimer = nil;
    
    if (!flag) {
        [self recordFailure:@"录音出现未知错误"];
    }
    if (self.recordingBlock) {
        self.recordingBlock(flag ? nil : [NSError errorWithDomain:@"录音出现未知错误" code:500 userInfo:nil]);
        self.recordingBlock = nil;
    }
    if (!flag) {
        [[LameForMP3 sharedInstance] cancelTranscoding];
    }else {
        [[LameForMP3 sharedInstance] finishTranscoding];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [_recorderTimer invalidate];
    _recorderTimer = nil;
    
    if (self.recordingBlock) {
        self.recordingBlock(error);
        self.recordingBlock = nil;
    }
    
    [self recordFailure:@"录音失败"];
    [[LameForMP3 sharedInstance] cancelTranscoding];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [_playerTimer invalidate];
    _playerTimer = nil;
    if (flag) {
        [self audioPlayedSuccess];
    }else {
        [self audioPlayedFailure:@"播放出现未知错误"];
    }
    
    if (self.playBlock) {
        self.playBlock(flag ? nil : [NSError errorWithDomain:@"播放出现未知错误" code:500 userInfo:nil]);
        self.playBlock = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [_playerTimer invalidate];
    _playerTimer = nil;
    
    [self audioPlayedFailure:@"播放失败"];
    
    if (self.playBlock) {
        self.playBlock(error);
        self.playBlock = nil;
    }
}


#pragma mark LameForMp3Delegate
- (void)transcodingFailured {
    NSLog(@"转码失败");
    if (_recorderFinishedBlock) {
        _recorderFinishedBlock(nil, 0);
    }
    [[LameForMP3 sharedInstance] deleteSourceFile];
}

- (void)transcodingFinished:(NSString *)filePath audioTimes:(NSTimeInterval)times {
    /*
     1. 是否转码完成，没有完成直接报录制失败
     2. 如果完成，判断时间是否大于1秒，小于1秒，报失败(删除源文件和mp3文件)
     3. 如果大于1秒，完成转码(删除源文件，保留mp3文件)
     */
    
    if ([LameForMP3 sharedInstance].status == LameTranscodeStatusFinished) {
        if ([LameForMP3 sharedInstance].mp3FilePath.length > 0) {
            if (_recorderFinishedBlock) {
                _recorderFinishedBlock(times > 1 ? filePath : nil, times > 1 ?: 0);
                if (times < 1) {
                    [[LameForMP3 sharedInstance] deleteMp3File];
                }
            }
        }
    }else {
        if (_recorderFinishedBlock) {
            _recorderFinishedBlock(nil, 0);
        }
    }
    
    [[LameForMP3 sharedInstance] deleteSourceFile];
}

@end
