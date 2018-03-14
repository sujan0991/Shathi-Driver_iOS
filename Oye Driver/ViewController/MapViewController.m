//
//  MapViewController.m
//  Shathi
//
//  Created by Sujan on 5/16/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import "MapViewController.h"
#import <AccountKit/AccountKit.h>
#import "UserAccount.h"
#import "HexColors.h"
#import "DDHTimerControl.h"
#import "ServerManager.h"
#import "LocationShareModel.h"
#import "VerifyIdentityViewController.h"
#import "CancelReasonTableViewCell.h"
#import "JTMaterialSpinner.h"

#import "LegalDocumentUploadViewController.h"

@import Firebase;

@interface MapViewController (){

    JTMaterialSpinner *spinner;
    
    AKFAccountKit *_accountKit;
    
    CLLocationManager *locationManager;

    CLLocationCoordinate2D currentLocation;
    
    //CLLocationCoordinate2D googleMarkerLocation;
    
    CLLocationCoordinate2D googleSearchLocation;
    
    
    CLLocation *pickUpPoint ;
    CLLocation *destinationPoint;
    
    
    NSMutableArray *searchResults;
    NSMutableArray *searchResultsPlaceId;
    NSMutableDictionary *reverseGeoResult;
    
    NSMutableArray *homeWorkArray;
    
    int rideId;
    
    float totalRating;
    
    
    GMSMarker *pickUpMarker;
    GMSMarker *destinationMarker;
    
    NSString *phoneNo;
    
    NSMutableArray *cancelReasonArray;
    NSString* cancelReasonId;
}

@property (nonatomic, strong) DDHTimerControl *timerControl;
@property (nonatomic, strong) NSDate *endDate;



@end




@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    
    

   
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(rideInfo:) name:@"rideNotification" object:nil];
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(appBecomeActive:) name:@"becomeActiveNotification" object:nil];
    
    
    [self firstViewSetUp];
    [self drawShadow:self.navView];
    
   
    [self setMap];
    

    homeWorkArray = [[NSMutableArray alloc]init];
    
    NSLog(@"UserAccount sharedManager].riderIsApproved  %d",[UserAccount sharedManager].riderIsApproved);
    
    if ([UserAccount sharedManager].riderIsApproved == 1) {
        
        NSLog(@"approved");
        
    }else{
    
        VerifyIdentityViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VerifyIdentityViewController"];
        
        vc.isCrossHidden =YES;
    
        [self presentViewController:vc animated:YES completion:nil];

    }
    
    spinner=[[JTMaterialSpinner alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 17, self.view.frame.size.height/2 - 17, 35, 35)];
    [self.shadeView bringSubviewToFront:spinner];
    [self.shadeView addSubview:spinner];
    spinner.hidden =YES;
    
    
}

-(void)dealloc{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) drawShadow:(UIView *)view{
    
    
    view.layer.shadowColor = [[UIColor blackColor]CGColor];
    view.layer.shadowOffset = CGSizeMake(0, 4.0);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 5.0;
    
    
}

