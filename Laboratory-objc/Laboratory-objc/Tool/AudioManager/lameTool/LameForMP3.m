//
//  LameForMP3.m
//  Laboratory-objc
//
//  Created by huangqing on 2019/5/1.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LameForMP3.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

@interface LameForMP3()

@property (nonatomic, assign, readwrite) LameTranscodeStatus status;
@property (nonatomic, copy, readwrite) NSString *sourceFilePath;
@property (nonatomic, copy, readwrite) NSString *mp3FilePath;
@property (nonatomic, assign, readwrite) NSTimeInterval mp3Times;
@property (nonatomic, copy, readwrite) NSString *MP3Directory;
@end

static LameForMP3 *once = nil;

@implementation LameForMP3

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        once = [[self alloc] init];
        once.status = LameTranscodeStatusNone;
        once.mp3FilePath = nil;
    });
    
    return once;
}

- (void)configureMP3Directory:(NSString *)directory {
    if (directory == nil || directory.length <= 0) {
        directory = @"/";
    }
    // 文件目录标准化
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    if (!isDirectory) {
        directory = [directory stringByReplacingOccurrencesOfString:[directory lastPathComponent] withString:@""];
    }
    // 移除documents路径
    directory = [directory stringByReplacingOccurrencesOfString:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] withString:@""];
//    DDLog(@"子目录路径: %@", directory);
    
    _MP3Directory = directory;
}

- (void)transcodingMP3File:(NSString *)sourcePcmFilePath sampleRate:(NSInteger)sampleRate {
    
    NSString *inPath = sourcePcmFilePath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:inPath]) {
//        DDLog(@"源文件存在");
    }else {
        [self transcodingFailed];
        return;
    }
    
    // 转码文件保存路径
    NSString *outPath = [[sourcePcmFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
    if (_MP3Directory.length > 0) {
        NSString *fileName = [[[sourcePcmFilePath lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];
        outPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:_MP3Directory] stringByAppendingPathComponent:fileName];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
        [[self class] removeFile:outPath];
    }
    
    _sourceFilePath = sourcePcmFilePath;
    _mp3FilePath = nil;
    _status = LameTranscodeStatusTranscoding;
    _mp3Times = 0;
    
    WeakSelf(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            int read, write;
            
            FILE *pcmFile = fopen([inPath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
            FILE *mp3File = fopen([outPath cStringUsingEncoding:NSASCIIStringEncoding], "wb+");
            
            const int PCM_SIZE = 8192;
            const int MP3_SIZE = 8192;
            short int pcm_buffer[PCM_SIZE * 2];
            unsigned char mp3_buffer[MP3_SIZE];
            
            lame_t lame = lame_init();
            lame_set_mode(lame, JOINT_STEREO);
            // 转码率必须和转码文件参数保持一致
            lame_set_in_samplerate(lame, (int)MAX(sampleRate, 8000));
            lame_set_VBR(lame, vbr_default);
            lame_set_brate(lame, 128);
            lame_set_quality(lame, 2); // 0~9 质量从高到低，推荐2 5（正常质量，转换中等） 7（一般品质）
            lame_init_params(lame);
            
            long curpos;
            BOOL isSkipPCMHeader = NO;
            do {
                curpos = ftell(pcmFile);
                long startPos = ftell(pcmFile);
                fseek(pcmFile, 0, SEEK_END);
                long endPos = ftell(pcmFile);
                long length = endPos - startPos;
                fseek(pcmFile, curpos, SEEK_SET);
                
                if (length > PCM_SIZE * 2 * sizeof(short int)) {
                    
                    if (!isSkipPCMHeader) {
                        /*
                         跳过文件头，防止转码后开头会有噪音
                         */
                        fseek(pcmFile, 4 * 1024, SEEK_CUR);
                        isSkipPCMHeader = YES;
                    }
                    
                    read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcmFile);
                    write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    fwrite(mp3_buffer, write, 1, mp3File);
//                    DDLog(@"正在转码，读取到数据： %d bytes", write);
                }
                
            } while (weakself.status == LameTranscodeStatusTranscoding || weakself.status == LameTranscodeStatusPaused);
            
            
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcmFile);
            write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            
//            DDLog(@"完整文件数据: %d bytes, 文件路径:%@", write, outPath);
            lame_mp3_tags_fid(lame, mp3File);
            
            lame_close(lame);
            fclose(mp3File);
            fclose(pcmFile);
            
        } @catch (NSException *exception) {
//            DDLog(@"异常:%@", exception.reason);
            weakself.status = LameTranscodeStatusFailured;
        } @finally {
            weakself.mp3FilePath = outPath;
            [weakself getAudioTimes];
            if (weakself.status != LameTranscodeStatusFailured && weakself.status != LameTranscodeStatusCanceled) {
                weakself.status = LameTranscodeStatusFinished;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakself.status == LameTranscodeStatusFinished) {
                    [weakself transcodingSuccess];
                }else {
                    [weakself transcodingFailed];
                }
            });
        }
    });
}

- (void)finishTranscoding {
    self.status = LameTranscodeStatusFinished;
}

- (void)cancelTranscoding {
    self.status = LameTranscodeStatusCanceled;
}

- (void)pausedTranscoding {
    self.status = LameTranscodeStatusPaused;
}


#pragma mark - 移除文件
- (void)deleteMp3File {
    [[self class] removeFile:_mp3FilePath];
}

- (void)deleteSourceFile {
    [[self class] removeFile:_sourceFilePath];
}

+ (void)removeFile:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}


/**
 获取时间长度
 */
- (void)getAudioTimes {
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:_mp3FilePath] options:nil];
    CMTime audioDuration = audioAsset.duration;
    _mp3Times = CMTimeGetSeconds(audioDuration);
}


#pragma mark - 响应协议方法
- (void)transcodingSuccess {
    if (_delegate && [_delegate respondsToSelector:@selector(transcodingFinished:audioTimes:)]) {
        [_delegate transcodingFinished:_mp3FilePath audioTimes:_mp3Times];
    }
}

- (void)transcodingFailed {
    if (_delegate && [_delegate respondsToSelector:@selector(transcodingFailured)]) {
        [_delegate transcodingFailured];
    }
}

@end
