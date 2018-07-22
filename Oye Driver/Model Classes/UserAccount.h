//
//  Recipe.h
//  RecipeApp
//
//  Created by Simon on 25/12/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SynthesizeSingleton.h"


@interface UserAccount : NSObject

@property (nonatomic) int userId;


@property (nonatomic,strong) NSString *name;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic, strong) NSString *email;

@property (nonatomic,strong) NSString *userTypeId;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic) int riderStatus;
@property (nonatomic) int riderIsApproved;
@property (nonatomic) int riderIsBlocked;

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *gcmRegKey;

@property (nonatomic) float commissionRate;
@property (nonatomic) int missedRide;
@property (nonatomic) float rating;
@property (nonatomic) float due;

@property int isOnRide;
@property (nonatomic) int rideId;

+ (UserAccount *)sharedManager;

@end