-(void) firstViewSetUp{

   
    
    self.rideSuggestionView.hidden = YES;
    self.arriveView.hidden = YES;
    self.startTripView.hidden = YES;
    self.finishTripView.hidden = YES;
    self.collectMoneyView.hidden = YES;
    
    self.cancelReasonView.hidden = YES;
    self.shadeView.hidden = YES;
    
    self.cancelReasonTableView.delegate = self;
    self.cancelReasonTableView.dataSource = self;
    self.cancelReasonTextView.delegate = self;
    
    self.rideSuggestionView.layer.cornerRadius = 3.0;
    self.arriveView.layer.cornerRadius = 3.0;
    self.startTripView.layer.cornerRadius = 3.0;
    self.finishTripView.layer.cornerRadius = 3.0;
    self.collectMoneyView.layer.cornerRadius = 3.0;


    
    [self circurelPhoto:self.passengerPhoto];
    [self circurelPhoto:self.passengerPhotoInArriveView];
    [self circurelPhoto:self.passengerPhotoInStartTripView];
    [self circurelPhoto:self.passengerPhotoInFinishTripView];
    [self circurelPhoto:self.passengerPhotoIncollectMoneyView];
    
    [self circurelLabel:self.ratingLabelInRideSuggestionView];
    [self circurelLabel:self.ratingLabelInArriveView];
    [self circurelLabel:self.ratingLabelInStartTripView];
    [self circurelLabel:self.ratingLabelInFinishTripView];
    [self circurelLabel:self.ratingLabelInCollectMoneyView];
    

    [UserAccount sharedManager].isOnRide = 0;
    
    totalRating = 0;
    
    self.locationShareModel= [LocationShareModel sharedModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

-(void) circurelPhoto:(UIImageView *)imageView{
    
    
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 5.0f;
    imageView.layer.borderColor = [[UIColor hx_colorWithHexString:@"#E9E9E9"]CGColor];
    
    
}
-(void) circurelLabel:(UILabel *)label{
    
    label.layer.cornerRadius = self.ratingLabelInRideSuggestionView.frame.size.width/2;
    label.layer.masksToBounds = YES;
}


-(void)setMap{
    
    //Map
    
    self.googleMapView.delegate = self;
    
    
    if (locationManager==nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 1;
    locationManager.distanceFilter = kCLDistanceFilterNone;
  
    [locationManager startUpdatingLocation];
    
    self.googleMapView.myLocationEnabled = YES;
    
//    [locationManager requestWhenInUseAuthorization];
    
    
  //  NSLog(@"current Device %lf",[[[UIDevice currentDevice] systemName] floatValue]);
    
//    if ([[[UIDevice currentDevice] systemName] floatValue] >= 8.0)
//    {
//        [locationManager requestWhenInUseAuthorization];
//        // NSLog(@"Requested");
//    }
//    else
//    {
//        [locationManager requestWhenInUseAuthorization];
//        [locationManager startUpdatingLocation];
//    }
//    

    
    
//    currentLocation = locationManager.location.coordinate;
 

}
//
//- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
//    
//   
//    
//    if([CLLocationManager locationServicesEnabled]){
//        
//        
//        [locationManager startUpdatingLocation];
//        self.googleMapView.myLocationEnabled = YES;
//        
//    }else{
//    
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
////                                                        message:@"You must enable your location."
////                                                       delegate:nil
////                                              cancelButtonTitle:@"OK"
////                                              otherButtonTitles:nil];
////        [alert show];
////    
//    }
//    
//  
//    
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    

    CLLocation *currentPostion=locations.lastObject;
    
    //CLLocation *currentPostion=locations.lastObject;
    currentLocation.latitude=currentPostion.coordinate.latitude;
    currentLocation.longitude=currentPostion.coordinate.longitude;
    
    NSLog(@"got the location");
    

        
    NSLog(@"Current Location = %f, %f",currentLocation.latitude,currentLocation.longitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
    
    
    
    [manager stopUpdatingLocation];
        
   
    if (currentPostion !=nil) {
        
        [self getCurrentLocation];
    }
    
    
}


-(void)getCurrentLocation{


    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(currentLocation.latitude,currentLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        
        GMSAddress* firstaddressObj = [response firstResult];
        
        NSLog(@"address %@", firstaddressObj.thoroughfare);
        NSLog(@"coordinate.latitude=%f", firstaddressObj.coordinate.latitude);
        NSLog(@"coordinate.longitude=%f", firstaddressObj.coordinate.longitude);
        
        
        
        NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
        
        if (firstaddressObj.thoroughfare != nil) {
            
            //[postData setObject:[NSString stringWithFormat:@"%@",firstaddressObj.subLocality] forKey:@"current_address"];
             [postData setObject:[NSString stringWithFormat:@"%@",firstaddressObj.thoroughfare] forKey:@"current_address"];
            
        }else{
        
               [postData setObject:[NSString stringWithFormat:@""] forKey:@"current_address"];
        }
     
        [postData setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.latitude]  forKey:@"current_latitude"];
        [postData setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.longitude] forKey:@"current_longitude"];
        
        NSLog(@"post data %@",postData);
        
        [[ServerManager sharedManager] patchRiderLocation:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
            
            
            if (success) {
                
                NSLog(@"successfully");
                

            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    
                });
            }
            
        }];
        
    }];


}

-(void)rideInfo: (NSNotification *)notification
{
    
    
    
    NSDictionary* rideInfo = [notification userInfo];
    
   // NSLog(@"ride info %@",rideInfo);
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                    message:[NSString stringWithFormat:@"%@",rideInfo]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
    
    NSData *webData = [[rideInfo objectForKey:@"data" ] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
   // NSLog(@"JSON DIct: %@", jsonDict);
    
    int notificationType = [[jsonDict objectForKey:@"notification_type"]intValue];
    
    if (notificationType == 1) {
        //ride request
        
        phoneNo =[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"user"] objectForKey:@"phone"];
        self.passengerNameLabel.text = [[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"user"] objectForKey:@"name"];
        
        self.picupLabel.text = [[jsonDict objectForKey:@"ride_info" ] objectForKey:@"pickup_address"];
        self.destinationLabel.text = [[jsonDict objectForKey:@"ride_info" ] objectForKey:@"destination_address"];
        
        pickUpPoint = [[CLLocation alloc] initWithLatitude:[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"pickup_latitude"] floatValue] longitude:[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"pickup_longitude"] floatValue]];
        destinationPoint = [[CLLocation alloc] initWithLatitude:[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"destination_latitude"] floatValue] longitude:[[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"destination_longitude"] floatValue]];
        
        NSLog(@"pick up point %@",pickUpPoint);
        NSLog(@"destination point %@",destinationPoint);
        
        //set picup marker
        
        if (pickUpMarker) {
            
            pickUpMarker.map = nil;
        }
        pickUpMarker = [[GMSMarker alloc] init];
        
        pickUpMarker.position = CLLocationCoordinate2DMake(pickUpPoint.coordinate.latitude, pickUpPoint.coordinate.longitude);
        
        pickUpMarker.title = [NSString stringWithFormat:@"%@",[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"pickup_address"]];
        
        pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];
        
        pickUpMarker.map = self.googleMapView;
        
        // set destination pin
        if (destinationMarker) {
            
            destinationMarker.map = nil;
        }
        
        destinationMarker= [[GMSMarker alloc] init];
        
        destinationMarker.position = CLLocationCoordinate2DMake(destinationPoint.coordinate.latitude, destinationPoint.coordinate.longitude);
        
        destinationMarker.title = [NSString stringWithFormat:@"%@",[[jsonDict objectForKey:@"ride_info" ] objectForKey:@"destination_address"]];
        
        destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];
        
        destinationMarker.map = self.googleMapView;
        
        
        [self drawpoliline:pickUpPoint destination:destinationPoint];
        
        rideId =[[[jsonDict objectForKey:@"ride_info"] objectForKey:@"id"]intValue];
        
        
        [self performSelector:@selector(showRideSuggestionView) withObject:self afterDelay:1.0 ];
        
    }else if (notificationType == 4){
        
       // self.rideSuggestionView.hidden = YES;
        self.arriveView.hidden = YES;
        self.startTripView.hidden = YES;
        self.finishTripView.hidden = YES;
        self.collectMoneyView.hidden = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"User cancel the request"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        NSLog(@"Rider cancel the request");
        
        [UIView animateWithDuration:.5
                              delay:0
                            options: UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             
                             self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width, self.rideSuggestionView.frame.size.height);
                             
                             
                         }
                         completion:^(BOOL finished){
                             
                             
                             self.rideSuggestionView.hidden = YES;
                             
                             
                         }];
        
        [self.googleMapView clear];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
        
        [self.googleMapView animateToCameraPosition:camera];
        
        
    }else if (notificationType == 10){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"generic"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        NSLog(@"generic");
        
    }
}


