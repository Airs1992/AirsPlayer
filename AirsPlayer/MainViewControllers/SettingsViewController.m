//
//  SettingsViewController.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/16.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "SettingsViewController.h"
#import "BaseNavigationController.h"
#import "LevelManger.h"

#import "i2KEPCSingleComponentPickerView.h"
#import "i2KEPCMultiComponentPickerView.h"
#import <ReactiveCocoa.h>
#import "i2KEPCDatePickerView.h"
#import "ADManager.h"

@interface SettingsViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) NSUserDefaults *ud;
@property (nonatomic, weak) i2KEPCSingleComponentPickerView *singleComponentPicker;
@property (nonatomic, assign) NSInteger selectedIndexSingleDelegated;
@property (nonatomic, strong) NSString *selectedValueSingleDelegated;
@property (nonatomic, strong) NSArray *singleComponentPickerValues;
@property (nonatomic, strong) UIBarButtonItem *levelBtn;

@end

@implementation SettingsViewController

static NSString * const levelKey = @"levelKey";

-(NSUserDefaults *)ud
{
    if (_ud == nil) {
        _ud = [NSUserDefaults standardUserDefaults];
    }
    return _ud;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = @"Level Setting";
    
    self.singleComponentPickerValues = @[@"level0",@"level1", @"level2", @"level3", @"level4", @"level5", @"level6", @"level7", @"level8", @"level9"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(BaseNavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    NSString *levelStr = [self.ud objectForKey:levelKey];
    if (levelStr == nil) {
        levelStr = @"Level0";
    }else {
        levelStr = [NSString stringWithFormat:@"Level%@",[self.ud objectForKey:levelKey]];
    }
    self.levelBtn = [[UIBarButtonItem alloc] initWithTitle:levelStr
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(showLevelSelect)];
    NSString *passwordStr = [self.ud objectForKey:@"PasswordKey"];
    if (passwordStr != nil) {
        self.navigationItem.rightBarButtonItem = self.levelBtn;
    }
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 50)];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.numberOfLines=0;
    titleLabel.font=[UIFont systemFontOfSize:13];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text=NSLocalizedString(@"Open button, and then set your Audition level and password, The list displays only the files below that level \nDo not forget you password", nil);
    titleLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UISwitch *serviceSwitch=[[UISwitch alloc] initWithFrame:CGRectMake((ScreenWidth-60)/2, ScreenHeight/2, 60, 40)];
    serviceSwitch.onTintColor = [UIColor yellowColor];
    
    BOOL switchStatus = [LevelManger sharedInstance].levelOpenStatus;
    
    if (switchStatus) {
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:195.0/255.0 blue:215.0/255.0 alpha:1];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }else {
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }
    
    [serviceSwitch setOn:switchStatus animated:NO];
    
    [serviceSwitch addTarget:self action:@selector(toggleLevel:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:serviceSwitch];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ADManager sharedInstance]showADBannerInViewController:self];
}

-(void)toggleLevel:(id)sender
{
    if ([(UISwitch*)sender isOn])
    {
//        [[LevelManger sharedInstance] operateLevel:YES];
//        [LevelManger sharedInstance].levelOpenStatus=YES;
        
        [LevelManger sharedInstance].successBlock = ^(){
            if ([LevelManger sharedInstance].levelOpenStatus) {
                self.navigationItem.rightBarButtonItem = self.levelBtn;
                [UIView animateWithDuration:0.2f animations:^{
                    //动画
                    self.view.backgroundColor = [UIColor colorWithRed:60.0/255.0 green:195.0/255.0 blue:215.0/255.0 alpha:1];
                } completion:^(BOOL finished) {
                    //动画结束
                }];
            }
            [self presentViewController:[[LevelManger sharedInstance]showSuccessAlert] animated:YES completion:nil];
        };
        
        [LevelManger sharedInstance].faultBlock = ^(){
            [(UISwitch*)sender setOn:NO];
            [self presentViewController:[[LevelManger sharedInstance]showFaultAlert] animated:YES completion:nil];
        };
        
        [LevelManger sharedInstance].cancelBlock = ^(){
            [(UISwitch*)sender setOn:NO];
        };

        [self presentViewController:[[LevelManger sharedInstance]showSecureTextEntryAlert] animated:YES completion:nil];        
    }
    else
    {
//        [[LevelManger sharedInstance] operateLevel:NO];
//        [LevelManger sharedInstance].levelOpenStatus=NO;
        
        [LevelManger sharedInstance].successBlock = ^(){
            self.navigationItem.rightBarButtonItem = nil;
            if (![LevelManger sharedInstance].levelOpenStatus) {
                [UIView animateWithDuration:0.2f animations:^{
                    //动画
                    self.view.backgroundColor = [UIColor whiteColor];
                } completion:^(BOOL finished) {
                    //动画结束
                }];
            }
        };
        
        [LevelManger sharedInstance].faultBlock = ^(){
            [(UISwitch*)sender setOn:YES];
            [self presentViewController:[[LevelManger sharedInstance]showFaultAlert] animated:YES completion:nil];
        };
        
        [LevelManger sharedInstance].cancelBlock = ^(){
            [(UISwitch*)sender setOn:YES];
        };
        
        [self presentViewController:[[LevelManger sharedInstance]showSecureTextEntryOnlyOneAlert] animated:YES completion:nil];
        
    }
}

- (void)showLevelSelect
{
    [LevelManger sharedInstance].successBlock = ^(){
        i2KEPCSingleComponentPickerView *singlePickerWithDelegate =
        [[i2KEPCSingleComponentPickerView alloc] initWithTitle:@"Level limit" dataSource:self delegate:self];
        
        self.singleComponentPicker = singlePickerWithDelegate;
        [singlePickerWithDelegate showPicker];
        [singlePickerWithDelegate.valuePicker selectRow:self.selectedIndexSingleDelegated
                                            inComponent:0
                                               animated:NO];
        
        [[singlePickerWithDelegate valueSignal] subscribeNext:^(RACTuple *x) {
            NSInteger row = [x.first integerValue];
            self.selectedValueSingleDelegated = self.singleComponentPickerValues[row];
            self.selectedIndexSingleDelegated = row;
            self.levelBtn.title = [NSString stringWithFormat:@"Level%ld",(long)row];
            [self.ud setObject:[NSString stringWithFormat:@"%ld",(long)row] forKey:levelKey];
        }];
    };
    
    [LevelManger sharedInstance].faultBlock = ^(){
        [self presentViewController:[[LevelManger sharedInstance]showFaultAlert] animated:YES completion:nil];
    };
    
    [LevelManger sharedInstance].cancelBlock = ^(){
    };
    
    [self presentViewController:[[LevelManger sharedInstance]showSecureTextEntryOnlyOneLevelChangeAlert] animated:YES completion:nil];
}

#pragma mark - UIPickerViewDataSource Implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.singleComponentPicker.valuePicker) {
        return [self.singleComponentPickerValues count];
    }
    return 0;
}

#pragma mark UIPickerViewDelegate Implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.singleComponentPicker.valuePicker) {
        return self.singleComponentPickerValues[row];
    }
    return @"----------";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
