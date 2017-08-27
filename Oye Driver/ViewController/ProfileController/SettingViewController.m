//
//  SettingViewController.m
//  Oye Driver
//
//  Created by Sujan on 8/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController (){


    NSArray *settingList;
}

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
//        RideHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RideHistoryViewController"];
//        
//        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row ==4)
    {
        
//        [accountKit logOut];
//        
//        
//        [UserAccount sharedManager].accessToken= @"" ;
//        
//        [self.navigationController popToRootViewControllerAnimated:YES];
        
        //        LandingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LandingViewController"];
        //
        //        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end