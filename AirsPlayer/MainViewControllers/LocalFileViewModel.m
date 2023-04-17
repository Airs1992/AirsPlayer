//
//  LocalFileViewModel.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/11.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "LocalFileViewModel.h"
#import "FileModel.h"
#import "KxMovieDecoder.h"
#import "HistoryArchive.h"

@interface LocalFileViewModel()

@property(nonatomic, strong) NSUserDefaults *ud;

@property (nonatomic, strong) HistoryArchive *historyArchive;
@property (nonatomic, strong) NSMutableArray *historyArchiveArray;
@property (nonatomic, strong) NSMutableArray *duartionArray;

@end

@implementation LocalFileViewModel

-(NSUserDefaults *)ud
{
    if (_ud == nil) {
        _ud = [NSUserDefaults standardUserDefaults];
    }
    return _ud;
}

- (NSArray *)getLocalVideoFiles
{
    self.duartionArray = [NSMutableArray arrayWithCapacity:1];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ducumentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:ducumentsDirectory error:NULL];
    FileModel *fileModel;
    NSMutableArray *videoArrays=[NSMutableArray array];
    
    self.historyArchiveArray=[NSMutableArray arrayWithCapacity:1];
    self.historyArchive=[[HistoryArchive alloc] init];
    self.historyArchiveArray=(NSMutableArray *)[self.historyArchive loadArchivesWithType:TypeLocal];
    if (self.historyArchiveArray.count<1) {
        self.historyArchiveArray=[NSMutableArray arrayWithCapacity:1];
    }
    
    for (int j=0; j<self.historyArchiveArray.count; j++) {
        FileModel *oneinfo = self.historyArchiveArray[j];
        [self.duartionArray addObject: oneinfo.duartionStr];
    }
    
    for (int i=0; i<contents.count; i++) {
        fileModel=[[FileModel alloc] init];
        NSString *testPath=contents[i];
        NSString *videoPath = [[NSString alloc] initWithFormat:@"%@/%@",ducumentsDirectory,testPath];
        NSString *exestr = [videoPath pathExtension];
        NSArray *fileTypeArr = @[@"m4v", @"wmv", @"3gp", @"mp4", @"mov", @"avi", @"mkv", @"mpeg", @"mpg", @"flv", @"vob"];
        if ([fileTypeArr containsObject:exestr]) {
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[[NSString alloc] initWithFormat:@"%@/%@",ducumentsDirectory,testPath] error:nil];
            fileModel.fileSize=[[fileAttributes objectForKey:@"NSFileSize"] longValue]/1000000;
            NSDate *modificationDate=[fileAttributes objectForKey:@"NSFileModificationDate"];
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *modificationDateString=[formatter stringFromDate:modificationDate];
            NSString *fileCreationDateString=[formatter stringFromDate:[fileAttributes objectForKey:@"NSFileCreationDate"]];
            fileModel.fileModificationDate=modificationDateString;
            fileModel.fileCreationDate=fileCreationDateString;
            fileModel.path=videoPath;
            fileModel.name=testPath;
            NSArray *range=[testPath componentsSeparatedByString:@"."];
            if (range.count>0) {
                fileModel.fileType=[range lastObject];
            }
            fileModel.title=fileModel.name;
            NSArray *imageDataArr = [self getVideoThumb:videoPath withIndex:i];
            fileModel.shoutCutImage = imageDataArr[0];
            fileModel.imagePath = imageDataArr[1];
            
            if (self.duartionArray.count>0) {
                fileModel.duartionStr = self.duartionArray[i];
            }else{
                fileModel.duartionStr = ((FileModel *)self.historyArchiveArray[i]).duartionStr;
            }
            if (i+1 <= self.historyArchiveArray.count) {
                fileModel.videoLevel = ((FileModel *)self.historyArchiveArray[i]).videoLevel;
            }
            
            NSString *localLevel = [self.ud objectForKey:@"levelKey"];
            
            if ([self.ud boolForKey:@"levelOpenKey"]) {
                if (fileModel.videoLevel==nil || fileModel.videoLevel.integerValue<=localLevel.integerValue) {
                    fileModel.isHide = @"0";
                }else{
                    fileModel.isHide = @"1";
                }
            }else {
                fileModel.isHide = @"0";
            }
            [videoArrays addObject:fileModel];
        }
    }
    
    if (!(videoArrays.count<1)) {
        [self.historyArchive saveArr:videoArrays withType:TypeLocal];
    }
    
    return videoArrays;
}

- (NSArray *)getLocalFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ducumentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:ducumentsDirectory error:NULL];
    return contents;
}

- (BOOL)removeLocalFile:(NSString *)localFile withImagePath:(NSString *)imagePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res=[fileManager removeItemAtPath:localFile error:nil];
    BOOL imageres=[fileManager removeItemAtPath:imagePath error:nil];
    if (res && imageres) {
        NSLog(@"delete file success");
    }else
        NSLog(@"delete file failure");
    NSLog(@"Is file exist ? : %@",[fileManager isExecutableFileAtPath:localFile]?@"YES":@"NO");
    return ![fileManager isExecutableFileAtPath:localFile];
}

-(NSArray *)getVideoThumb:(NSString *)videoURL withIndex:(NSInteger)index
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //获得视频文件夹
    NSString *folderPath = [path stringByAppendingPathComponent:@"thumbs"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
        NSLog(@"thumbs is exists.");
    }
    NSString *imagePath = [folderPath stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",[[videoURL lastPathComponent] stringByDeletingPathExtension]]];
    
    
    BOOL existed = [fileManager fileExistsAtPath:imagePath];
    if (!existed) {
        KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
        [decoder openFile:videoURL error:nil];

        NSString *duartionStr = [self TimeformatFromSeconds:decoder.duration];
        [self.duartionArray addObject:duartionStr];
        
        NSArray *ar =  [decoder decodeFrames:1.0f];
        KxMovieFrame *frame;
        
        for (KxMovieFrame *frames in ar)
        {
            if (frames.type == KxMovieFrameTypeVideo) {
                frame =  ar.lastObject;
                break;
            }
        }
        
        KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
        UIImage *imageKX = [rgbFrame asImage];
        [decoder closeFile];
        
        NSData *imageData = UIImageJPEGRepresentation(imageKX, 0.2f);
        [imageData writeToFile:imagePath atomically:NO];
        return @[imageKX,imagePath];
    }else {
        
        UIImage *imageKX = [UIImage imageWithContentsOfFile:imagePath];
        return @[imageKX,imagePath];
    }    
}

-(NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02d",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

@end
