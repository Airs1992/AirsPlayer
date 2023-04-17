//
//  LocalFileViewController.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/9.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "LocalFileViewController.h"
#import "BaseNavigationController.h"
#import "LocalFileViewModel.h"
#import "FileModel.h"
#import "HistoryArchive.h"

#import "KxMovieViewController.h"
#import "YiRefreshHeader.h"
#import "WifiViewController.h"
#import "WifiManager.h"
#import "NSMutableArray+SWUtilityButtons.h"
#import "SWTableViewCell.h"

#import "i2KEPCSingleComponentPickerView.h"
#import "i2KEPCMultiComponentPickerView.h"
#import <ReactiveCocoa.h>
#import "i2KEPCDatePickerView.h"

#import "LevelManger.h"
#import "ADManager.h"

//@import GoogleMobileAds;

@interface LocalFileViewController ()<UITableViewDataSource,UITableViewDelegate,WebFileResourceDelegate,SWTableViewCellDelegate,UIPickerViewDataSource, UIPickerViewDelegate>

@property(nonatomic, strong) NSUserDefaults *ud;
@property(nonatomic, strong) UITableView *mainTableView;
@property(nonatomic, strong) LocalFileViewModel *localFileViewModel;
@property(nonatomic, strong) NSMutableArray *localFileArray;
@property(nonatomic, strong) NSMutableArray *displayArray;
@property (nonatomic, strong) HistoryArchive *historyArchive;

@property(nonatomic, strong) YiRefreshHeader *refreshHeader;
@property(nonatomic, strong) NSMutableArray *fileList;
@property(nonatomic, strong) KxMovieViewController *moviePlayerVC;

@property (nonatomic, weak) i2KEPCSingleComponentPickerView *singleComponentPicker;
@property (nonatomic, assign) NSInteger selectedIndexSingleDelegated;
@property (nonatomic, strong) NSString *selectedValueSingleDelegated;
@property (nonatomic, strong) NSArray *singleComponentPickerValues;

//@property (nonatomic, strong) GADBannerView  *bannerView;

@end

@implementation LocalFileViewController

-(NSUserDefaults *)ud
{
    if (_ud == nil) {
        _ud = [NSUserDefaults standardUserDefaults];
    }
    return _ud;
}

-(NSMutableArray *)displayArray
{
    __weak __typeof(self) weakSelf = self;
    
    if (_displayArray == nil) {
        _displayArray = [[NSMutableArray alloc]init];
        [self.localFileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileModel *oneinfo = obj;
            if (oneinfo.isHide.boolValue == 0) {
                [weakSelf.displayArray addObject:oneinfo];
            }
        }];
    }
    return _displayArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.bannerView = [[GADBannerView alloc]initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(50) origin:CGPointMake(0, self.view.bounds.size.height-50)];
//    self.bannerView.backgroundColor = [UIColor blackColor];
//
//    self.bannerView.adUnitID = @"ca-app-pub-9588340612079411/9977311083";
//    self.bannerView.rootViewController = self;
//    [self.bannerView loadRequest:[GADRequest request]];
//    [self.view addSubview:self.bannerView];
    
    self.localFileViewModel=[[LocalFileViewModel alloc] init];
    self.historyArchive=[[HistoryArchive alloc] init];
    
    self.localFileArray=[NSMutableArray array];
    self.singleComponentPickerValues = @[@"level0",@"level1", @"level2", @"level3", @"level4", @"level5", @"level6", @"level7", @"level8", @"level9"];
    self.localFileArray=(NSMutableArray *)[self.localFileViewModel getLocalVideoFiles];
    
    self.title = NSLocalizedString(@"Local File", nil);
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(BaseNavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    self.mainTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight-64-50) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTableView];
    
    self.mainTableView.dataSource=self;
    self.mainTableView.delegate=self;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"WiFi" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarAction)];
    
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
    titleLabel.backgroundColor = [UIColor blackColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.numberOfLines=0;
    titleLabel.font=[UIFont systemFontOfSize:13];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.text=NSLocalizedString(@"You can transfer video files via itunes or wifi\nSupport m4v, wmv, 3gp, mp4, mov, avi, mkv, mpeg, mpg, flv, vob format", nil);
    //来自kxmovie项目的MainViewController类
    
    self.mainTableView.tableHeaderView=titleLabel;
    [self addHeader];
    
    self.fileList = [[NSMutableArray alloc] init];
    [self loadFileList];
    [WifiManager sharedInstance].httpServer.fileResourceDelegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ADManager sharedInstance]showADBannerInViewController:self];
    self.moviePlayerVC = nil;
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
    self.localFileArray=(NSMutableArray *)[self.localFileViewModel getLocalVideoFiles];
    [self.mainTableView reloadData];
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
    self.localFileArray=(NSMutableArray *)[self.localFileViewModel getLocalVideoFiles];
    [self.mainTableView reloadData];
}