-(void)drawpoliline:(CLLocation *)origin destination:(CLLocation *)destination{


    //draw poliline
    
    
    
    [self fetchPolylineWithOrigin:origin destination:destination completionHandler:^(GMSPolyline *polyline)
     {
         
         
         if(polyline)

            polyline.map = self.googleMapView;
         
         
         }];
    

  
    GMSMutablePath *path = [[GMSMutablePath alloc] init];
    
    [path addLatitude:origin.coordinate.latitude longitude:origin.coordinate.longitude];
    [path addLatitude:destination.coordinate.latitude longitude:destination.coordinate.longitude];
    
    [self updateCameraPosition:path];
    

}

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     
                                                    
                                                     
                                                     GMSPolyline *polyline = nil;
                                                     if ([routesArray count] > 0)
                                                     {
                                                         NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                         
                                                        // NSLog(@"routeDict   %@",routeDict);
                                                         
                                                         NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                         NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                         GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                         polyline = [GMSPolyline polylineWithPath:path];
                                                         polyline.strokeWidth = 3.f;
                                                         polyline.strokeColor = [UIColor hx_colorWithHexString:@"262C4E"];
                                                         
                                                         NSArray * legs = [[NSArray alloc]init];
                                                         
                                                         legs = [routeDict objectForKey:@"legs"];
                                                         
                                                         //NSLog(@"legs   %@",legs);
                                                         
                                                         NSString *distance = [[[legs objectAtIndex:0]objectForKey:@"distance"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"distance   %@",distance);
                                                         
                                                         NSString *time = [[[legs objectAtIndex:0]objectForKey:@"duration"]objectForKey:@"text"];
                                                         
                                                         NSLog(@"duration   %@",time);
                                                         
                                                         
                                                     }
                                                     
                                                     // run completionHandler on main thread                                           
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                         
                                                         if(completionHandler)
                                                             completionHandler(polyline);
                                                         
                                                     });
                                                 }];
    [fetchDirectionsTask resume];
}

-(void)updateCameraPosition:(GMSMutablePath*)path {
    
    
    
    GMSCoordinateBounds *bounds =[[GMSCoordinateBounds alloc] initWithPath:path];
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds
                                             withPadding:100.0f];
    [self.googleMapView moveCamera:update];
    //[self.googleMapView animateToZoom:14];
    [self.googleMapView animateToViewingAngle:35];
    
    
   // [self performSelector:@selector(showFareView) withObject:self afterDelay:2.0 ];

}



//- (void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
//    
//    if (!self.staticPin.isHidden) {
//        
//        NSLog(@"position.target.latitude %f",position.target.latitude);
//        NSLog(@"position.target.longitude %f",position.target.longitude);
//        
//        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(position.target.latitude,position.target.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
//            
//            
//            GMSAddress* firstaddressObj = [response firstResult];
//            // if (self.customPicUpButton.isHidden) {
//            
//            self.destinationTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
//            
//            // }else{
//            
//            //     self.pickUpTextView.text = [NSString stringWithFormat:@"%@", firstaddressObj.thoroughfare];
//            //  }
//            NSLog(@"reverse geocoding firstaddressObj: %@",firstaddressObj.thoroughfare);
//        }];
//        
//        pickUpPoint = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
//        destinationPoint = [[CLLocation alloc] initWithLatitude:position.target.latitude longitude:position.target.longitude];
//        
//        
//        
//    }
//    
//}


- (IBAction)myLocationButtonAction:(id)sender {
    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
//
//    [self.googleMapView animateToCameraPosition:camera];
    
    LegalDocumentUploadViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"LegalDocumentUploadViewController"];
    
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
}



