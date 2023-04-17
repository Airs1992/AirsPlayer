//
//  FileModel.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/11.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.fileSize = [decoder decodeIntegerForKey:@"fileSize"];
    self.fileModificationDate = [decoder decodeObjectForKey:@"fileModificationDate"];
    self.fileCreationDate = [decoder decodeObjectForKey:@"fileCreationDate"];
    self.path = [decoder decodeObjectForKey:@"path"];
    self.imagePath = [decoder decodeObjectForKey:@"imagePath"];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.title = [decoder decodeObjectForKey:@"title"];
    self.fileType = [decoder decodeObjectForKey:@"fileType"];
    self.shoutCutImage = [decoder decodeObjectForKey:@"shoutCutImage"];
    self.duartionStr = [decoder decodeObjectForKey:@"duartionStr"];
    self.videoLevel = [decoder decodeObjectForKey:@"videoLevel"];
    self.isHide = [decoder decodeObjectForKey:@"isHide"];
    

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:self.fileSize forKey:@"fileSize"];
    [encoder encodeObject:self.fileModificationDate forKey:@"fileModificationDate"];
    [encoder encodeObject:self.fileCreationDate forKey:@"fileCreationDate"];
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.imagePath forKey:@"imagePath"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.fileType forKey:@"fileType"];
    [encoder encodeObject:self.shoutCutImage forKey:@"shoutCutImage"];
    [encoder encodeObject:self.duartionStr forKey:@"duartionStr"];
    [encoder encodeObject:self.videoLevel forKey:@"videoLevel"];
    [encoder encodeObject:self.isHide forKey:@"isHide"];
}

- (id)copyWithZone:(NSZone *)zone {
    FileModel *copy = [[[self class] allocWithZone:zone] init];
    copy.fileSize = self.fileSize;
    copy.fileModificationDate = [self.fileModificationDate copyWithZone:zone];
    copy.fileCreationDate = [self.fileCreationDate copyWithZone:zone];
    copy.path = [self.path copyWithZone:zone];
    copy.imagePath = [self.imagePath copyWithZone:zone];
    copy.name = [self.name copyWithZone:zone];
    copy.title = [self.title copyWithZone:zone];
    copy.fileType = [self.fileType copyWithZone:zone];
    copy.shoutCutImage = self.shoutCutImage;
    copy.duartionStr = [self.duartionStr copyWithZone:zone];
    copy.videoLevel = [self.videoLevel copyWithZone:zone];
    copy.isHide = [self.isHide copyWithZone:zone];
    return copy;
}

@end
