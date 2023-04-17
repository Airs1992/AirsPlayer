//
//  HistoryArchive.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "HistoryArchive.h"

static NSString * const kHistoryArchiveKey = @"historyArchive";

@implementation HistoryArchive

- (NSString *)cacheDirWithType:(VideoArrType)type
{
    switch (type) {
        case TypeLocal:{
            NSString *addressPath=[NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject],@"cache0"];
            return addressPath;
        }
            break;
        case TypeNetwork:{
            NSString *addressPath=[NSString stringWithFormat:@"%@/%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject],@"cache1"];
            return addressPath;
        }
            break;
        default:
            break;
    }
}

//保存数组与归档
- (void)saveArr:(NSArray *)array withType:(VideoArrType)type
{
    //归档
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:array forKey:kHistoryArchiveKey]; // archivingData的encodeWithCoder
    [archiver finishEncoding];
    //写入文件
    [data writeToFile:[self cacheDirWithType:type] atomically:YES];
}

//解档得到数组
- (NSArray *)loadArchivesWithType:(VideoArrType)type{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:[self cacheDirWithType:type]];
    if (existed) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self cacheDirWithType:type]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        //获得数组
        NSArray *archivingData = [unarchiver decodeObjectForKey:kHistoryArchiveKey];// initWithCoder方法被调用
        [unarchiver finishDecoding];
        return archivingData;
    }else{
        NSArray *archivingData=[NSMutableArray arrayWithCapacity:1];
        return archivingData;
    }
}

@end
