//
//  FirstViewController.h
//  DBTracking
//
//  Created by Ulrik Vadstrup on 25/04/15.
//  Copyright (c) 2015 Ulrik Vadstrup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "Flightpositions.h"


@interface TrackViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate>{
    
    NSTimer *intervalTimer;
    NSMutableData *urlData;
    NSMutableArray *flightPath;
    double estimatedLatitude;
    double estimatedLongitude;
    CLLocationManager *locationManager;
    
    IBOutlet MKMapView *naviMap;
    
    
    AppDelegate *appDelegate;
    
    bool bfirstZoom;
    bool bEstimateLanding;
    bool bfirstview;
    
}

@property (nonatomic, retain) NSMutableData *urlData;

@end

