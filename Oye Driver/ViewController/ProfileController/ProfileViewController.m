//
//  ProfileViewController.m
//  Oye Driver
//
//  Created by Sujan on 7/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "ProfileViewController.h"
#import <AccountKit/AccountKit.h>
#import "LandingViewController.h"
#import "UserAccount.h"
#import "ServerManager.h"
#import "NSDictionary+NullReplacement.h"
#import "Constants.h"
#import "RideHistoryViewController.h"
#import "SettingViewController.h"
#import "EditPrifileViewController.h"

@interface ProfileViewController (){
    
    AKFAccountKit *accountKit;
    
    NSArray *settingList;
    NSArray *imageArray;
    
    NSMutableDictionary *userInfo;

}


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    if (accountKit == nil) {
        accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    }
    [self setUpView];
    [self drawShadow:self.navView];
    
    [self getUserInfo];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    NSLog(@"[UserAccount sharedManager].isOnRide in profile  %d",[UserAccount sharedManager].isOnRide);
    
    if ([UserAccount sharedManager].isOnRide == 1) {
        
        self.driverStatusSwitch.userInteractionEnabled = NO;
        
    }else{
    
        self.driverStatusSwitch.userInteractionEnabled = YES;
    }
    
}

-(void) setUpView{
    
    
    
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 5.0f;
    self.profilePicture.layer.borderColor = [[UIColor whiteColor]CGColor];
    
    self.editProfileButton.layer.cornerRadius = self.editProfileButton.frame.size.width / 2;
    
    
    self.settingTableView.delegate = self;
    self.settingTableView.dataSource = self;
    
    
    settingList = [[NSArray alloc] initWithObjects:@"Support",@"History",@"Settings",@"About", nil];
    
    //UIImage *image1 = [UIImage imageNamed:@"gift_icon"];
    UIImage *image2 = [UIImage imageNamed:@"Support"];
    UIImage *image3 = [UIImage imageNamed:@"History"];
    UIImage *image4 = [UIImage imageNamed:@"Settings_black"];
    UIImage *image5 = [UIImage imageNamed:@"about"];
    
    
    imageArray = [[NSArray alloc] initWithObjects:image2,image3,image4,image5, nil];
    
    NSLog(@"status  in profile %d",[UserAccount sharedManager].riderStatus);
    
    if ([UserAccount sharedManager].riderStatus == 1) {
        
        [self.driverStatusSwitch setOn:NO];
        self.statusLabel.text = @"Offline";
        
    }else{
        
        [self.driverStatusSwitch setOn:YES];
        self.statusLabel.text = @"Online";
        
    }
    
    self.settingTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.settingTableView.frame.size.width, 1)];
    
   [self.driverStatusSwitch addTarget:self
                          action:@selector(stateChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    self.locationShareModel= [LocationShareModel sharedModel];
    
    
 
}

-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return settingList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"profileCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    UIImageView *settingIcon = (UIImageView*) [cell viewWithTag:1];
    
    settingIcon.image=[imageArray objectAtIndex:indexPath.row];
    
    
    UILabel *settingOption= (UILabel*) [cell viewWithTag:2];
    
    
    settingOption.text =[NSString stringWithFormat:@"%@",[settingList objectAtIndex:indexPath.row]];
    
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0)
    {
        
        
    }else if (indexPath.row ==1)
    {
        RideHistoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RideHistoryViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (indexPath.row ==2)
    {
        SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
}

-(void) getUserInfo{
    
    
    [[ServerManager sharedManager] getRiderInfoWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"user info %@",userInfo);
            
            [self.profilePicture sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_API_URL,[userInfo objectForKey:@"profile_picture"]]]];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"name"]];
            self.phoneNoLabel.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"phone"]];
           
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
    
    
}

- (void)stateChanged:(UISwitch *)switchState
{
    self.locationTracker = [[LocationTracker alloc]init];
    
    if ([switchState isOn]) {

        NSLog(@"ON");
        self.statusLabel.text = @"Online";
        
        [[ServerManager sharedManager] patchRiderStatus:@"2" withCompletion:^(BOOL success) {
            
            if (success) {
                
                NSLog(@"success");
                
                //self.locationTracker.isStopUpdateLocation = 0;
                
                [UserAccount sharedManager].riderStatus = 2;
                
                //invalidate the timer
                if (self.locationShareModel.timer) {
                    
                    [self.locationShareModel.timer invalidate];
                    self.locationShareModel.timer = nil;
                    NSLog(@"self.shareModel.timer in state on  = nil");
                }
                
                //invalidate locaton uptade timer
                
                if (self.locationUpdateTimer) {
                    
                    [self.locationUpdateTimer invalidate];
                    self.locationUpdateTimer = nil;
                    NSLog(@"self.locationUpdateTimer in state on  = nil");
                }
                
                
                
                NSLog(@"self.locationTracker in state change ");
                
                [self.locationTracker startLocationTracking];
                
                //Send the best location to server every 60 seconds
                //You may adjust the time interval depends on the need of your app.
                NSTimeInterval time = 60*5;
                self.locationUpdateTimer =
                [NSTimer scheduledTimerWithTimeInterval:time
                                                 target:self
                                               selector:@selector(updateLocation)
                                               userInfo:nil
                                                repeats:YES];
                
                
            }else{
            
              dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
              });
            }
 
        }];

    }else{
 
       NSLog(@"OFF");
        
        self.statusLabel.text = @"Offline";
        
        [[ServerManager sharedManager] patchRiderStatus:@"1" withCompletion:^(BOOL success) {
            
            if (success) {
                
                NSLog(@"success");
                
              //  self.locationTracker.isStopUpdateLocation = 1;
                [UserAccount sharedManager].riderStatus = 1;
                [self.locationTracker stopLocationTracking];
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"no user info");
                    
                    
                });
            }
            
        }];
        
    }
}

-(void)updateLocation {
    
    if ([UserAccount sharedManager].riderStatus != 1) {
        
        
        NSLog(@"status  in updateLocation %d",[UserAccount sharedManager].riderStatus);
        
        NSLog(@"updateLocation in profile");
        
        
        [self.locationTracker updateLocationToServer];
        
    }
}


- (IBAction)editProfileAction:(id)sender {
    
    
    EditPrifileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPrifileViewController"];
    
    vc.userInfo = userInfo;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)backButtonAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
