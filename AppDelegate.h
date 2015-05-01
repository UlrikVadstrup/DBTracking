//
//  AppDelegate.h
//  DBTracking
//
//  Created by Ulrik Vadstrup on 25/04/15.
//  Copyright (c) 2015 Ulrik Vadstrup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSMutableArray *goalsArray;
    MKUserLocation *userLocation;
}

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) MKUserLocation *userLocation;
@property (strong, nonatomic) NSString *logCaptain;
@property (nonatomic) NSInteger logCaptainIndex;
@property (nonatomic) int estimatedFlightTime;
@property (nonatomic) bool centerMap;
@property (nonatomic) bool zoomBalloon;
@property (nonatomic) bool showroute;

@property (strong, nonatomic) NSString *logURL;


@end

