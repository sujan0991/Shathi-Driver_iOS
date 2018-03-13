//
//  AppDelegate.h
//  Oye Driver
//
//  Created by Sujan on 7/3/17.
//  Copyright © 2017 Sujan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTracker.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property LocationTracker * locationTracker;
@property (nonatomic) NSTimer* locationUpdateTimer;
@property LocationShareModel * locationShareModel;

//-(void) askForNotificationPermission;

@end

