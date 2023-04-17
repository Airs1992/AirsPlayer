//
//  WifiManager.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPServer.h"
@interface WifiManager : NSObject
@property(strong,nonatomic) HTTPServer *httpServer;
@property(assign,nonatomic) BOOL serverStatus;
+ (instancetype)sharedInstance;
- (void)operateServer:(BOOL)status;
@end
