//
//  Flightpositions.h
//  BalloonFollow
//
//  Created by Ulrik Vadstrup on 28/07/14.
//  Copyright (c) 2014 Ulrik Vadstrup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flightpositions : NSObject{
    
    NSString *strType;
    NSString *strTimeOfDay;
    NSString *strLogName;
    NSString *strLogDate;
    NSString *strLogTime;
    NSString *strLatitude;
    NSString *strLongitude;
    NSString *strHeight;
    NSString *strSpeed;
    NSString *strCompass;
    NSString *strHeading;
    NSString *strBallonStatus;

    
}

@property (strong, nonatomic) NSString *strType;
@property (strong, nonatomic) NSString *strTimeOfDay;
@property (strong, nonatomic) NSString *strLogName;
@property (strong, nonatomic) NSString *strLogDate;
@property (strong, nonatomic) NSString *strLogTime;
@property (strong, nonatomic) NSString *strLatitude;
@property (strong, nonatomic) NSString *strLongitude;
@property (strong, nonatomic) NSString *strHeight;
@property (strong, nonatomic) NSString *strSpeed;
@property (strong, nonatomic) NSString *strCompass;
@property (strong, nonatomic) NSString *strHeading;
@property (strong, nonatomic) NSString *strBallonStatus;

@end