//- (void)keyboardDidShow: (NSNotification *) notif{
//   
//     self.searchLocationTableView.hidden = NO;
//}
//
//- (void)keyboardDidHide: (NSNotification *) notif{
//    
//    self.searchLocationTableView.hidden = YES;
//}



- (IBAction)turnOnLocationServiceButtonAction:(id)sender {
    
    

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        
        
   
}

- (IBAction)acceptRideButtonAction:(id)sender {
    

    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    
    [[ServerManager sharedManager] patchAcceptRide:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary){
        
        
        if (success) {
            
            NSLog(@"accept ride");
            NSLog(@"resultDataDictionary in accept ride %@",resultDataDictionary);
            
            int rideStatus = [[resultDataDictionary objectForKey:@"status"]intValue];
            
            if (rideStatus == 0) {
                
                NSLog(@"massage %@",[resultDataDictionary objectForKey:@"message"]);
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:[NSString stringWithFormat:@"%@",[resultDataDictionary objectForKey:@"message"]]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
                self.rideSuggestionView.hidden = YES;
                
                [self.googleMapView clear];
                
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
                
                [self.googleMapView animateToCameraPosition:camera];
                
                
                
//                //invalidate the timer
//                if (self.locationShareModel.timer) {
//                    
//                    [self.locationShareModel.timer invalidate];
//                    self.locationShareModel.timer = nil;
//                    NSLog(@"self.shareModel.timer");
//                }
//                
//                //invalidate locaton uptade timer
//                
//                if (self.locationUpdateTimer) {
//                    
//                    [self.locationUpdateTimer invalidate];
//                    self.locationUpdateTimer = nil;
//                    NSLog(@"self.locationUpdateTimer ");
//                }
//                
//                
//                self.locationTracker = [[LocationTracker alloc]init];
//                
//                NSLog(@"self.locationTracker ");
//                
//                [self.locationTracker startLocationTracking];
//                
//                //Send the best location to server every 60 seconds
//                //You may adjust the time interval depends on the need of your app.
//                NSTimeInterval time = 60*5;
//                self.locationUpdateTimer =
//                [NSTimer scheduledTimerWithTimeInterval:time
//                                                 target:self
//                                               selector:@selector(updateLocationfromMap)
//                                               userInfo:nil
//                                                repeats:YES];
                
                
            }else  {
                
                
                if (self.locationShareModel.timer) {
                    
                    [self.locationShareModel.timer invalidate];
                    self.locationShareModel.timer = nil;
                    NSLog(@"self.shareModel.timer in start trip  = nil");
                }
                
                if (self.locationUpdateTimer) {
                    
                    [self.locationUpdateTimer invalidate];
                    self.locationUpdateTimer = nil;
                    NSLog(@"self.locationUpdateTimer in start trip  = nil");
                }
                
                self.locationTracker = [[LocationTracker alloc]init];
                
                NSLog(@"self.locationTracker in start trip");
                
                
                [self.locationTracker removePlistData];
                
                [self.locationTracker startMonitoringSignificantLocation];
                
                [self.locationTracker startLocationTracking];
                
                [self performSelector:@selector(updateLocationfromMap) withObject:self afterDelay:6.0 ];
                
                NSTimeInterval time = 60.0;
                self.locationUpdateTimer =
                [NSTimer scheduledTimerWithTimeInterval:time
                                                 target:self
                                               selector:@selector(updateLocationfromMap)
                                               userInfo:nil
                                                repeats:YES];
                
                
                
                [UIView animateWithDuration:.5
                                      delay:0
                                    options: UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     
                                     
                                     self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width, self.rideSuggestionView.frame.size.height);
                                     
                                     
                                 }
                                 completion:^(BOOL finished){
                                     
                                     NSLog(@"loadPlistData %@",[[self.locationTracker loadPlistData] objectForKey:@"LocationArray"]);
                                     
                                     self.rideSuggestionView.hidden = YES;
                                     [self showStartTripView];
                                     
                                 }];
                
                
                
            }
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@" not accept ride");
                
            });
        }
        
    }];
}
- (IBAction)arriveButtonAction:(id)sender {
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    
    [[ServerManager sharedManager] patchArrive:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary){
        
        
        if (success) {
            
            NSLog(@"arrive ride");
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                 self.arriveView.frame = CGRectMake(20,self.view.frame.size.height ,self.arriveView.frame.size.width, self.arriveView.frame.size.height);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.arriveView.hidden = YES;
                                 [self showStartTripView];
                                 
                             }];
            
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
}
- (IBAction)cancelRideRequestButtonAction:(id)sender {
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    
    [[ServerManager sharedManager] patchCancelRideRequest:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary){
        
        
        if (success) {
            
            NSLog(@"cancel ride");
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                     
                                     self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width, self.rideSuggestionView.frame.size.height);
                                     
                                 
                                 
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.rideSuggestionView.hidden = YES;
                                 
                                 [self.googleMapView clear];
                                 
                                 GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
                                 
                                 [self.googleMapView animateToCameraPosition:camera];
                                 
                                 
                             }];
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
    
}

