//
//  MapViewController.h
//  Shathi
//
//  Created by Sujan on 5/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "RateView.h"
#import "LocationTracker.h"

@interface MapViewController : UIViewController<CLLocationManagerDelegate,GMSMapViewDelegate,UITextFieldDelegate,RateViewDelegate>




@property (weak, nonatomic) IBOutlet GMSMapView *googleMapView;
@property (weak, nonatomic) IBOutlet UIView *navView;



@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;



@property (weak, nonatomic) IBOutlet UIView *rideSuggestionView;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *passengerPhoto;
@property (weak, nonatomic) IBOutlet UIButton *acceptRideButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelRideButton;
@property (weak, nonatomic) IBOutlet UILabel *picupLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;


@property (weak, nonatomic) IBOutlet UIView *startTripView;
@property (weak, nonatomic) IBOutlet UIImageView *passengerPhotoInStartTripView;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameLabelInStartTripView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabelInStartTripView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabelInStartTripView;
@property (weak, nonatomic) IBOutlet UIButton *startTripButton;

@property (weak, nonatomic) IBOutlet UIView *finishTripView;
@property (weak, nonatomic) IBOutlet UIImageView *passengerPhotoInFinishTripView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabelInFinishTripView;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabelInFinishTripView;
@property (weak, nonatomic) IBOutlet UIButton *finishTripButton;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameInFinishTripView;

@property (weak, nonatomic) IBOutlet UIView *collectMoneyView;
@property (weak, nonatomic) IBOutlet UIImageView *passengerPhotoIncollectMoneyView;
@property (weak, nonatomic) IBOutlet UILabel *passengerNameIncollectMoneyView;

@property (weak, nonatomic) IBOutlet RateView *rateView;

@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property LocationShareModel * locationShareModel;

@end
