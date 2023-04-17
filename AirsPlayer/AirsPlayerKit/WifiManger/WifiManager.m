
//
//  WifiManager.m
//  Eleven
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "WifiManager.h"

@interface WifiManager ()
@end

@implementation WifiManager
@synthesize httpServer;

+ (instancetype)sharedInstance
{
    static WifiManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[WifiManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        httpServer = [[HTTPServer alloc] init];
        [httpServer setType:@"_http._tcp."];
        [httpServer setPort:8080];
        [httpServer setName:@"CocoaWebResource"];
        [httpServer setupBuiltInDocroot];
    }
    return self;
}

- (void)operateServer:(BOOL)status
{
    NSError *error;
    if (status)
    {
        BOOL serverIsRunning = [httpServer start:&error];
        if(!serverIsRunning)
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    }
    else
    {
        [httpServer stop];
    }
}

- (void)dealloc
{
    httpServer.fileResourceDelegate = nil;
}

@end