#pragma mark - Actions

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

- (void)rightBarAction
{
    WifiViewController *viewController=[[WifiViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private

- (void)addHeader{
    
    self.refreshHeader=[[YiRefreshHeader alloc] init];
    self.refreshHeader.scrollView = self.mainTableView;
    [self.refreshHeader header];
    __weak typeof(self.mainTableView) weakTableView = self.mainTableView;
    __weak typeof(self.refreshHeader) weakRefreshHeader = self.refreshHeader;
    
    WEAKSELF;
    
    self.refreshHeader.beginRefreshingBlock=^(){
        __strong typeof(self.mainTableView) strongTableView = weakTableView;
        __strong typeof(self.refreshHeader) strongRefreshHeader = weakRefreshHeader;
        
        weakSelf.localFileArray=(NSMutableArray *)[weakSelf.localFileViewModel getLocalVideoFiles];
        [strongTableView reloadData];
        [strongRefreshHeader endRefreshing];
    };
}

#pragma mark - UITableViewDataSource  &UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    self.displayArray = nil;
    return self.displayArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 15)];
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SWTableViewCell *cell;
    NSString *cellId=@"CellId1";
    FileModel *file=self.displayArray[indexPath.row];
    cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell==nil) {
//        cell=(SWTableViewCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.delegate = self;
    }
    cell.rightUtilityButtons = [self rightButtons];
    if ([self.ud boolForKey:@"levelOpenKey"]) {
        cell.leftUtilityButtons = [self leftButtonsWithLevel:file.videoLevel];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text=file.name;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%ld MB    %@    %@",file.fileSize,file.duartionStr,file.fileCreationDate];
    cell.imageView.image = file.shoutCutImage;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileModel *file=self.displayArray[indexPath.row];
    NSString *path =file.path;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // increase buffering for .wmv, it solves problem with delaying audio frames
    if ([path.pathExtension isEqualToString:@"wmv"])
        parameters[KxMovieParameterMinBufferedDuration] = @(5.0);
    // disable deinterlacing for iPhone, because it's complex operation can cause stuttering
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KxMovieParameterDisableDeinterlacing] = @(YES);
    
    // disable buffering
//    parameters[KxMovieParameterMinBufferedDuration] = @(5.0f);
//    parameters[KxMovieParameterMaxBufferedDuration] = @(5.0f);
    
    self.moviePlayerVC = [KxMovieViewController movieViewControllerWithContentPath:path parameters:parameters];
    
    [self presentViewController:self.moviePlayerVC animated:YES completion:nil];
    //[self.navigationController pushViewController:vc animated:YES];
    //    LoggerApp(1, @"Playing a movie: %@", path);
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

#pragma mark - Tool Methods
/**
 *  当tableview中 数据源数量很少不足以填满当前区域  比如只有1一个数据  那么它将隐藏 空cell的分割线
 */
