//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"
#import "UserAccount.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"
#import <GoogleMaps/GoogleMaps.h>
#import "ServerManager.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
			_locationManager.allowsBackgroundLocationUpdates = YES;
			_locationManager.pausesLocationUpdatesAutomatically = NO;
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        
        
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        
        //self.isStopUpdateLocation = 0;
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    
    NSLog(@"startLocationTracking");

//    if ([CLLocationManager locationServicesEnabled] == NO) {
//        NSLog(@"locationServicesEnabled false");
//        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [servicesDisabledAlert show];
//    } else {
//        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
//
//        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
//            NSLog(@"authorizationStatus failed");
//        } else {
    
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
              [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
//        }
//    }
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

- (void)startMonitoringSignificantLocation {
    NSLog(@"startMonitoringSignificantLocation");
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    
    if (locationManager)
        [locationManager stopMonitoringSignificantLocationChanges];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopMonitoringSignificantLocation {
    NSLog(@"stopMonitoringSignificantLocation");
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    
    if (locationManager)
        [locationManager stopMonitoringSignificantLocationChanges];
}



#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            self.myLastLocation = theLocation;
            
            self.myLastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
            
            
        }
    }
    

    

    
    if ([UserAccount sharedManager].riderStatus == 2) {
        
        //If the timer still valid, return it (Will not run the code below)
        if (self.shareModel.timer) {
            return;
        }
        
        self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
        [self.shareModel.bgTask beginNewBackgroundTask];
        
         //Restart the locationMaanger after xx minute
        
//        if ([UserAccount sharedManager].isOnRide == 1) {
//
//            NSLog(@"timer for 30 sec");
//            self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self
//                                                                   selector:@selector(restartLocationUpdates)
//                                                                   userInfo:nil
//                                                                    repeats:NO];
//        }else{
//
//            NSLog(@"timer for 5 min ");
//
//           self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60*5 target:self
//                                                               selector:@selector(restartLocationUpdates)
//                                                               userInfo:nil
//                                                                repeats:NO];
//        }
        
        //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
        //The location manager will only operate for 10 seconds to save battery
        if (self.shareModel.delay10Seconds) {
            [self.shareModel.delay10Seconds invalidate];
            self.shareModel.delay10Seconds = nil;
            NSLog(@"self.shareModel.delay10Seconds = nil");
        }
        
        self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:5 target:self
                                                                        selector:@selector(stopLocationDelayBy10Seconds)
                                                                        userInfo:nil
                                                                         repeats:NO];
        
    }else{
    
        CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
        [locationManager stopUpdatingLocation];
    
    }


}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 5 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}


//Send the location to Server
- (void)updateLocationToServer {
    
   
        
        NSLog(@"updateLocationToServer");
        
        // Find the best location from the array based on accuracy
        NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
        
        for(int i=0;i<self.shareModel.myLocationArray.count;i++){
            
            NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
            
            if(i==0)
                
                myBestLocation = currentLocation;
            
            else{
                
                if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
                    
                    myBestLocation = currentLocation;
                    
                }
            }
        }
        NSLog(@"My Best location:%@",myBestLocation);
        
        //If the array is 0, get the last location
        //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
        if(self.shareModel.myLocationArray.count==0)
        {
            NSLog(@"Unable to get location, use the last known location");
            
            self.myLocation=self.myLastLocation;
            self.myLocationAccuracy=self.myLastLocationAccuracy;
            
        }else{
            CLLocationCoordinate2D theBestLocation;
            theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
            theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
            self.myLocation=theBestLocation;
            self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
        }
    
    
        //add locations in trip location array
    
          self.shareModel.tripLocationDictionary = [[NSMutableDictionary alloc]init];

          [self.shareModel.tripLocationDictionary setObject:[NSString stringWithFormat:@"%f",self.myLocation.latitude] forKey:@"latitude"];
          [self.shareModel.tripLocationDictionary setObject:[NSString stringWithFormat:@"%f",self.myLocation.longitude] forKey:@"longitude"];
    
    
        NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
    
    
    if ([UserAccount sharedManager].isOnRide == 0) {
    
        // send driver current locaton to server when not riding
        
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(self.myLocation.latitude,self.myLocation.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
            
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
    else
    {
        
        [self saveLocationsToPlist];
        
    }
        
    
    
        //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager

        [self.shareModel.myLocationArray removeAllObjects];
        self.shareModel.myLocationArray = nil;
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];

      //  NSLog(@"tripLocationArray  %@",self.shareModel.tripLocationArray);

        
 //   }
}

- (void)saveLocationsToPlist {
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile) {
        savedProfile = [[NSMutableDictionary alloc] init];
        self.shareModel.tripLocationArray = [[NSMutableArray alloc]init];
    } else {
        self.shareModel.tripLocationArray  = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(self.shareModel.tripLocationDictionary) {

        [self.shareModel.tripLocationDictionary setObject:[self appState] forKey:@"AppState"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/mm hh:mm:ss";
        
        NSString *theDate = [dateFormatter stringFromDate:[NSDate date]];
        
        
        [self.shareModel.tripLocationDictionary setObject:theDate forKey:@"Time"];
        
        [self.shareModel.tripLocationArray  addObject:self.shareModel.tripLocationDictionary];
        [savedProfile setObject:self.shareModel.tripLocationArray forKey:@"LocationArray"];
        [savedProfile setObject:[NSNumber numberWithBool:[UserAccount sharedManager].isOnRide] forKey:@"RideStatus"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE]) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
    
    NSLog(@"plist savedProfile %@",savedProfile);
}

-(void)removePlistData
{
    NSLog(@"removePlistData");
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error])
    {
        //TODO: Handle/Log error
    }
}

-(NSMutableDictionary*)loadPlistData
{
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile) {
        return nil;
    } else {
        return savedProfile;
    }
    
}
- (NSString *)appState {
    UIApplication* application = [UIApplication sharedApplication];
    
    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    return appState;
}



@end