#pragma mark - UITableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

        return cancelReasonArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
        static NSString *CellIdentifier = @"reasonCell";
    
        CancelReasonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        if (!cell)
            cell = [[CancelReasonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
        cell.reasonLabel.text = [[cancelReasonArray objectAtIndex:indexPath.row] objectForKey:@"reason"];
    
    
    
        return cell;
    
    
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        
        //[tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        cancelReasonId = [[cancelReasonArray objectAtIndex:indexPath.row] objectForKey:@"id"];
        
        NSLog(@"cancelReasonId  %@",cancelReasonId);
        NSLog(@"selected index  %lu",(cancelReasonArray.count - 1));
        
        if (indexPath.row == (cancelReasonArray.count - 1)) {
            
            [self.cancelReasonTextView becomeFirstResponder];
            
        }else{
            
            [self.cancelReasonTextView resignFirstResponder];
        }
        
        
    }

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.cancelReasonView.isHidden) {
        
        [self.cancelReasonTextView resignFirstResponder];
        
        NSLog(@"Is it called");
    }
    
}

- (IBAction)cancelRideButtonAction:(id)sender {
    
    [[ServerManager sharedManager] getRideCancelReasosnsWithCompletion:^(BOOL success, NSMutableDictionary *responseObject) {
        
        
        if ( responseObject!=nil) {
            
            
            cancelReasonArray = [responseObject objectForKey:@"data"];
            NSLog(@"reasons in mapview  %@",cancelReasonArray);
            
            [self.cancelReasonTableView reloadData];
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                 self.startTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.startTripView.frame.size.width, self.startTripView.frame.size.height);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 self.startTripView.hidden = YES;
                                 
                                 self.backButton.hidden = YES;
                                 
                                 
                                 
                                 
                             }];

            
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no user info");
                
                
            });
            
        }
    }];
    
    self.cancelReasonView.hidden = NO;
    self.shadeView.hidden = NO;


    
}

- (IBAction)cancelReasonSubmitButtonAction:(id)sender {
    
    self.cancelReasonView.hidden = YES;
    self.shadeView.hidden = YES;
    
    [self.cancelReasonTextView resignFirstResponder];
    
    NSMutableDictionary* reasons=[[NSMutableDictionary alloc] init];
    
    [reasons setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    [reasons setObject:cancelReasonId forKey:@"ride_cancel_reason_id"];
    
    if (self.cancelReasonTextView.text.length>0) {
        
        [reasons setObject:self.cancelReasonTextView.text forKey:@"other_cancel_reason"];
        
    }
    
    
    NSLog(@"post data %@",reasons);
    
    [[ServerManager sharedManager] cancelRideWithReason:reasons withCompletion:^(BOOL success) {
        
        
        if (success) {
            
            NSLog(@"successfully");

               [self.googleMapView clear];
            
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
               [self.googleMapView animateToCameraPosition:camera];
             
             
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed!"
                                                                message:@"Please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
            });
        }
        
    }];
    

    
}

- (void)keyboardDidShow: (NSNotification *) notif{
    
    if (!self.cancelReasonView.isHidden) {
        

        NSDictionary* info = [notif userInfo];
        
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        NSLog(@"keyboard height %f",kbSize.height);
        
        //self.cancelReasonViewCenterConstraint.constant = -kbSize.height * 0.6;
        
        self.otherReasonsBottomConstraint.constant = kbSize.height * 0.6;
        
       
        
        
    }
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
    if (!self.cancelReasonView.isHidden) {
        
        //self.cancelReasonViewCenterConstraint.constant = 0;
        self.otherReasonsBottomConstraint.constant = 0;
        
        
    }
}



-(void) showRideSuggestionView{

    NSLog(@"ride id in ride suggestion view %d",rideId);
    
    self.rideSuggestionView.hidden = NO;
    self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width,self.rideSuggestionView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.rideSuggestionView.frame = CGRectMake(20,(self.view.frame.size.height - self.rideSuggestionView.frame.size.height-49) ,self.rideSuggestionView.frame.size.width,self.rideSuggestionView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                         NSLog(@"frame: %@", NSStringFromCGRect(self.rideSuggestionView.frame));
                         
                     }];


}
-(void) showArrivedView{
    
    if (self.passengerNameInArriveView.text.length == 0 ) {
    
    self.pickupLabelInArriveView.text = self.picupLabel.text;
    self.destinationLabelInArriveView.text = self.destinationLabel.text;
    self.passengerNameInArriveView.text = self.passengerNameLabel.text;
        
    }
    self.arriveView.hidden = NO;
    NSLog(@"self.arriveView.frame %@",[self.view subviews]);
    
    self.arriveView.frame = CGRectMake(20,self.view.frame.size.height ,self.arriveView.frame.size.width,self.arriveView.frame.size.height);
   
  
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                        self.arriveView.frame = CGRectMake(20,(self.view.frame.size.height - self.arriveView.frame.size.height-49) ,self.arriveView.frame.size.width,self.arriveView.frame.size.height);
                    

                     }

                     completion:^(BOOL finished){

               
                     }];
    
    
    NSLog(@"[UserAccount sharedManager].isOnRide %d",[UserAccount sharedManager].isOnRide);
    
    
}

