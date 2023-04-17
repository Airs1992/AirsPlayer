//
//  WifiViewController.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/11.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "WifiViewController.h"
#import "HTTPServer.h"
#import "BaseNavigationController.h"
#import "WifiManager.h"
#import "ADManager.h"

@interface WifiViewController ()

@property(nonatomic, strong) UILabel *urlLabel;
@property(nonatomic, strong) HTTPServer *httpServer;
@property(nonatomic, strong) NSMutableArray *fileList;

@end

@implementation WifiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = NSLocalizedString(@"WiFi Transfer", @"");
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 50)];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.numberOfLines=0;
    titleLabel.font=[UIFont systemFontOfSize:13];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text=NSLocalizedString(@"Open button, and then enter the address in the browser address bar\nClose button Remember when the transfer is complete", nil);
    titleLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:titleLabel];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UISwitch *serviceSwitch=[[UISwitch alloc] initWithFrame:CGRectMake((ScreenWidth-60)/2, ScreenHeight/2, 60, 40)];
    serviceSwitch.onTintColor = [UIColor yellowColor];
    
    BOOL switchStatus = [WifiManager sharedInstance].serverStatus;
    
    [serviceSwitch setOn:switchStatus animated:NO];
    
    [serviceSwitch addTarget:self action:@selector(toggleService:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:serviceSwitch];

    self.urlLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-98, ScreenWidth, 40)];
    [self.view addSubview:self.urlLabel];
    self.urlLabel.textAlignment=NSTextAlignmentCenter;
    self.urlLabel.textColor=[UIColor whiteColor];
    
    if (switchStatus) {
        [self.urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [[WifiManager sharedInstance].httpServer hostName], [[WifiManager sharedInstance].httpServer port]]];
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:235.0/255.0 blue:150.0/255.0 alpha:1];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }else {
        [self.urlLabel setText:@""];
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }
    
    if (serviceSwitch.on) {
        [self.urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [[WifiManager sharedInstance].httpServer hostName], [[WifiManager sharedInstance].httpServer port]]];
    }else{
        [self.urlLabel setText:@""];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ADManager sharedInstance]showADBannerInViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.httpServer.fileResourceDelegate = nil;
    
}

- (void)toggleService:(id)sender
{
    NSError *error;
    if ([(UISwitch*)sender isOn])
    {
        BOOL serverIsRunning ;
        [[WifiManager sharedInstance] operateServer:YES];
        [WifiManager sharedInstance].serverStatus=YES;
        if(!serverIsRunning)
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
        [self.urlLabel setText:[NSString stringWithFormat:@"http://%@:%d", [[WifiManager sharedInstance].httpServer hostName], [[WifiManager sharedInstance].httpServer port]]];
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:235.0/255.0 blue:150.0/255.0 alpha:1];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }
    else
    {
        [[WifiManager sharedInstance] operateServer:NO];
        [WifiManager sharedInstance].serverStatus=NO;
        [self.urlLabel setText:@""];
        [UIView animateWithDuration:0.2f animations:^{
            //动画
            self.view.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            //动画结束
        }];
    }
}

// load file list
- (void)loadFileList
{
    [self.fileList removeAllObjects];
    NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
                                      enumeratorAtPath:docDir];
    NSString *pname;
    while (pname = [direnum nextObject])
    {
        [self.fileList addObject:pname];
    }
}

#pragma mark WebFileResourceDelegate
// number of the files
- (NSInteger)numberOfFiles
{
    return [self.fileList count];
}

// the file name by the index
- (NSString*)fileNameAtIndex:(NSInteger)index
{
    return [self.fileList objectAtIndex:index];
}

// provide full file path by given file name
- (NSString*)filePathForFileName:(NSString*)filename
{
    NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    return [NSString stringWithFormat:@"%@/%@", docDir, filename];
}

// handle newly uploaded file. After uploading, the file is stored in
// the temparory directory, you need to implement this method to move
// it to proper location and update the file list.
- (void)newFileDidUpload:(NSString*)name inTempPath:(NSString*)tmpPath
{
    if (name == nil || tmpPath == nil)
        return;
    NSString* docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSString *path = [NSString stringWithFormat:@"%@/%@", docDir, name];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if (![fm moveItemAtPath:tmpPath toPath:path error:&error])
    {
        NSLog(@"can not move %@ to %@ because: %@", tmpPath, path, error );
    }
    
    [self loadFileList];
    
}

// implement this method to delete requested file and update the file list
- (void)fileShouldDelete:(NSString*)fileName
{
    NSString *path = [self filePathForFileName:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    if(![fm removeItemAtPath:path error:&error])
    {
        NSLog(@"%@ can not be removed because:%@", path, error);
    }
    [self loadFileList];
}

@end
