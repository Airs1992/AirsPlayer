//
//  HistoryArchive.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TypeLocal,
    TypeNetwork,
} VideoArrType;

@interface HistoryArchive : NSObject


- (void)saveArr:(NSArray *)array withType:(VideoArrType)type;//保存数组与归档
- (NSArray *)loadArchivesWithType:(VideoArrType)type;//解档得到数组

@end