-(void) showStartTripView{
    
    self.pickupLabelInStartTripView.text = self.picupLabel.text;
    self.destinationLabelInStartTripView.text = self.destinationLabel.text;
    self.passengerNameLabelInStartTripView.text = self.passengerNameLabel.text;
    
    self.startTripView.hidden = NO;
    self.startTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.startTripView.frame.size.width,self.startTripView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.startTripView.frame = CGRectMake(20,(self.view.frame.size.height - self.startTripView.frame.size.height-49) ,self.startTripView.frame.size.width,self.startTripView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];
    
   
    NSLog(@"[UserAccount sharedManager].isOnRide %d",[UserAccount sharedManager].isOnRide);

    
}

- (IBAction)startTripButtonAction:(id)sender {
    
    [UserAccount sharedManager].isOnRide = 1;
    
   
//    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.latitude] forKey:@"latitude"];
//    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.longitude] forKey:@"longitude"];
    //[dict setObject:@"start" forKey:@"start or stop"];
    
//
//    [self.locationShareModel.tripLocationArray addObject:dict];
//

//    if (self.locationShareModel.timer) {
//
//        [self.locationShareModel.timer invalidate];
//        self.locationShareModel.timer = nil;
//        NSLog(@"self.shareModel.timer in start trip  = nil");
//    }
//
//    if (self.locationUpdateTimer) {
//
//        [self.locationUpdateTimer invalidate];
//        self.locationUpdateTimer = nil;
//        NSLog(@"self.locationUpdateTimer in finish trip  = nil");
//    }
//
//    self.locationTracker = [[LocationTracker alloc]init];
//
//    NSLog(@"self.locationTracker in start trip");
//
//
//    [self.locationTracker removePlistData];
//
//    [self.locationTracker startMonitoringSignificantLocation];
//
//    [self.locationTracker startLocationTracking];
//
//    [self performSelector:@selector(updateLocationfromMap) withObject:self afterDelay:6.0 ];
//
//    NSTimeInterval time = 60.0;
//    self.locationUpdateTimer =
//    [NSTimer scheduledTimerWithTimeInterval:time
//                                     target:self
//                                   selector:@selector(updateLocationfromMap)
//                                   userInfo:nil
//                                    repeats:YES];
    
    

    
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    
    
    [[ServerManager sharedManager] patchStartRide:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary){
        
        
        if (success) {
            
            NSLog(@"start ride");
            
            
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                 self.startTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.startTripView.frame.size.width, self.startTripView.frame.size.height);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.startTripView.hidden = YES;
                                 
                                 [self showFinishTripView];
                                 
                             }];
            
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
    
    
}



-(void)showFinishTripView{

    NSLog(@"showFinishTripView");
    if (self.passengerNameInFinishTripView.text.length == 0) {
        
        self.pickupLabelInFinishTripView.text = self.picupLabel.text;
        self.destinationLabelInFinishTripView.text = self.destinationLabel.text;
        self.passengerNameInFinishTripView.text = self.passengerNameLabel.text;

    }
    self.finishTripView.hidden = NO;
    self.finishTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.finishTripView.frame.size.width,self.finishTripView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.finishTripView.frame = CGRectMake(20,(self.view.frame.size.height - self.finishTripView.frame.size.height-49) ,self.finishTripView.frame.size.width,self.finishTripView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];




}


- (IBAction)finishTripButtonAction:(id)sender {
    
    self.shadeView.hidden = NO;
    spinner.hidden = NO;
    [spinner beginRefreshing];
    
    [self updateLocationfromMap];
    [self performSelector:@selector(sendLocationDataOnFinishingTrip) withObject:self afterDelay:5.0 ];
    
}

-(void)sendLocationDataOnFinishingTrip
{
    self.locationShareModel.tripLocationArray=[[self.locationTracker loadPlistData] objectForKey:@"LocationArray"];
    
    
    
    
    if(self.locationShareModel.tripLocationArray ==nil || self.locationShareModel.tripLocationArray == NULL){
        
        self.locationShareModel.tripLocationArray = [[NSMutableArray alloc]init];
        
    }
    NSLog(@"tripLocationArray  %@",self.locationShareModel.tripLocationArray);
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.locationShareModel.tripLocationArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (jsonData && !error)
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"location JSON: %@", jsonString);
    }
    
    
    NSLog(@"ride id %d",rideId);
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    //[postData setObject:@"188" forKey:@"ride_id"];
    [postData setObject:jsonString forKey:@"waypoints"];
    
    [[ServerManager sharedManager] patchFinishRide:postData withCompletion:^(BOOL success, NSMutableDictionary *responseObject){
        
        
        if (responseObject!=nil) {
            self.shadeView.hidden = YES;
            spinner.hidden = YES;
            [spinner endRefreshing];
            
            [UserAccount sharedManager].isOnRide = 0;
            
            self.finishTripView.hidden = YES;
            
            //            [UIView animateWithDuration:.5
            //                                  delay:0
            //                                options: UIViewAnimationOptionCurveEaseIn
            //                             animations:^{
            //
            //
            //                                 self.finishTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.finishTripView.frame.size.width, 0);  // ???????????????????????? why it is not working ??????
            //
            //
            //                             }
            //                             completion:^(BOOL finished){
            //
            //
            //                                 self.finishTripView.hidden = YES;
            //
            //                                 [self showCollectMoneyView];
            //
            //                             }];
            
            [self showCollectMoneyView];
            
            NSLog(@"finish ride");
            
            NSLog(@"responseObject in finish ride %@",responseObject);
            
            
            
            self.passengerNameIncollectMoneyView.text  = self.passengerNameLabel.text;
            self.totalFareLabel.text = [NSString stringWithFormat:@"%@",[[[responseObject objectForKey:@"data"]objectForKey:@"detail"]objectForKey:@"total_payable_fare"]];
            
            NSLog(@"total_payable_fare %@",[[[responseObject objectForKey:@"data"]objectForKey:@"detail"]objectForKey:@"total_payable_fare"]);
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.shadeView.hidden = YES;
                spinner.hidden = YES;
                [spinner endRefreshing];
                
            });
        }
        
    }];
    
    
    
    [self.locationTracker stopMonitoringSignificantLocation];
    
    
    //invalidate the timer
    if (self.locationShareModel.timer) {
        
        [self.locationShareModel.timer invalidate];
        self.locationShareModel.timer = nil;
        NSLog(@"self.shareModel.timer in finish trip  = nil");
    }
    
    //invalidate locaton uptade timer
    
    if (self.locationUpdateTimer) {
        
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
        NSLog(@"self.locationUpdateTimer in finish trip  = nil");
    }
    
    
    self.locationTracker = [[LocationTracker alloc]init];
    
    NSLog(@"self.locationTracker in finish trip");
    
    [self.locationTracker startLocationTracking];
    
    //Send the best location to server every 60 seconds
    //You may adjust the time interval depends on the need of your app.
    NSTimeInterval time = 60*5;
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(updateLocationfromMap)
                                   userInfo:nil
                                    repeats:YES];
    
    
}

