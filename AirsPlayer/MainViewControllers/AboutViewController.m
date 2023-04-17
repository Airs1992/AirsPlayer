//
//  AboutViewController.m
//  AirsPlayer
//
//  Created by 洪尘 on 16/9/16.
//  Copyright © 2016年 洪尘. All rights reserved.
//

#import "AboutViewController.h"
#import "BaseNavigationController.h"

#import "ADManager.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // Do any additional setup after loading the view.
    self.title = @"About";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(BaseNavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[ADManager sharedInstance]showADBannerInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
