//
//  ServerManager.h
//  ArteVue
//
//  Created by Tanvir Palash on 1/4/17.
//  Copyright © 2016 Tanvir Palash. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ServerManager : NSObject

@property (nonatomic, readwrite) BOOL isNetworkAvailable;

+ (ServerManager *)sharedManager;

- (BOOL)checkForNetworkAvailability;

typedef void (^api_Completion_Handler_Status)(BOOL success);
typedef void (^api_Completion_Handler_Data)(BOOL success, NSMutableDictionary *resultDataDictionary);
typedef void (^api_Completion_Handler_Status_String)(BOOL success, NSString* resultString);



//User SignUp/Login

- (void)postLoginWithPhone:(NSString*)phone accessToken:(NSString*)accesstoken  completion:(api_Completion_Handler_Status)completion;

//change profile picture

- (void)postProfilePicture:(UIImage*)image completion:(api_Completion_Handler_Status)completion;

//get current user info
- (void)getUserInfoWithCompletion:(api_Completion_Handler_Data)completion;

//get rider status
- (void)getRiderStatusWithCompletion:(api_Completion_Handler_Status)completion;

//update userInfo

-(void) updateUserDetailsWithData:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//update rider status
-(void)patchRiderStatus:(NSString*)status withCompletion:(api_Completion_Handler_Status)completion;

//update rider location
-(void)patchRiderLocation:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//accept ride
-(void)patchAcceptRide:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//cancel ride
-(void)patchCancelRide:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//start ride
-(void)patchStartRide:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Status)completion;

//finish ride
-(void)patchFinishRide:(NSDictionary*)dataDic withCompletion:(api_Completion_Handler_Data)completion;


@end