-(void)updateLocationfromMap {
    
    NSLog(@"updateLocation in outside if");
    
   [self.locationTracker startLocationTracking];
    
    if ([UserAccount sharedManager].riderStatus != 1) {
    
        NSLog(@"ison ride  in map %d",[UserAccount sharedManager].isOnRide);
    
        NSLog(@"updateLocation in map");
        [self.locationTracker updateLocationToServer];
    
    }else if (self.locationUpdateTimer) {
    
    
        //invalidate locaton uptade timer
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
        NSLog(@"self.locationUpdateTimer in updateLocationfromMap  = nil");
    
    }
}


-(void)showCollectMoneyView{
    
    self.collectMoneyView.hidden = NO;
    self.collectMoneyView.frame = CGRectMake(20,self.view.frame.size.height ,self.collectMoneyView.frame.size.width,self.collectMoneyView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         
                         self.collectMoneyView.frame = CGRectMake(20,(self.view.frame.size.height - self.collectMoneyView.frame.size.height-49) ,self.collectMoneyView.frame.size.width,self.collectMoneyView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];

    self.passengerNameIncollectMoneyView.text = self.passengerNameLabel.text;
    
    self.rateView.notSelectedImage = [UIImage imageNamed:@"Star_deactive.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"Star_active.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"Star_active.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;


}

- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating {
    
    
    
    totalRating = rating;
    
    NSLog(@"RATING is :)%f",totalRating);
    
}

- (IBAction)collectMoneyButtonAction:(id)sender {
    
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    [postData setObject:[NSString stringWithFormat:@"%.1f",totalRating] forKey:@"rating"];
    
    [[ServerManager sharedManager] patchRating:postData withCompletion:^(BOOL success, NSMutableDictionary *resultDataDictionary) {
        
        if ( resultDataDictionary!=nil) {
            
            NSLog(@"  info  %@",resultDataDictionary);
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionTransitionNone
                             animations:^{
                                 
                                 
                                 self.collectMoneyView.frame = CGRectMake(20,self.view.frame.size.height ,self.collectMoneyView.frame.size.width, self.collectMoneyView.frame.size.height);
                                 
                                 [self.googleMapView clear];
                                 
                                 GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
                                 
                                 [self.googleMapView animateToCameraPosition:camera];
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.collectMoneyView.hidden = YES;
                                 
                                 
                                 
                             }];
                                 
                                 
                                 
            
            
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"no  info");
                
                
            });
            
        }
        
        
        
    }];

    
    
}


- (IBAction)phoneButtonAction:(id)sender {
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNo]] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                
                NSLog(@"Opened url");
            }
        }];
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNo]]];
        
    }
    
}

- (IBAction)messageButtonAction:(id)sender {
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", phoneNo]] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                
                NSLog(@"Opened url");
            }
        }];
    }else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", phoneNo]]];
        
    }
}

