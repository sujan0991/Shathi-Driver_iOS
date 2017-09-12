//
//  DashboardViewController.m
//  OyeTest
//
//  Created by Tanvir Palash on 22/8/17.
//  Copyright © 2017 Tanvir Palash. All rights reserved.
//

#import "DashboardViewController.h"
#import "ServerManager.h"
#import "UserAccount.h"
#import "NSDictionary+NullReplacement.h"

@interface DashboardViewController ()
{
    
    NSMutableDictionary *totalEarningData, *totalRideData;
}

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.commissionRateLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].commissionRate];
    self.missedCountLabel.text=[NSString stringWithFormat:@"%d",[UserAccount sharedManager].missedRide];
    self.ratingLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].rating];
    self.dueLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].due];
  
    totalEarningData=[[NSMutableDictionary alloc] init];
    totalRideData=[[NSMutableDictionary alloc] init];
    
    [self configureViewLayers];
    [self loadData];
  
    self.tripsCollectionView.delegate=self;
    self.tripsCollectionView.dataSource=self;
    
    self.earnsCollectionView.delegate=self;
    self.earnsCollectionView.dataSource=self;
    
}

-(void)configureViewLayers
{
    self.view.layer.backgroundColor=[UIColor colorWithRed:.2 green:.23 blue:.38 alpha:1.0f].CGColor;
    
    self.graphView.layer.backgroundColor=[UIColor colorWithRed:.2 green:.23 blue:.38 alpha:1.0f].CGColor;
    self.graphView.layer.shadowOffset=CGSizeZero;
    self.graphView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
    self.graphView.layer.shadowOpacity=1;
    self.graphView.layer.shadowRadius=5;
    
    self.tripsView.layer.masksToBounds=YES;
    self.tripsView.layer.cornerRadius=3.0f;
    self.tripsView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.tripsView.layer.shadowOffset=CGSizeZero;
    self.tripsView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.tripsView.layer.shadowOpacity=1;
    self.tripsView.layer.shadowRadius=3;
    
    self.ratingView.layer.masksToBounds=YES;
    self.ratingView.layer.cornerRadius=3.0f;
    self.ratingView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.ratingView.layer.shadowOffset=CGSizeZero;
    self.ratingView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.ratingView.layer.shadowOpacity=1;
    self.ratingView.layer.shadowRadius=3;
    
    self.dueView.layer.masksToBounds=YES;
    self.dueView.layer.cornerRadius=3.0f;
    self.dueView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.dueView.layer.shadowOffset=CGSizeZero;
    self.dueView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.dueView.layer.shadowOpacity=1;
    self.dueView.layer.shadowRadius=3;
    
    self.earningView.layer.masksToBounds=YES;
    self.earningView.layer.cornerRadius=3.0f;
    self.earningView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.earningView.layer.shadowOffset=CGSizeZero;
    self.earningView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.earningView.layer.shadowOpacity=1;
    self.earningView.layer.shadowRadius=3;
    
    self.missedView.layer.masksToBounds=YES;
    self.missedView.layer.cornerRadius=3.0f;
    self.missedView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.missedView.layer.shadowOffset=CGSizeZero;
    self.missedView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.missedView.layer.shadowOpacity=1;
    self.missedView.layer.shadowRadius=3;
    
    self.commisionView.layer.masksToBounds=YES;
    self.commisionView.layer.cornerRadius=3.0f;
    self.commisionView.layer.backgroundColor=[UIColor colorWithRed:0.26 green:0.3 blue:0.45 alpha:1.0f].CGColor;
    self.commisionView.layer.shadowOffset=CGSizeZero;
    self.commisionView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f].CGColor;
    self.commisionView.layer.shadowOpacity=1;
    self.commisionView.layer.shadowRadius=3;
    
}

