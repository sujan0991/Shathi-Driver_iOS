//
//  LeaderBoardViewController.h
//  Shathi
//
//  Created by Sujan on 9/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface LeaderBoardViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageManagerDelegate>



@property (weak, nonatomic) IBOutlet UITableView *leaderBoardTableView;
@property (weak, nonatomic) IBOutlet UILabel *earningLabel;
@property (weak, nonatomic) IBOutlet UIButton *topEarnersButton;
@property (weak, nonatomic) IBOutlet UIButton *topRidesButton;




@end
