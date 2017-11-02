//
//  TabBarViewController.m
//  Oye Driver
//
//  Created by Sujan on 7/10/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "TabBarViewController.h"
#import "HexColors.h"
#import "AppDelegate.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self.tabBar setTintColor:[UIColor hx_colorWithHexString:@"#ffffff"]];
    [self.tabBar setBarTintColor:[UIColor hx_colorWithHexString:@"#323B61"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logOutFromTabbar
{
    
   
    AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
    
    UIViewController* rootController = [self.storyboard  instantiateViewControllerWithIdentifier:@"LandingViewController"];
    
    UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:rootController];
    
    navigation.navigationBarHidden=YES;
    appDelegateTemp.window.rootViewController = navigation;
    
   
}

@end
