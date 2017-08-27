//
//  ProfileViewController.h
//  Oye Driver
//
//  Created by Sujan on 7/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTracker.h"
#import "UIImageView+WebCache.h"

@interface ProfileViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageManagerDelegate>




@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNoLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@property (weak, nonatomic) IBOutlet UISwitch *driverStatusSwitch;

@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property LocationShareModel * locationShareModel;

@end