- (void)setExtraCellLineHidden{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.mainTableView setTableFooterView:view];
    [self.mainTableView setTableHeaderView:view];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    if ([self.ud boolForKey:@"levelOpenKey"]) {
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                    title:@"Level"];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                    title:@"Delete"];
    }else{
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                    title:@"Delete"];
    }
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtonsWithLevel:(NSString *)levelStr
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    if (levelStr==nil) {
        levelStr = @"Level0";
    }else{
        levelStr = [NSString stringWithFormat:@"Level%@",levelStr];
    }
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:60.0/255.0 green:195.0/255.0 blue:215.0/255.0 alpha:1]
                                                title:levelStr];
    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    if ([self.ud boolForKey:@"levelOpenKey"]) {
        switch (index) {
            case 0:
            {
                NSLog(@"Level button was pressed");
                
                [LevelManger sharedInstance].successBlock = ^(){
                    NSIndexPath *cellIndexPath = [self.mainTableView indexPathForCell:cell];
                    
                    __block FileModel *file=self.localFileArray[cellIndexPath.row];
                    
                    i2KEPCSingleComponentPickerView *singlePickerWithDelegate =
                    [[i2KEPCSingleComponentPickerView alloc] initWithTitle:@"Level limit" dataSource:self delegate:self];
                    
                    self.singleComponentPicker = singlePickerWithDelegate;
                    [singlePickerWithDelegate showPicker];
                    [singlePickerWithDelegate.valuePicker selectRow:self.selectedIndexSingleDelegated
                                                        inComponent:0
                                                           animated:NO];
                    
                    [[singlePickerWithDelegate valueSignal] subscribeNext:^(RACTuple *x) {
                        NSInteger row = [x.first integerValue];
                        file.videoLevel = [NSString stringWithFormat:@"%ld",(long)row];
                        [self.historyArchive saveArr:self.localFileArray withType:TypeLocal];
                        self.selectedValueSingleDelegated = self.singleComponentPickerValues[row];
                        self.selectedIndexSingleDelegated = row;
                        [self.refreshHeader beginRefreshing];
                    }];
                };
                
                [LevelManger sharedInstance].faultBlock = ^(){
                    [self presentViewController:[[LevelManger sharedInstance]showFaultAlert] animated:YES completion:nil];
                };
                
                [LevelManger sharedInstance].cancelBlock = ^(){
                };
                
                [self presentViewController:[[LevelManger sharedInstance]showSecureTextEntryOnlyOneLevelChangeAlert] animated:YES completion:nil];

                
                //////////////////////////////////////////////////
            }
                break;
            case 1:
            {
                // Delete button was pressed
                NSIndexPath *cellIndexPath = [self.mainTableView indexPathForCell:cell];
                
                FileModel *file=self.localFileArray[cellIndexPath.row];
                if ([self.localFileViewModel removeLocalFile:file.path withImagePath:file.imagePath]) {
                    //删除数组里的数据    删除对应数据的cell
                    NSMutableArray *arr=self.localFileArray;
                    [arr removeObjectAtIndex:cellIndexPath.row];
                    [self.mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.refreshHeader beginRefreshing];
                }
                break;
            }
            default:
                break;
        }
    }else{
        switch (index) {
            case 0:
            {
                // Delete button was pressed
                NSIndexPath *cellIndexPath = [self.mainTableView indexPathForCell:cell];
                
                FileModel *file=self.localFileArray[cellIndexPath.row];
                if ([self.localFileViewModel removeLocalFile:file.path withImagePath:file.imagePath]) {
                    //删除数组里的数据    删除对应数据的cell
                    NSMutableArray *arr=self.localFileArray;
                    [arr removeObjectAtIndex:cellIndexPath.row];
                    [self.mainTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.refreshHeader beginRefreshing];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [WifiManager sharedInstance].httpServer.fileResourceDelegate = nil;
}

@end
