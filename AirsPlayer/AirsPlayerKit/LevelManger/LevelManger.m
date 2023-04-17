//
//  LevelManger.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/21.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "LevelManger.h"



@interface LevelManger()

@property(nonatomic, strong)NSUserDefaults *ud;
@property (nonatomic, strong)UIAlertAction *secureTextAlertAction;
@property (nonatomic, copy)NSString *password;
@property (nonatomic, copy)NSString *againPassword;
@end

@implementation LevelManger

static NSString * const levelOpenKey = @"levelOpenKey";
static NSString * const PasswordKey = @"PasswordKey";

-(NSUserDefaults *)ud
{
    if (_ud == nil) {
        _ud = [NSUserDefaults standardUserDefaults];
    }
    return _ud;
}

+ (instancetype)sharedInstance
{
    static LevelManger *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LevelManger alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *savePassword = [self.ud objectForKey:PasswordKey];
        if (savePassword == nil) {
            self.levelOpenStatus = NO;
        }else{
            self.levelOpenStatus = [self.ud boolForKey:levelOpenKey];
        }
    }
    return self;
}

- (void)operateLevel:(BOOL)status
{
    [self.ud setBool:status forKey:levelOpenKey];
    self.levelOpenStatus = status;
}

- (UIAlertController *)showSecureTextEntryAlert {
    NSString *title = NSLocalizedString(@"Password", nil);
    NSString *message = NSLocalizedString(@"Please input you password over four Number.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field for the secure text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.secureTextEntry = YES;
        textField.placeholder = @"Over 4 number";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(againHandleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.secureTextEntry = YES;
        textField.placeholder = @"Input the password again";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];

    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's cancel action occured.");
        
        [self operateLevel:NO];
        [self cancelBlock];
        
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's other action occured.");
        
        if ([self.password isEqualToString:self.againPassword]) {
            NSLog(@"password success");
            [self.ud setObject:self.password forKey:PasswordKey];
            [self operateLevel:YES];
            self.successBlock();
        }else{
            NSLog(@"password fault");
            [self operateLevel:NO];
            self.faultBlock();
        }
        
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    // The text field initially has no text in the text field, so we'll disable it.
    otherAction.enabled = NO;
    
    // Hold onto the secure text alert action to toggle the enabled/disabled state when the text changed.
    self.secureTextAlertAction = otherAction;
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    return alertController;    
}

- (UIAlertController *)showSecureTextEntryOnlyOneAlert {
    NSString *title = NSLocalizedString(@"Password", nil);
    NSString *message = NSLocalizedString(@"Please input you password over four Number.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field for the secure text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.secureTextEntry = YES;
        textField.placeholder = @"Input your password";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's cancel action occured.");
        [self operateLevel:YES];
        [self cancelBlock];

        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's other action occured.");
        NSString *savePassword = [self.ud objectForKey:PasswordKey];
        if ([self.password isEqualToString:savePassword]) {
            [self.ud removeObjectForKey:PasswordKey];
            [self operateLevel:NO];
            self.successBlock();
        }else {
            [self operateLevel:YES];
            self.faultBlock();
        }
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    // The text field initially has no text in the text field, so we'll disable it.
    otherAction.enabled = NO;
    
    // Hold onto the secure text alert action to toggle the enabled/disabled state when the text changed.
    self.secureTextAlertAction = otherAction;
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    return alertController;
}

- (UIAlertController *)showSecureTextEntryOnlyOneLevelChangeAlert {
    NSString *title = NSLocalizedString(@"Password", nil);
    NSString *message = NSLocalizedString(@"Please input you password over four Number.", nil);
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
    NSString *otherButtonTitle = NSLocalizedString(@"OK", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // Add the text field for the secure text entry.
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // Listen for changes to the text field's text so that we can toggle the current
        // action's enabled property based on whether the user has entered a sufficiently
        // secure entry.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
        textField.secureTextEntry = YES;
        textField.placeholder = @"Input your password";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's cancel action occured.");
        [self cancelBlock];
        
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"The \"Secure Text Entry\" alert's other action occured.");
        NSString *savePassword = [self.ud objectForKey:PasswordKey];
        if ([self.password isEqualToString:savePassword]) {
            self.successBlock();
        }else {
            self.faultBlock();
        }
        // Stop listening for text changed notifications.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alertController.textFields.firstObject];
    }];
    
    // The text field initially has no text in the text field, so we'll disable it.
    otherAction.enabled = NO;
    
    // Hold onto the secure text alert action to toggle the enabled/disabled state when the text changed.
    self.secureTextAlertAction = otherAction;
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    return alertController;
}


- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    self.password = textField.text;
    self.secureTextAlertAction.enabled = textField.text.length >= 5;
}



- (void)againHandleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    
    // Enforce a minimum length of >= 5 characters for secure text alerts.
    self.againPassword = textField.text;
    self.secureTextAlertAction.enabled = textField.text.length >= 5;
}

-(UIAlertController *)showSuccessAlert {
    UIAlertController *con = [UIAlertController alertControllerWithTitle:@"Success" message:@"Already set up your password" preferredStyle:UIAlertControllerStyleAlert];
    [con addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //按钮触发的方法
    }]];
    return con;
}

-(UIAlertController *)showFaultAlert {
    UIAlertController *con = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Your passwords do not match" preferredStyle:UIAlertControllerStyleAlert];
    [con addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //按钮触发的方法
    }]];
    return con;
}

@end