-(void)loadData
{
    [[ServerManager sharedManager] getRiderStatWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        if ( responseObject!=nil) {
            
            NSMutableDictionary* userInfo= [[NSMutableDictionary alloc] initWithDictionary:[responseObject dictionaryByReplacingNullsWithBlanks]];
            
            NSLog(@"user info %@",userInfo);
            
            [UserAccount sharedManager].commissionRate=[[[userInfo objectForKey:@"riderInfo"] objectForKey:@"commission_rate"] floatValue];
            [UserAccount sharedManager].missedRide=[[[userInfo objectForKey:@"riderInfo"] objectForKey:@"missed_ride"] intValue];
            [UserAccount sharedManager].rating=[[[userInfo objectForKey:@"riderInfo"] objectForKey:@"rating"] floatValue];
            [UserAccount sharedManager].due=[[[userInfo objectForKey:@"riderInfo"] objectForKey:@"rider_to_company_total_due"] floatValue];
            
            self.commissionRateLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].commissionRate];
            self.missedCountLabel.text=[NSString stringWithFormat:@"%d",[UserAccount sharedManager].missedRide];
            self.ratingLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].rating];
            self.dueLabel.text=[NSString stringWithFormat:@"%.2f",[UserAccount sharedManager].due];
            
          
            totalEarningData=[userInfo objectForKey:@"totalEarning"];
            totalRideData=[userInfo objectForKey:@"totalRide"];
            
            
            [self.tripsCollectionView reloadData];
            [self.earnsCollectionView reloadData];
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
            });
            
        }
    }];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    UICollectionViewCell *cell;
    
    if([collectionView isEqual:self.tripsCollectionView])
    {
        
        cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TripCell" forIndexPath:indexPath];
        
        UILabel* dataLabel=(UILabel*) [cell viewWithTag:1];
        UILabel* nameLabel=(UILabel*) [cell viewWithTag:2];
        if(indexPath.item==0)
        {
            nameLabel.text=@"Today";
            dataLabel.text=[NSString stringWithFormat:@"%d",[[totalRideData objectForKey:@"today"]intValue]];
        }
        else if(indexPath.item==1)
        {
            nameLabel.text=@"This Week";
            dataLabel.text=[NSString stringWithFormat:@"%d",[[totalRideData objectForKey:@"this_week"]intValue]];
        }
        else if(indexPath.item==2)
        {
            nameLabel.text=@"This Month";
            dataLabel.text=[NSString stringWithFormat:@"%d",[[totalRideData objectForKey:@"this_month"]intValue]];
            
        }
        else
        {
            nameLabel.text=@"This Year";
            dataLabel.text=[NSString stringWithFormat:@"%d",[[totalRideData objectForKey:@"this_year"]intValue]];
            
        }
    }
    else
    {
        cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"EarningCell" forIndexPath:indexPath];
       
        
        
        UILabel* dataLabel=(UILabel*) [cell viewWithTag:1];
        UILabel* nameLabel=(UILabel*) [cell viewWithTag:2];
        
        if(indexPath.item==0)
        {
            nameLabel.text=@"Today";
            dataLabel.text=[NSString stringWithFormat:@"%.2f৳",[[totalEarningData objectForKey:@"today"]floatValue]];
        }
        else if(indexPath.item==1)
        {
            nameLabel.text=@"This Week";
            dataLabel.text=[NSString stringWithFormat:@"%.2f৳",[[totalEarningData objectForKey:@"this_week"]floatValue]];
        }
        else if(indexPath.item==2)
        {
            nameLabel.text=@"This Month";
            dataLabel.text=[NSString stringWithFormat:@"%.2f৳",[[totalEarningData objectForKey:@"this_month"]floatValue]];
            
        }
        else
        {
            nameLabel.text=@"This Year";
            dataLabel.text=[NSString stringWithFormat:@"%.2f৳",[[totalEarningData objectForKey:@"this_year"]floatValue]];
            
        }
    }
    
    return cell;
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return collectionView.frame.size;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if(scrollView==self.tripsCollectionView)
    {
        CGFloat pageWidth = self.tripsCollectionView.frame.size.width;
        float currentPage = self.tripsCollectionView.contentOffset.x / pageWidth;
        
        if (0.0f != fmodf(currentPage, 1.0f))
        {
            self.tripPageControl.currentPage = currentPage + 1;
        }
        else
        {
            self.tripPageControl.currentPage = currentPage;
        }
    }
    else if(scrollView==self.earnsCollectionView)
    {
        CGFloat pageWidth = self.earnsCollectionView.frame.size.width;
        float currentPage = self.earnsCollectionView.contentOffset.x / pageWidth;
        
        if (0.0f != fmodf(currentPage, 1.0f))
        {
            self.earnsPageControl.currentPage = currentPage + 1;
        }
        else
        {
            self.earnsPageControl.currentPage = currentPage;
        }
    }
}
- (IBAction)changeTripPage:(UIPageControl *)sender {
    int page = (int)sender.currentPage;
   
    [self.tripsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}
- (IBAction)changeEarningPage:(UIPageControl*)sender {
    int page = (int)sender.currentPage;
    
    [self.earnsCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
