//
//  ADManager.h
//  AirsPlayer
//
//  Created by 洪尘 on 2016/9/30.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADManager : NSObject

+ (instancetype)sharedInstance;

- (void)showADBannerInViewController:(UIViewController *)rootVC;

@end