-(void)appBecomeActive: (NSNotification *)notification
{
    
    NSDictionary* info = [notification userInfo];
    
    NSLog(@"ride info in appbecome active %@",info);
    
    
    NSLog(@"app become active");
    int status = [[info objectForKey:@"status"]intValue];
    
    if (status == 2) {
        
         NSLog(@"rider going to pickup");
        
        [self reSetViewWhenActive:info];

        

        NSLog(@"arriveview %d",_arriveView.isHidden);
        if (self.arriveView.isHidden) {

            self.passengerNameInArriveView.text = [[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"name"];
             self.ratingLabelInArriveView.text = [NSString stringWithFormat:@"%@",[[[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"metadata"] objectForKey:@"rating_avg"]];;
            self.pickupLabelInArriveView.text = [[info objectForKey:@"data"] objectForKey:@"pickup_address"];
            self.destinationLabelInArriveView.text = [[info objectForKey:@"data"] objectForKey:@"destination_address"];
            
            phoneNo = [[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"phone"];
            
            [self performSelector:@selector(showArrivedView) withObject:self afterDelay:1.0 ];

            NSLog(@"bhdfhjnfgkmfhld");
        }
    }
    else if (status == 3)
    {
        
         NSLog(@"rider on ride");
       
        rideId = [[[info objectForKey:@"data"]objectForKey:@"id"]intValue];
        
       // [self reSetViewWhenActive:info];
        
        NSLog(@"[[[info objectForKey:objectForKey:objectForKey:] %@",[[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"name"]);
        
        
        
        phoneNo = [[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"phone"];
        
        [UserAccount sharedManager].isOnRide = 1;
        [UserAccount sharedManager].riderStatus = 4;
         NSLog(@"rider on ride %d",[UserAccount sharedManager].isOnRide);
        
        if (self.finishTripView.isHidden)
        {
            self.passengerNameInFinishTripView.text = [[[info objectForKey:@"data" ]objectForKey:@"user"] objectForKey:@"name"];
            // self.ratingInDriverSuggestionView.text = [[[[jsonDict objectForKey:@"rider_info" ] objectForKey:@"user"] objectForKey:@"metadata"]objectForKey:@"rating_avg"];
            self.pickupLabelInFinishTripView.text = [[info objectForKey:@"data"] objectForKey:@"pickup_address"];
            self.destinationLabelInFinishTripView.text = [[info objectForKey:@"data"] objectForKey:@"destination_address"];
            
            [self performSelector:@selector(showFinishTripView) withObject:self afterDelay:1.0 ];
            
        }

            //[UserAccount sharedManager].riderStatus =
            NSLog(@"[UserAccount sharedManager] riderStatus %d",[UserAccount sharedManager].riderStatus);
            
            self.locationTracker = [[LocationTracker alloc]init];
            [self.locationTracker startMonitoringSignificantLocation];
            [self.locationTracker startLocationTracking];
            
            //Send the best location to server every 30 seconds
         
            
            [self.locationUpdateTimer invalidate];
        
            NSTimeInterval time = 60.0;
            self.locationUpdateTimer =
            [NSTimer scheduledTimerWithTimeInterval:time
                                             target:self
                                           selector:@selector(updateLocationfromMap)
                                           userInfo:nil
                                            repeats:YES];
            
            
    }
    else if (status == 4){
        
        rideId = [[[info objectForKey:@"data"]objectForKey:@"id"]intValue];
        
        if (self.collectMoneyView.isHidden) {
            
            
            [self performSelector:@selector(showCollectMoneyView) withObject:self afterDelay:1.0 ];
            
            
        }
            
            
    }
        
        
        
}
    

-(void)reSetViewWhenActive:(NSDictionary*)info{
    
    rideId = [[[info objectForKey:@"data"]objectForKey:@"id"]intValue];

    pickUpPoint = [[CLLocation alloc] initWithLatitude:[[[info objectForKey:@"data"]objectForKey:@"pickup_latitude"] floatValue] longitude:[[[info objectForKey:@"data"]objectForKey:@"pickup_longitude"] floatValue]];
    
    destinationPoint = [[CLLocation alloc] initWithLatitude:[[[info objectForKey:@"data"] objectForKey:@"destination_latitude"] floatValue] longitude:[[[info objectForKey:@"data"] objectForKey:@"destination_longitude"] floatValue]];

    NSLog(@"pickupPoint in reSetViewWhenActive %@",pickUpPoint);

    //set picup marker

    if (pickUpMarker) {

        pickUpMarker.map = nil;
    }
    pickUpMarker = [[GMSMarker alloc] init];

    pickUpMarker.position = CLLocationCoordinate2DMake(pickUpPoint.coordinate.latitude, pickUpPoint.coordinate.longitude);

    pickUpMarker.title = [NSString stringWithFormat:@"%@",[[info objectForKey:@"data"] objectForKey:@"pickup_address"]];

    pickUpMarker.icon = [UIImage imageNamed:@"Pickup.png"];

    pickUpMarker.map = self.googleMapView;
    NSLog(@"self.googleMapView %@",pickUpMarker.map);
    
    // set destination pin
    if (destinationMarker) {

        destinationMarker.map = nil;
    }

    destinationMarker= [[GMSMarker alloc] init];
    destinationMarker.position = CLLocationCoordinate2DMake(destinationPoint.coordinate.latitude, destinationPoint.coordinate.longitude);

    destinationMarker.title = [NSString stringWithFormat:@"%@",[[info objectForKey:@"data"] objectForKey:@"destination_address"]];

    destinationMarker.icon = [UIImage imageNamed:@"Destination.png"];
    destinationMarker.map = self.googleMapView;

    [self drawpoliline:pickUpPoint destination:destinationPoint];
}

- (IBAction)backButtonAction:(id)sender {
    

}

- (IBAction)settingButtonAction:(id)sender {
    
//    SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
//    
//    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
