//
//  DashboardViewController.h
//  OyeTest
//
//  Created by Tanvir Palash on 22/8/17.
//  Copyright © 2017 Tanvir Palash. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UIView *graphView;

@property (weak, nonatomic) IBOutlet UIView *tripsView;
@property (weak, nonatomic) IBOutlet UICollectionView *tripsCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *tripPageControl;

@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet UIView *dueView;
@property (weak, nonatomic) IBOutlet UIView *missedView;
@property (weak, nonatomic) IBOutlet UIView *commisionView;

@property (weak, nonatomic) IBOutlet UIView *earningView;
@property (weak, nonatomic) IBOutlet UICollectionView *earnsCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *earnsPageControl;

@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueLabel;
@property (weak, nonatomic) IBOutlet UILabel *missedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commissionRateLabel;


@end
