//
//  LeaderBoardViewController.m
//  Shathi
//
//  Created by Sujan on 9/24/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "LeaderBoardViewController.h"
#import "HexColors.h"
#import "ServerManager.h"
#import "Constants.h"
#import "JTMaterialSpinner.h"

@interface LeaderBoardViewController ()
{
    JTMaterialSpinner *spinner;
    NSMutableArray *topRiders;
}

@end

@implementation LeaderBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.leaderBoardTableView.delegate = self;
    self.leaderBoardTableView.dataSource = self;
    
    self.topEarnersButton.selected = YES;
    
    [self topEarners];
    
      self.leaderBoardTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.leaderBoardTableView.frame.size.width, 1)];
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2 - 17, 35, 35)];
    [self.view bringSubviewToFront:spinner];
    [self.view addSubview:spinner];
    //spinner.hidden =YES;
    [spinner beginRefreshing];
    
}

- (void)viewDidUnload {
    //    [btnSelect release];
  
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)topEarnersButtonAction:(UIButton *)sender {
    
    self.topEarnersButton.selected = YES;
    self.earningLabel.text = @"Earning";
    if (sender.selected) {
        
        self.topEarnersButton.backgroundColor = [UIColor hx_colorWithHexString:@"237B4D"];
        self.topRidesButton.backgroundColor = [UIColor hx_colorWithHexString:@"262C4E"];
        
        [self topEarners];
    }
    if (self.topRidesButton.selected) {
        
        self.topRidesButton.selected = NO;
    }
        
   
    

}

- (IBAction)topRidesButtonAction:(UIButton *)sender {
    
    self.topRidesButton.selected = YES;
    self.earningLabel.text = @"Rides";
    
    if (sender.selected) {
        
        self.topRidesButton.backgroundColor = [UIColor hx_colorWithHexString:@"237B4D"];
        self.topEarnersButton.backgroundColor = [UIColor hx_colorWithHexString:@"262C4E"];
        [self topRides];
    }
    if (self.topEarnersButton.selected) {
        
        self.topEarnersButton.selected = NO;
    }
}

-(void)topEarners{
    
    spinner.hidden = NO;
    [spinner beginRefreshing];
    
    [[ServerManager sharedManager] getTopEarnersWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        
        if ( responseObject!=nil) {
            
            spinner.hidden = YES;
            [spinner endRefreshing];
            
            topRiders = [[NSMutableArray alloc]init];
            topRiders = [responseObject objectForKey:@"top_earners"];
            
            NSLog(@"top earners  %@",topRiders);
            
            [self.leaderBoardTableView reloadData];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                spinner.hidden = YES;
                [spinner endRefreshing];
                
            });
            
        }
    }];
    
}

-(void)topRides{
    
    spinner.hidden = NO;
    [spinner beginRefreshing];
    
    [[ServerManager sharedManager] getTopRidesWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            spinner.hidden = YES;
            [spinner endRefreshing];
            
            topRiders = [[NSMutableArray alloc]init];
            topRiders = [responseObject objectForKey:@"top_rides"];
            
            NSLog(@"top rides  %@",topRiders);
            
            [self.leaderBoardTableView reloadData];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                spinner.hidden = YES;
                [spinner endRefreshing];
                
                
            });
            
        }
    }];
}


#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return topRiders.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"leaderBoardCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell  = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    
    UIImageView *riderImage = (UIImageView*) [cell viewWithTag:1];
    
    riderImage.layer.cornerRadius = riderImage.frame.size.width / 2;
    riderImage.clipsToBounds = YES;
    [riderImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_API_URL,[[[topRiders objectAtIndex:indexPath.row] objectForKey:@"rider"]objectForKey:@"profile_picture"]]]];
    
    UILabel *nameLabel= (UILabel*) [cell viewWithTag:2];
    nameLabel.text = [[[topRiders objectAtIndex:indexPath.row] objectForKey:@"rider"]objectForKey:@"name"];
    
    NSLog(@"riders name %@",[[[topRiders objectAtIndex:indexPath.row] objectForKey:@"rider"]objectForKey:@"name"]);
    
    UILabel *earningLabel= (UILabel*) [cell viewWithTag:3];
    
    if (self.topEarnersButton.selected) {
        
        earningLabel.text =[NSString stringWithFormat:@"%@",[[topRiders objectAtIndex:indexPath.row] objectForKey:@"totalEarning"]];
        
    }else if (self.topRidesButton.selected){
        
        earningLabel.text =[NSString stringWithFormat:@"%@",[[topRiders objectAtIndex:indexPath.row] objectForKey:@"totalRide"]];

    }
    
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    
}

@end
