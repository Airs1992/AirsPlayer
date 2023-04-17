//
//  LevelManger.h
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PassWordSetSuccess)();
typedef void (^PassWordSetFault)();
typedef void (^PassWordCancel)();

@interface LevelManger : NSObject

@property (nonatomic, copy) PassWordSetSuccess successBlock;
@property (nonatomic, copy) PassWordSetFault faultBlock;
@property (nonatomic, copy) PassWordCancel cancelBlock;

@property(assign,nonatomic) BOOL levelOpenStatus;

+ (instancetype)sharedInstance;
- (void)operateLevel:(BOOL)status;
- (UIAlertController *)showSecureTextEntryAlert;
- (UIAlertController *)showSecureTextEntryOnlyOneAlert;
- (UIAlertController *)showSecureTextEntryOnlyOneLevelChangeAlert;
- (UIAlertController *)showSuccessAlert;
- (UIAlertController *)showFaultAlert;

@end
