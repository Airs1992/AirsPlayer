//
//  NetworkViewController.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/14.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "NetworkViewController.h"
#import "BaseNavigationController.h"
#import "KxMovieViewController.h"
#import "HistoryArchive.h"
#import "ADManager.h"

@interface NetworkViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *historyArchiveArray;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) HistoryArchive *historyArchive;


@end

@implementation NetworkViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title=NSLocalizedString(@"Network Video", nil);
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(BaseNavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    self.mainTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-114) style:UITableViewStyleGrouped];
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.dataSource=self;
    self.mainTableView.delegate=self;
    self.mainTableView.rowHeight=40;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"clear", nil) style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction)];
    
    self.historyArchiveArray=[NSMutableArray arrayWithCapacity:1];
    self.historyArchive=[[HistoryArchive alloc] init];
    self.historyArchiveArray=(NSMutableArray *)[self.historyArchive loadArchivesWithType:TypeNetwork];
    if (self.historyArchiveArray.count<1) {
        self.historyArchiveArray=[NSMutableArray arrayWithCapacity:1];
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

#pragma mark - Actions

- (void)rightBarAction
{
    [self.historyArchiveArray removeAllObjects];
    [self.historyArchive saveArr:nil withType:TypeNetwork];
    [self.mainTableView reloadData];
}

- (void)textAction:(UITextField *)tempTextField
{
    if ([tempTextField isFirstResponder]) {
        [tempTextField resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)tempTextField
{
    [tempTextField resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收
    return YES;
}

#pragma mark - UITableViewDataSource  &UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    
    if (section==0) {
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
        label.textColor=[UIColor whiteColor];
        label.backgroundColor=[UIColor blackColor];
        label.font=[UIFont systemFontOfSize:13];
        label.textAlignment=NSTextAlignmentCenter;
        label.text=NSLocalizedString(@"Enter any HTTP, RTSP, RTMP, RTP address play network streaming or live", nil);
        //       来自wikipedia和https://www.vitamio.org/docs/Basic/2013/0429/3.html
        label.numberOfLines=0;
        [view addSubview:label];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 50;
    }else{
        return 5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }
    if (section==1) {
        return self.historyArchiveArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        UITableViewCell *cell;
        NSString *cellId=@"CellId1";
        cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
            if (indexPath.row==0){
                cell.contentView.backgroundColor = YiGray;
                self.textField=[[UITextField alloc] initWithFrame:CGRectMake(10, 0, ScreenWidth, 40)];
                [cell.contentView addSubview:self.textField];
                self.textField.backgroundColor=[UIColor clearColor];
                self.textField.font=[UIFont systemFontOfSize:13];
                self.textField.placeholder = @"Please enter you link...";
                self.textField.delegate=self;
                [self.textField addTarget:self action:@selector(textAction:) forControlEvents:UIControlEventTouchUpInside];
            }else if (indexPath.row==1) {
                cell.contentView.backgroundColor = [UIColor colorWithRed:22.0/255.0 green:205.0/255.0 blue:25.0/255.0 alpha:1];
                UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
                [cell.contentView addSubview:label];
                label.font=[UIFont italicSystemFontOfSize:15];
                label.backgroundColor=[UIColor clearColor];
                label.textColor = [UIColor whiteColor];
                label.text=NSLocalizedString(@"<Click to play>", nil);
                label.textAlignment=NSTextAlignmentCenter;
            }
        }
        return cell;
    }else if (indexPath.section==1) {
        UITableViewCell *cell;
        NSString *cellId=@"CellId1";
        cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        }
        cell.textLabel.font=[UIFont systemFontOfSize:13];
        cell.textLabel.text=self.historyArchiveArray[indexPath.row];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path;
    //    path =@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
    if (indexPath.section==0) {
        if (indexPath.row==1) {
            if (self.textField.text.length>0) {
                [self.historyArchiveArray addObject:self.textField.text];
                [self.historyArchive saveArr:self.historyArchiveArray withType:TypeNetwork];
                path=self.textField.text;
                [self.mainTableView reloadData];
            }
        }
    }else if (indexPath.section==1){
        path=self.historyArchiveArray[indexPath.row];
    }
    if (path.length<1 || !path) {
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    // disable buffering
    //parameters[KxMovieParameterMinBufferedDuration] = @(0.0f);
    //parameters[KxMovieParameterMaxBufferedDuration] = @(0.0f);
    
    KxMovieViewController *vc = [KxMovieViewController movieViewControllerWithContentPath:path
                                                                               parameters:parameters];
    [self presentViewController:vc animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];
    //    LoggerApp(1, @"Playing a movie: %@", path);
    
}

@end
