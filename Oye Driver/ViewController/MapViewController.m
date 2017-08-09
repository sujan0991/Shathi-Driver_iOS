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

@import Firebase;

@interface MapViewController (){

    AKFAccountKit *_accountKit;
    
    CLLocationManager *locationManager;

    CLLocationCoordinate2D currentLocation;
    
    //CLLocationCoordinate2D googleMarkerLocation;
    
    CLLocationCoordinate2D googleSearchLocation;
    
    
    CLLocation *picupPoint ;
    CLLocation *destinationPoint;
    
    
    NSMutableArray *searchResults;
    NSMutableArray *searchResultsPlaceId;
    NSMutableDictionary *reverseGeoResult;
    
    NSMutableArray *homeWorkArray;
    
    int rideId;
    
    NSString* totalRating;
    
}

@property (nonatomic, strong) DDHTimerControl *timerControl;
@property (nonatomic, strong) NSDate *endDate;



@end




@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //demo access token
    
    [UserAccount sharedManager].accessToken = @"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjEwYmE0YzZlOTUyMWY5NDkzN2ZiZGY2OGNlYzI1NTFlZGQzODQ5MzcyNTZmMGE4MDg3MzhhNmIwNzhhZWY4ZjNmNzA5NDc3ZDQwYjliMTFjIn0.eyJhdWQiOiIxIiwianRpIjoiMTBiYTRjNmU5NTIxZjk0OTM3ZmJkZjY4Y2VjMjU1MWVkZDM4NDkzNzI1NmYwYTgwODczOGE2YjA3OGFlZjhmM2Y3MDk0NzdkNDBiOWIxMWMiLCJpYXQiOjE0OTY5MTAxMTgsIm5iZiI6MTQ5NjkxMDExOCwiZXhwIjoxNTI4NDQ2MTE4LCJzdWIiOiIxMyIsInNjb3BlcyI6W119.IsnbumQjzfwCbpnUIIRERUWZNrJ_3TLQx2yZtYULFXGoeHEpOdElwd_Y1VK2G3CCGoLeQNBiHN2IRPVXHSYSjyanUcn92ugn4lkl8lAicgc7CMf2aJ51mzJpLs1U-KXUd7cDygM9Agt69z52KN5b0OPZ8p8kywOj7139XClvokJW9B4KpgpoGYNdMgUzooMHyAnfP7CuHLlfmAV27FtaoEhthpYKcI1EVkVL2y6DwV1zOrxD8wvEbSjPBADlc1W5H13d4LgTEqsRNv4Fb7rvjjS2wwdzX_I_O5Z6LiLV95TiHBHTqJpz7PTUzIRU-IKYzatoQr2nVDlR7V8ck4aD9Ql4B85yTqg5LCnVXRxwPZNV0UKAhC1KH6XFve52_VHZ5_hp8E4AKLjxfppgsa8hfA7Sa8iOBnrOVnF1_L6TP-Pl022NRSAo7JedNDbF0yllACWT_oZ7P5H8Cq9dBQRBasG61pxqZBQ_65hzULk6shWY6HoqMxHWpFSIo12pdC98LcSCxsYwQI1Sxaq0qw3DhxlYOgGqreHY1Pr8T35wdAx_fePbgU5dPCZTfrBKwYL_7eb5lR1EME06OEKHUk5dPXa3h18Vjong-nNd1zPeu7894T7ai_q-ArRnS8MjV4lLwbZO3nr6HP8154etkbjQ3uno9QK_98vl51l4cH4f5iE";
    


    
   
    [[NSNotificationCenter defaultCenter ]addObserver:self selector:@selector(rideInfo:) name:@"rideNotification" object:nil];
    
    
    [self firstViewSetUp];
    [self drawShadow:self.navView];
    
   
    [self setMap];
    
    
    
    
    homeWorkArray = [[NSMutableArray alloc]init];
    
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
    self.startTripView.hidden = YES;
    self.finishTripView.hidden = YES;
    self.collectMoneyView.hidden = YES;
    
    self.rideSuggestionView.layer.cornerRadius = 3.0;
    self.startTripView.layer.cornerRadius = 3.0;
    self.finishTripView.layer.cornerRadius = 3.0;
    self.collectMoneyView.layer.cornerRadius = 3.0;


    
    [self circurelPhoto:self.passengerPhoto];
    [self circurelPhoto:self.passengerPhotoInStartTripView];
    [self circurelPhoto:self.passengerPhotoInFinishTripView];
    [self circurelPhoto:self.passengerPhotoIncollectMoneyView];
    

    [UserAccount sharedManager].isOnRide = 0;
    
    self.locationShareModel= [LocationShareModel sharedModel];
    
}

