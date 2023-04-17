//
//  ADManager.m
//  AirsPlayer
//
//  Created by 洪尘 on 2016/9/30.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "ADManager.h"

@import GoogleMobileAds;

@interface ADManager()

@property (nonatomic, strong) GADBannerView  *bannerView;

@end

@implementation ADManager

+ (instancetype)sharedInstance
{
    static ADManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ADManager alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bannerView = [[GADBannerView alloc]initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(50) origin:CGPointMake(0, [[UIScreen mainScreen] bounds].size.height-50)];
        self.bannerView.backgroundColor = [UIColor blackColor];
        self.bannerView.adUnitID = @"ca-app-pub-9588340612079411/9977311083";
    }
    return self;
}

- (void)showADBannerInViewController:(UIViewController *)rootVC
{
    self.bannerView.rootViewController = rootVC;
    [self.bannerView loadRequest:[GADRequest request]];
    [rootVC.view addSubview:self.bannerView];
}

@end
