//
//  LABAudioManager.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/25.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABAudioManager.h"
#import "AYFile.h"

@interface LABAudioManager()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, retain) AVAudioSession *recordSession;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain, readwrite) AVAudioRecorder *recorder;
@property (nonatomic, assign, readwrite) NSInteger *recordingSeconds;
/**
 播放回调方法
 */
@property (nonatomic, copy) LabRecordPlayHandler playBlock;

@property (nonatomic, copy) LabRecordingHandler recordingBlock;

@end

static LABAudioManager *manager = nil;

/* 文件后缀名 */
static NSString *const kLabAudioSuffix = @".wav";
/* 文件目录路径 */
static NSString *const kLabAudioDirectiory = @"Audio/Record";

/* 监听属性 */
static NSString *const kLabAudioMonitorProperty = @"currentTime";


@implementation LABAudioManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        
    });
    
    return manager;
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
    
    // 添加后缀.mp3
    if (![[fileName lowercaseString] hasSuffix:kLabAudioSuffix]) {
        fileName = [fileName stringByAppendingString:kLabAudioSuffix];
    }
    
    fileName = [fileName lastPathComponent];
    
    // documents/Audio/Record/xxxx.mp3
    // 创建目录
    NSString *directoryPath = [[AYFile documents].path stringByAppendingPathComponent:kLabAudioDirectiory];
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
        return;
    }
    
    if (completion) {
        completion(self.recorder.url.path, self.recorder.currentTime);
        [self.recorder stop];
    }
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
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    if (self.recordingBlock) {
        self.recordingBlock(error);
        self.recordingBlock = nil;
    }
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

@end
