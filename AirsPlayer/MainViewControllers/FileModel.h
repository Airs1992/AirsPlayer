//
//  FileModel.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/11.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileModel : NSObject<NSCopying,NSCoding>

@property(nonatomic,assign) long fileSize;
@property(nonatomic,copy) NSString *fileModificationDate;
@property(nonatomic,copy) NSString *fileCreationDate;
@property(nonatomic,copy) NSString *path;
@property(nonatomic,copy) NSString *imagePath;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *fileType;
@property(nonatomic,copy) UIImage *shoutCutImage;
@property(nonatomic,copy) NSString *duartionStr;
@property(nonatomic,copy) NSString *videoLevel;
@property(nonatomic,copy) NSString *isHide;
@end