-(void) circurelPhoto:(UIImageView *)imageView{
    
    
    imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 5.0f;
    imageView.layer.borderColor = [[UIColor hx_colorWithHexString:@"#E9E9E9"]CGColor];
    
    
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
        
        if (firstaddressObj.thoroughfare == nil) {
            
            [postData setObject:[NSString stringWithFormat:@"%@",firstaddressObj.subLocality] forKey:@"current_address"];
        }else{
        
               [postData setObject:[NSString stringWithFormat:@"%@",firstaddressObj.thoroughfare] forKey:@"current_address"];
        }
     
        [postData setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.latitude]  forKey:@"current_latitude"];
        [postData setObject:[NSString stringWithFormat:@"%f",firstaddressObj.coordinate.longitude] forKey:@"current_longitude"];
        
        NSLog(@"post data %@",postData);
        
        [[ServerManager sharedManager] patchRiderLocation:postData withCompletion:^(BOOL success) {
            
            
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
    
    NSLog(@"ride info %@",rideInfo);
    
    NSData *webData = [[rideInfo objectForKey:@"gcm.notification.data" ] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
    NSLog(@"JSON DIct: %@", jsonDict);
    
    self.picupLabel.text = [jsonDict objectForKey:@"pickup_address"];
    self.destinationLabel.text = [jsonDict objectForKey:@"destination_address"];
    self.passengerNameLabel.text = [[jsonDict objectForKey:@"user"] objectForKey:@"name"];
    
    picupPoint = [[CLLocation alloc] initWithLatitude:[[jsonDict objectForKey:@"pickup_latitude"] floatValue] longitude:[[jsonDict objectForKey:@"pickup_longitude"] floatValue]];
    destinationPoint = [[CLLocation alloc] initWithLatitude:[[jsonDict objectForKey:@"destination_latitude"] floatValue] longitude:[[jsonDict objectForKey:@"destination_longitude"] floatValue]];
    
    
    [self drawpoliline:picupPoint destination:destinationPoint];
    
    rideId =[[jsonDict objectForKey:@"id"]intValue];
    
    [self showRideSuggestionView];
    
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
//        picupPoint = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
//        destinationPoint = [[CLLocation alloc] initWithLatitude:position.target.latitude longitude:position.target.longitude];
//        
//        
//        
//    }
//    
//}


- (IBAction)myLocationButtonAction:(id)sender {
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.latitude longitude:currentLocation.longitude zoom:16];
    
    [self.googleMapView animateToCameraPosition:camera];
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
    
    [[ServerManager sharedManager] patchAcceptRide:postData withCompletion:^(BOOL success){
        
        
        if (success) {
            
            NSLog(@"accept ride");
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 
                                 self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width, 0);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.rideSuggestionView.hidden = YES;
                                 [self showStartTripView];
                                 
                             }];
            
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
}

- (IBAction)cancelRideButtonAction:(id)sender {
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    
    [[ServerManager sharedManager] patchCancelRide:postData withCompletion:^(BOOL success){
        
        
        if (success) {
            
            NSLog(@"cancel ride");
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
    
}



-(void) showRideSuggestionView{

    
    
    self.rideSuggestionView.hidden = NO;
    self.rideSuggestionView.frame = CGRectMake(20,self.view.frame.size.height ,self.rideSuggestionView.frame.size.width,self.rideSuggestionView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.rideSuggestionView.frame = CGRectMake(20,(self.view.frame.size.height - self.rideSuggestionView.frame.size.height-49) ,self.rideSuggestionView.frame.size.width,self.rideSuggestionView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];


}

-(void) showStartTripView{
    
    self.pickupLabelInStartTripView.text = self.picupLabel.text;
    self.destinationLabelInStartTripView.text = self.destinationLabel.text;
    self.passengerNameLabelInStartTripView.text = self.passengerNameLabel.text;
    
    self.startTripView.hidden = NO;
    self.startTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.startTripView.frame.size.width,self.startTripView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.startTripView.frame = CGRectMake(20,(self.view.frame.size.height - self.startTripView.frame.size.height-49) ,self.startTripView.frame.size.width,self.startTripView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];
    
   
    NSLog(@"[UserAccount sharedManager].isOnRide %d",[UserAccount sharedManager].isOnRide);

    
}

- (IBAction)startTripButtonAction:(id)sender {
    
    [UserAccount sharedManager].isOnRide = 1;
    
   
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.latitude] forKey:@"latitude"];
    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.longitude] forKey:@"longitude"];
    //[dict setObject:@"start" forKey:@"start or stop"];
    
    self.locationShareModel.tripLocationArray = [[NSMutableArray alloc]init];
    
    [self.locationShareModel.tripLocationArray addObject:dict];
    
    
    
    //
    if (self.locationShareModel.timer) {
        
        [self.locationShareModel.timer invalidate];
        self.locationShareModel.timer = nil;
        NSLog(@"self.shareModel.timer in start trip  = nil");
    }
    
    if (self.locationUpdateTimer) {
        
        [self.locationUpdateTimer invalidate];
        self.locationUpdateTimer = nil;
        NSLog(@"self.locationUpdateTimer in finish trip  = nil");
    }
    
    self.locationTracker = [[LocationTracker alloc]init];
    
    NSLog(@"self.locationTracker in start trip");
    
    [self.locationTracker startLocationTracking];
    
    //Send the best location to server every 60 seconds
   
    NSTimeInterval time = 30.0;
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(updateLocationfromMap)
                                   userInfo:nil
                                    repeats:YES];
    
    

    
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    //[postData setObject:@"188" forKey:@"ride_id"];
    
    [[ServerManager sharedManager] patchStartRide:postData withCompletion:^(BOOL success){
        
        
        if (success) {
            
            NSLog(@"start ride");
            
            
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 
                                 self.startTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.startTripView.frame.size.width, 0);
                                 
                                 
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


    self.pickupLabelInFinishTripView.text = self.picupLabel.text;
    self.destinationLabelInFinishTripView.text = self.destinationLabel.text;
    self.passengerNameInFinishTripView.text = self.passengerNameLabel.text;
    
    self.finishTripView.hidden = NO;
    self.finishTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.finishTripView.frame.size.width,self.finishTripView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.finishTripView.frame = CGRectMake(20,(self.view.frame.size.height - self.finishTripView.frame.size.height-49) ,self.finishTripView.frame.size.width,self.finishTripView.frame.size.height);
                         
                         
                     }
     
                     completion:^(BOOL finished){
                         
                         
                     }];




}
- (IBAction)finishTripButtonAction:(id)sender {
    
    [UserAccount sharedManager].isOnRide = 0;
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.latitude] forKey:@"latitude"];
    [dict setObject:[NSString stringWithFormat:@"%f",currentLocation.longitude] forKey:@"longitude"];
   // [dict setObject:@"stop" forKey:@"start or stop"];
    
    [self.locationShareModel.tripLocationArray addObject:dict];
    
    NSLog(@"tripLocationArray  %@",self.locationShareModel.tripLocationArray);
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.locationShareModel.tripLocationArray options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (jsonData && !error)
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"location JSON: %@", jsonString);
    }
    

    
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
    
    

    
    
    
    NSMutableDictionary* postData=[[NSMutableDictionary alloc] init];
    
    [postData setObject:[NSString stringWithFormat:@"%d",rideId] forKey:@"ride_id"];
    //[postData setObject:@"188" forKey:@"ride_id"];
    [postData setObject:jsonString forKey:@"waypoints"];
    
    [[ServerManager sharedManager] patchFinishRide:postData withCompletion:^(BOOL success, NSMutableDictionary *responseObject){
        
        
        if (success) {
            
            NSLog(@"finish ride");
            
            NSLog(@"responseObject in finish ride %@",responseObject);
            
            self.passengerNameIncollectMoneyView.text  = self.passengerNameLabel.text;
            self.totalFareLabel.text = [NSString stringWithFormat:@"%@",[[[[responseObject objectForKey:@"data"]objectAtIndex:0]objectForKey:@"detail"]objectForKey:@"total_payable_fare"]];
            
             NSLog(@"total_payable_fare %@",[[[[responseObject objectForKey:@"data"]objectAtIndex:0]objectForKey:@"detail"]objectForKey:@"total_payable_fare"]);
            
            [UIView animateWithDuration:.5
                                  delay:0
                                options: UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 
                                 self.finishTripView.frame = CGRectMake(20,self.view.frame.size.height ,self.finishTripView.frame.size.width, 0);
                                 
                                 
                             }
                             completion:^(BOOL finished){
                                 
                                 
                                 self.finishTripView.hidden = YES;
                                 
                                 [self showCollectMoneyView];
                                 
                             }];
            
            
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
            });
        }
        
    }];
    
}

