//
//  LocalFileViewModel.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/11.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFileViewModel : NSObject

- (NSArray *)getLocalVideoFiles;
- (NSArray *)getLocalFiles;
- (BOOL)removeLocalFile:(NSString *)localFile withImagePath:(NSString *)imagePath;

@end
