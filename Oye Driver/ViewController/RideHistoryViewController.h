//
//  RideHistoryViewController.h
//  Oye Driver
//
//  Created by Sujan on 8/17/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface RideHistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageManagerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *navTitileLabel;

@property (weak, nonatomic) IBOutlet UITableView *historyTableView;


@property (weak, nonatomic) IBOutlet UILabel *noHistoryLabel;

@end