-(void)updateLocationfromMap {
    
    if ([UserAccount sharedManager].riderStatus == 2) {
    
        NSLog(@"ison ride  in map %d",[UserAccount sharedManager].isOnRide);
    
        NSLog(@"updateLocation in map");
    
    
       [self.locationTracker updateLocationToServer];
    
    }else{
    
    
        //invalidate locaton uptade timer
        
        if (self.locationUpdateTimer) {
            
            [self.locationUpdateTimer invalidate];
            self.locationUpdateTimer = nil;
            NSLog(@"self.locationUpdateTimer in updateLocationfromMap  = nil");
        }
    
    
    }
}


-(void)showCollectMoneyView{
    
    self.collectMoneyView.hidden = NO;
    self.collectMoneyView.frame = CGRectMake(20,self.view.frame.size.height ,self.collectMoneyView.frame.size.width,self.collectMoneyView.frame.size.height);
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
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
    
    
    
    totalRating =[NSString stringWithFormat:@"%.2f", rating];
    
    NSLog(@"RATING is :)%@",totalRating);
    
}

- (IBAction)collectMoneyButtonAction:(id)sender {
    
    [UIView animateWithDuration:.5
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         
                         self.collectMoneyView.frame = CGRectMake(20,self.view.frame.size.height ,self.collectMoneyView.frame.size.width, 0);
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                         self.collectMoneyView.hidden = YES;
                         
                         
                         
                     }];
    
}


- (IBAction)phoneButtonAction:(id)sender {
    
    
}

- (IBAction)messageButtonAction:(id)sender {
    
    
}



- (IBAction)backButtonAction:(id)sender {
    

    
}

- (IBAction)settingButtonAction:(id)sender {
    
//    SettingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
//    
//    [self.navigationController pushViewController:vc animated:YES];
    
}






@end
