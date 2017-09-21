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
    NSMutableArray *weeklyDataArray;
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
    [self configureGraph];
    [self loadData];
  
    self.tripsCollectionView.delegate=self;
    self.tripsCollectionView.dataSource=self;
    
    self.earnsCollectionView.delegate=self;
    self.earnsCollectionView.dataSource=self;
    
}

-(void)configureGraph
{
    
    /* This is commented out because the graph is created in the interface with this sample app. However, the code remains as an example for creating the graph using code.
     BEMSimpleLineGraphView *myGraph = [[BEMSimpleLineGraphView alloc] initWithFrame:CGRectMake(0, 60, 320, 250)];
     myGraph.delegate = self;
     myGraph.dataSource = self;
     [self.view addSubview:myGraph]; */
    
    // Create a gradient to apply to the bottom portion of the graph
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 1.0,
        1.0, 1.0, 1.0, 0.0
    };
    
    // Apply the gradient to the bottom portion of the graph
    self.lineGraphView.gradientBottom = CGGradientCreateWithColorComponents(colorspace, components, locations, num_locations);
    
    // Enable and disable various graph properties and axis displays
    self.lineGraphView.enableTouchReport = YES;
    self.lineGraphView.enablePopUpReport = YES;
    self.lineGraphView.enableYAxisLabel = YES;
    self.lineGraphView.autoScaleYAxis = YES;
    self.lineGraphView.alwaysDisplayDots = YES;
    self.lineGraphView.enableReferenceXAxisLines = YES;
    self.lineGraphView.enableReferenceYAxisLines = YES;
    self.lineGraphView.enableReferenceAxisFrame = YES;
    
    // Draw an average line
    self.lineGraphView.averageLine.enableAverageLine = YES;
    self.lineGraphView.averageLine.alpha = 0.6;
    self.lineGraphView.averageLine.color = [UIColor lightGrayColor];
    self.lineGraphView.averageLine.width = 2.5;
    self.lineGraphView.averageLine.dashPattern = @[@(2),@(2)];
    
    // Set the graph's animation style to draw, fade, or none
    self.lineGraphView.animationGraphStyle = BEMLineAnimationDraw;
    
    // Dash the y reference lines
    self.lineGraphView.lineDashPatternForReferenceYAxisLines = @[@(2),@(2)];
    
    // Show the y axis values with this format string
    self.lineGraphView.formatStringForValues = @"%.1f";
    
    self.lineGraphView.dataSource = self;
    self.lineGraphView.delegate = self;
}

-(void)configureViewLayers
{
    self.view.layer.backgroundColor=[UIColor colorWithRed:.2 green:.23 blue:.38 alpha:1.0f].CGColor;
    
    self.lineGraphView.layer.backgroundColor=[UIColor colorWithRed:.2 green:.23 blue:.38 alpha:1.0f].CGColor;
    self.lineGraphView.layer.shadowOffset=CGSizeZero;
    self.lineGraphView.layer.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
    self.lineGraphView.layer.shadowOpacity=1;
    self.lineGraphView.layer.shadowRadius=5;
    
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
            
            if (!weeklyDataArray) weeklyDataArray = [[NSMutableArray alloc] init];
            [weeklyDataArray removeAllObjects];
            
            
            weeklyDataArray=[userInfo objectForKey:@"weeklyData"];
            
            self.lineGraphView.animationGraphStyle = BEMLineAnimationFade;
            [self.lineGraphView reloadGraph];
            
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


#pragma mark - SimpleLineGraph Data Source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return (int)[weeklyDataArray count];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [[[weeklyDataArray objectAtIndex:index]objectForKey:@"total_earning"] floatValue];
}

#pragma mark - SimpleLineGraph Delegate

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 2;
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    //[[weeklyDataArray objectAtIndex:index] objectForKey:@"week_day"]
    return @"H";
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didTouchGraphWithClosestIndex:(NSInteger)index {
//    self.labelValues.text = [NSString stringWithFormat:@"%@", [self.arrayOfValues objectAtIndex:index]];
//    self.labelDates.text = [NSString stringWithFormat:@"in %@", [self labelForDateAtIndex:index]];
}

- (void)lineGraph:(BEMSimpleLineGraphView *)graph didReleaseTouchFromGraphWithClosestIndex:(CGFloat)index {
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
////        self.labelValues.alpha = 0.0;
////        self.labelDates.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
//        self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
//
//        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            self.labelValues.alpha = 1.0;
//            self.labelDates.alpha = 1.0;
//        } completion:nil];
//    }];
}

- (void)lineGraphDidFinishLoading:(BEMSimpleLineGraphView *)graph {
//    self.labelValues.text = [NSString stringWithFormat:@"%i", [[self.myGraph calculatePointValueSum] intValue]];
//    self.labelDates.text = [NSString stringWithFormat:@"between %@ and %@", [self labelForDateAtIndex:0], [self labelForDateAtIndex:self.arrayOfDates.count - 1]];
}

/* - (void)lineGraphDidFinishDrawing:(BEMSimpleLineGraphView *)graph {
 // Use this method for tasks after the graph has finished drawing
 } */

- (NSString *)popUpSuffixForlineGraph:(BEMSimpleLineGraphView *)graph {
    return @" ৳";
}

//- (NSString *)popUpPrefixForlineGraph:(BEMSimpleLineGraphView *)graph {
//    return @"$ ";
//}

#pragma mark - Optional Datasource Customizations
/*
 This section holds a bunch of graph customizations that can be made.  They are commented out because they aren't required.  If you choose to uncomment some, they will override some of the other delegate and datasource methods above.
 
 */

//- (NSInteger)baseIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 0;
//}
//
//- (NSInteger)incrementIndexForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 2;
//}

//- (NSArray *)incrementPositionsForXAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSMutableArray *positions = [NSMutableArray array];
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSInteger previousDay = -1;
//    for(int i = 0; i < self.arrayOfDates.count; i++) {
//        NSDate *date = self.arrayOfDates[i];
//        NSDateComponents * components = [calendar components:NSCalendarUnitDay fromDate:date];
//        NSInteger day = components.day;
//        if(day != previousDay) {
//            [positions addObject:@(i)];
//            previousDay = day;
//        }
//    }
//    return positions;
//
//}
//
//- (CGFloat)baseValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSNumber *minValue = [graph calculateMinimumPointValue];
//    //Let's round our value down to the nearest 100
//    double min = minValue.doubleValue;
//    double roundPrecision = 100;
//    double offset = roundPrecision / 2;
//    double roundedVal = round((min - offset) / roundPrecision) * roundPrecision;
//    return roundedVal;
//}
//
//- (CGFloat)incrementValueForYAxisOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    NSNumber *minValue = [graph calculateMinimumPointValue];
//    NSNumber *maxValue = [graph calculateMaximumPointValue];
//    double range = maxValue.doubleValue - minValue.doubleValue;
//    float increment = 1.0;
//    if (range <  10) {
//        increment = 2;
//    } else if (range < 100) {
//        increment = 10;
//    } else if (range < 500) {
//        increment = 50;
//    } else if (range < 1000) {
//        increment = 100;
//    } else if (range < 5000) {
//        increment = 500;
//    } else {
//        increment = 1000;
//    }
//    return increment;
//}
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
