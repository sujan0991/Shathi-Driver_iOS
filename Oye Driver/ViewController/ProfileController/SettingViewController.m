//
//  SettingViewController.m
//  Oye Driver
//
//  Created by Sujan on 8/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "SettingViewController.h"
#import "VerifyIdentityViewController.h"
#import <AccountKit/AccountKit.h>
#import "UserAccount.h"
#import "ServerManager.h"
#import "TabBarViewController.h"

@interface SettingViewController (){

    AKFAccountKit *accountKit;
    
    NSArray *settingList;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (accountKit == nil) {
        accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    }
    
    self.settingTable.delegate = self;
    self.settingTable.dataSource = self;
    
    settingList = [[NSArray alloc] initWithObjects:@"Notifications",@"Language",@"Verification identity",@"Terms of service",@"Log Out", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingfCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    UILabel *settingOption= (UILabel*) [cell viewWithTag:2];
    
    
    settingOption.text =[NSString stringWithFormat:@"%@",[settingList objectAtIndex:indexPath.row]];
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        
        
    }else if (indexPath.row ==2)
    {
        VerifyIdentityViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VerifyIdentityViewController"];
        
        vc.isCrossHidden =NO;
        
        [self presentViewController:vc animated:YES completion:nil];
        
    }else if (indexPath.row == 4)
    {
        
        
        [[ServerManager sharedManager] postLogOutWithCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
            
            if (resultDataDictionary!=nil) {
                
                [accountKit logOut];
                
                [UserAccount sharedManager].accessToken= @"" ;
                [UserAccount sharedManager].riderStatus = 1;
                
                TabBarViewController *tabBar = (TabBarViewController *) self.tabBarController;
                [tabBar logOutFromTabbar];
                
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"no user info");
                    
                    
                });
                
            }
            
        }];
        
        
        
        
       // [UserAccount sharedManager].accessToken= @"" ;
        
        
        

        
    }
    
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
