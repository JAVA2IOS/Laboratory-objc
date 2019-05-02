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
            if ([weakself.recorder prepareToRecord]) {
                [weakself.recorder record];
                [[LameForMP3 sharedInstance] transcodingMP3File:file.path sampleRate:[weakself.recorder.settings[AVSampleRateKey] integerValue]];
            }
        }else {
            if (completion) {
                completion([NSError errorWithDomain:@"录音开启失败" code:500 userInfo:nil]);
            }
        }
    });
}

- (void)stopRecord:(LabRecordFinishHandler)completion {
    if (!self.recorder) {
        if (completion) {
            completion(nil, 0);
        }
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
        if ([self.recorder isRecording]) {
            [self.recorder pause];
        }
    }
}

- (void)continueRecord:(LabRecordingHandler)completion {
    if (self.recorder) {
        if (completion) {
            self.recordingBlock = completion;
        }
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryRecord error:nil];
        [self.recordSession setActive:YES error:nil];
        [self.recorder record];
    }
}

- (BOOL)deleteRecord:(NSString *)recordPath {
    if (recordPath.length <= 0 || recordPath == nil) {
        return NO;
    }
    
    [[AYFile fileWithPath:recordPath] delete];
    
    if (self.recorder) {
        return [self.recorder deleteRecording];
    }
    
    return NO;
}


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


#pragma mark - 播放
- (void)audioPlay:(NSString *)filePath completion:(LabRecordPlayHandler)completion {
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
        if (completion) {
            completion([NSError errorWithDomain:@"找不到该文件" code:500 userInfo:nil]);
        }
        return;
    }
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 1;
    if ([_audioPlayer prepareToPlay]) {
        [_audioPlayer play];
        self.playBlock = completion;
    }else {
        if (completion) {
            completion([NSError errorWithDomain:@"播放失败" code:500 userInfo:nil]);
        }
    }
}

- (void)audioStop {
    if (_audioPlayer) {
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_audioPlayer stop];
    }
}

- (void)audioPaused {
    if (self.audioPlayer) {
        if ([self.audioPlayer isPlaying]) {
            [_audioPlayer pause];
        }
    }
}

- (void)audioContinued {
    if (_audioPlayer) {
        self.recordSession = [AVAudioSession sharedInstance];
        [self.recordSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [_audioPlayer play];
    }
}


#pragma mark - delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
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
    if (self.recordingBlock) {
        self.recordingBlock(error);
        self.recordingBlock = nil;
    }
    
    [[LameForMP3 sharedInstance] cancelTranscoding];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.playBlock) {
        self.playBlock(flag ? nil : [NSError errorWithDomain:@"播放出现未知错误" code:500 userInfo:nil]);
        self.playBlock = nil;
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
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
