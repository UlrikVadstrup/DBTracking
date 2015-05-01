//
//  FirstViewController.m
//  DBTracking
//
//  Created by Ulrik Vadstrup on 25/04/15.
//  Copyright (c) 2015 Ulrik Vadstrup. All rights reserved.
//

#import "TrackViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue]

@interface TrackViewController ()

@end

@implementation TrackViewController

@synthesize urlData;


- (void)viewDidLoad {
    bfirstview = false;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    bfirstZoom = false;
    bEstimateLanding = true;
    
    locationManager = [[CLLocationManager alloc] init];
    
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];

    
    [locationManager startUpdatingLocation];
    
    naviMap.showsUserLocation = YES;
    naviMap.showsPointsOfInterest = YES;
    
    intervalTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                     target:self
                                                   selector:@selector(updatePos:)
                                                   userInfo:nil
                                                    repeats:YES];
    flightPath = [[NSMutableArray alloc] init];
    
    bfirstview = true;
    
    [self zoomCar];
    [self updatePos:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    if (bfirstview) {
        [self updatePos:nil];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    appDelegate.userLocation = userLocation;
    if (!appDelegate.zoomBalloon && appDelegate.centerMap) {
        [self zoomCar];
    }
}

-(void)updatePos:(NSTimer *) theTimer{
    
    [self becomeFirstResponder];
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate: currentTime];
    
    //Get AM or PM
    [dateFormatter setDateFormat:@"HH"];
    NSString *hourString = [dateFormatter stringFromDate: currentTime];
    NSString *timeOfDay;
    if ([hourString doubleValue] >= 14)
        timeOfDay = @"PM";
    else
        timeOfDay = @"AM";
    
    //dateString = @"24-04-2015";
    //timeOfDay = @"PM";
    
    
    //self.lblDateForLogs.text = [NSString stringWithFormat:@"%@ %@", dateString, timeOfDay];
    
    NSString *logName = [appDelegate.logCaptain stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    NSString *baseURL = appDelegate.logURL;
    
    
    NSString *key;
    key = [NSString stringWithFormat:@"%@/qrypositions.php?LogDate=%@&TimeOfDay=%@&Log_Name=%@", baseURL, dateString, timeOfDay, logName];
    
    NSLog(@"URL : %@", key);
    
    NSURL *url = [NSURL URLWithString:key];
    
    NSLog(@"URL : %@", url);
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection *urlconn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSLog(@"urlconn : %@", urlconn);
    
    self.urlData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.urlData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (statusCode == 200) {
            NSLog(@"received successful (200) response ");
        } else {
            NSLog(@"whoops, something wrong, received status code of %ld", (long)statusCode);
        }
    } else {
        NSLog(@"Not a HTTP response");
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError *err = nil;
    id resultObject = [NSJSONSerialization JSONObjectWithData:urlData options:kNilOptions error:&err];
    
    if (!resultObject) {
        NSLog(@"Parsing failed - No data !!");
    }
    if ([resultObject isKindOfClass:[NSArray class]]) {
        NSLog(@"Parser returned an array!!");
    }
    if ([resultObject isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Parser returned a Dictionary!!");
    }
    
    NSArray *tempArray = [[NSArray alloc] initWithArray:resultObject];
    //NSLog(@"Array : %@", [tempArray description]);
    
    int commType;
    if (tempArray.count > 0)
        commType = [[[tempArray objectAtIndex:0] valueForKey:@"COMM"] intValue];
    else
        commType = 0;
    NSLog(@"Comm type = %d", commType);
    
    switch (commType) {
        case 0: // Nothing - delete flightpath
            [flightPath removeAllObjects];
            [self deletePositions];
            [self drawFlightPath];
            break;
        case 1: // Balloonroute !
            [flightPath removeAllObjects];
            if (tempArray.count > 0) {
                for (int i = 0 ; i <= tempArray.count -1 ; ++i){
                    Flightpositions *tmp = [[Flightpositions alloc]init];
                    tmp.strType = [[tempArray objectAtIndex:i] valueForKey:@"type"];
                    tmp.strTimeOfDay = [[tempArray objectAtIndex:i] valueForKey:@"TimeOfDay"];
                    tmp.strLogName = [[tempArray objectAtIndex:i] valueForKey:@"Log_Name"];
                    tmp.strLogDate = [[tempArray objectAtIndex:i] valueForKey:@"Log_Date"];
                    tmp.strLogTime = [[tempArray objectAtIndex:i] valueForKey:@"Log_Time"];
                    tmp.strLatitude = [[tempArray objectAtIndex:i] valueForKey:@"Latitude"];
                    tmp.strLongitude = [[tempArray objectAtIndex:i] valueForKey:@"Longitude"];
                    tmp.strHeight = [[tempArray objectAtIndex:i] valueForKey:@"Height"];
                    tmp.strSpeed = [[tempArray objectAtIndex:i] valueForKey:@"Speed"];
                    tmp.strCompass = [[tempArray objectAtIndex:i] valueForKey:@"Compass"];
                    tmp.strHeading = [[tempArray objectAtIndex:i] valueForKey:@"Heading"];
                    tmp.strBallonStatus = [[tempArray objectAtIndex:i] valueForKey:@"Balloon_Status"];
                    if (tmp) {
                        [flightPath addObject:tmp];
                    }
                }
                [self deletePositions];
                [self drawFlightPath];
                [self estimateLanding];
            }
            break;
        case 2: // Goals !
            break;
        default:
            break;
    }
    
    // Create route to balloon/landing if checked
    if (appDelegate.showroute) {
        [self showGPSRoute:nil];
    }
    else{
        for (id<MKOverlay> overlay in naviMap.overlays)
        {
            if ([overlay.title isEqualToString:@"GPSRoute"]) {
                [naviMap removeOverlay:overlay];
            }
        }
    }
    
}


-(void)estimateLanding{
    
    double radiusEarthKilometres = 6371.01;
    float kmDistance;
    
    
    for (id<MKOverlay> overlay in naviMap.overlays)
    {
        if ([overlay.title isEqualToString:@"EstimatedLanding"]) {
            [naviMap removeOverlay:overlay];
        }
    }
    
    if (bEstimateLanding) {
        
        Flightpositions *start = [flightPath objectAtIndex:0];
        Flightpositions *now = [flightPath objectAtIndex:flightPath.count-1];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *currentTime = [NSDate date];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *nowTime = [dateFormatter stringFromDate: currentTime];
        NSDate* secondTime = [dateFormatter dateFromString:nowTime];
        NSDate* firstTime = [dateFormatter dateFromString:start.strLogTime];
        NSTimeInterval timeDifference =  [secondTime timeIntervalSinceDate:firstTime];
        
        NSLog(@"timeDifference %f", timeDifference);
        
        //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        //NSString *flightTime = @"75";
        int iFlightTime = appDelegate.estimatedFlightTime;
        
        int valTime = floor((timeDifference / 60));
        
        if ((valTime > iFlightTime) || (isnan(timeDifference)))
            valTime = iFlightTime;
        
        if (valTime < 0)
            valTime = 0;
        
        int iCalculateTime = iFlightTime - valTime;
        //self.lblEstimatedLanding.text = [NSString stringWithFormat:@"Vis estimeret landing (%ld min.)", (long)iCalculateTime];
        
        //Calculate distanceforwared from speed.
        kmDistance = (([now.strSpeed doubleValue] * 3.6) / 60.0 * iCalculateTime);
        
        float distRatio = kmDistance / radiusEarthKilometres;
        float distRatioSine = sinf(distRatio);
        float distRatioCosine = cosf(distRatio);
        
        float startLatRad = [now.strLatitude doubleValue] * M_PI / 180;
        float startLonRad = [now.strLongitude doubleValue] * M_PI / 180;
        
        float startLatCos = cosf(startLatRad);
        float startLatSin = sinf(startLatRad);
        
        float angleRadHeading = [now.strCompass doubleValue] * (M_PI / 180);
        
        float endLatRads = asinf((startLatSin * distRatioCosine) + (startLatCos * distRatioSine * cosf(angleRadHeading)));
        float endLonRads = startLonRad + atan2f(sinf(angleRadHeading) * distRatioSine * startLatCos, distRatioCosine - startLatSin * sinf(endLatRads));
        
        estimatedLatitude = endLatRads * 180 / M_PI;
        estimatedLongitude = endLonRads * 180 / M_PI;
        
        CLLocationCoordinate2D coord[2];
        coord[0].latitude = [now.strLatitude doubleValue];
        coord[0].longitude = [now.strLongitude doubleValue];
        
        coord[1].latitude = estimatedLatitude;
        coord[1].longitude = estimatedLongitude;
        
        MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coord count:2];
        polyLine.title = @"EstimatedLanding";
        [naviMap addOverlay:polyLine];
    }
    else{
        //self.lblEstimatedLanding.text = @"Vis estimeret landing";
    }
    
}


-(void)drawFlightPath{
    //Draw flightpath
    for (id<MKOverlay> overlay in naviMap.overlays)
    {
        if ([overlay.title isEqualToString:@"Track"]) {
            [naviMap removeOverlay:overlay];
        }
    }
    
    if (flightPath.count > 2) {
        Flightpositions *fps = [[Flightpositions alloc] init];
        fps = [flightPath objectAtIndex:flightPath.count-1];
        [self markPositionWithLatitude:[fps.strLatitude doubleValue] andLongitude:[fps.strLongitude doubleValue] andTitle:fps.strLogTime andSubTitle:[NSString stringWithFormat:@"%@ m : %@ km/t", fps.strHeight, fps.strSpeed]];
    }
    
    if (flightPath.count > 2) {
        for (int i = 1; i < flightPath.count ; i++) {
            Flightpositions *fps1 = [[Flightpositions alloc] init];
            Flightpositions *fps2 = [[Flightpositions alloc] init];
            fps1 = flightPath[i-1];
            fps2 = flightPath[i];
            CLLocationCoordinate2D coord[2];
            coord[0].latitude = [fps1.strLatitude doubleValue];
            coord[0].longitude = [fps1.strLongitude doubleValue];
            coord[1].latitude = [fps2.strLatitude doubleValue];
            coord[1].longitude = [fps2.strLongitude doubleValue];
            
            MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coord count:2];
            polyLine.title = @"Track";
            [naviMap addOverlay:polyLine];
        }
        
        Flightpositions *fps = [[Flightpositions alloc] init];
        fps = flightPath[flightPath.count-1];
        
        //self.lblHeight.text = [NSString stringWithFormat:@"%@ m", fps.strHeight];
        //self.lblLogs.text = [NSString stringWithFormat:@"%lu", (unsigned long)flightPath.count];
        //self.lblName.text = [NSString stringWithFormat:@"%@", fps.strLogName];
        //self.lblSpeed.text = [NSString stringWithFormat:@"%@ km/t", fps.strSpeed];
        //self.lblTime.text = [NSString stringWithFormat:@"%@", fps.strLogTime];
        
        // Center map last position if update baloon
        if (appDelegate.zoomBalloon && appDelegate.centerMap) {
            [self zoomBalloon];
        }
    }
    
    //PLACE GOALS ANNOTATIONS
    //for (int i = 0; i < appDelegate.goalsArray.count ; i++) {
    //    GoalType *gt = [[GoalType alloc] init];
    //    gt = appDelegate.goalsArray[i];
    //    if (![gt.strTaskNr isEqualToString:@"0"])
    //        [self markPositionWithLatitude: gt.dLatitude andLongitude:gt.dLongitude andTitle:gt.strDescription andSubTitle:[NSString stringWithFormat:@"Task : %@",gt.strTaskNr]];
    //    else
    //        [self markPositionWithLatitude: gt.dLatitude andLongitude:gt.dLongitude andTitle:gt.strDescription andSubTitle:[NSString stringWithFormat:@""]];
    //}
    
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
    if (([overlay isKindOfClass:[MKPolyline class]]) && [overlay.title isEqualToString:@"Track"]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        routeRenderer.fillColor = [UIColor blueColor];
        routeRenderer.lineWidth = 2;
        return routeRenderer;
    }
    if (([overlay isKindOfClass:[MKPolyline class]]) && [overlay.title isEqualToString:@"GPSRoute"]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        routeRenderer.lineWidth = 5;
        return routeRenderer;
    }
    
    if (([overlay isKindOfClass:[MKPolyline class]]) && [overlay.title isEqualToString:@"EstimatedLanding"]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1.0];
        routeRenderer.lineWidth = 2;
        routeRenderer.lineDashPhase = 15;
        NSArray* array = [NSArray arrayWithObjects:[NSNumber numberWithInt:20], [NSNumber numberWithInt:5], nil];
        routeRenderer.lineDashPattern = array;
        return routeRenderer;
    }
    
    else return nil;
}


- (IBAction)showGPSRoute:(id)sender {
    
    if (flightPath.count > 0) {
        [self createRouteToBalloon];
    }
}

- (IBAction)chkShowLanding:(id)sender {
    if (!bEstimateLanding) {
        bEstimateLanding = true;
        [((UIButton *)sender) setImage:[UIImage imageNamed:@"checkBoxMarked.png"] forState:UIControlStateNormal];
    }
    else
    {
        bEstimateLanding = false;
        [((UIButton *)sender) setImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateNormal];
        for (id<MKOverlay> overlay in naviMap.overlays)
        {
            if ([overlay.title isEqualToString:@"EstimatedLanding"]) {
                [naviMap removeOverlay:overlay];
            }
        }
    }
}

-(void)zoomBalloon{
    if (flightPath.count > 0) {
        Flightpositions *fps = [[Flightpositions alloc] init];
        fps = flightPath[flightPath.count-1];
        CLLocationCoordinate2D coord[1];
        coord[0].latitude = [fps.strLatitude doubleValue];
        coord[0].longitude = [fps.strLongitude doubleValue];
        MKCoordinateRegion region;
        region.center = coord[0];
        if (!bfirstZoom) {
            MKCoordinateSpan span;
            span.latitudeDelta = 0.15;
            span.longitudeDelta = 0.15;
            region.span = span;
            bfirstZoom = true;
        }
        else
        {
            MKCoordinateSpan oldSpan = naviMap.region.span;
            region.span = oldSpan;
            
        }
        region = [naviMap regionThatFits:region];
        [naviMap setRegion:region animated:YES];
    }
}

-(void)zoomCar{
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = naviMap.userLocation.coordinate;
    if (!bfirstZoom) {
        mapRegion.span.latitudeDelta = 0.15;
        mapRegion.span.longitudeDelta = 0.15;
        bfirstZoom = true;
    }
    else{
        MKCoordinateSpan oldSpan = naviMap.region.span;
        mapRegion.span = oldSpan;
    }
    [naviMap setRegion:mapRegion animated: YES];
}

-(void)createRouteToBalloon{
    
    
    for (id<MKOverlay> overlay in naviMap.overlays)
    {
        if ([overlay.title isEqualToString:@"GPSRoute"]) {
            [naviMap removeOverlay:overlay];
        }
    }
    
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:(naviMap.userLocation.coordinate) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@"Car"];
    
    Flightpositions *fps = [[Flightpositions alloc] init];
    fps = flightPath[flightPath.count-1];
    
    double destLatitude;
    double destLongitude;
    
    if (bEstimateLanding) {
        destLatitude = estimatedLatitude;
        destLongitude = estimatedLongitude;
        
    }
    else{
        destLatitude = [fps.strLatitude doubleValue];
        destLongitude = [fps.strLongitude doubleValue];
    }
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:CLLocationCoordinate2DMake(destLatitude, destLongitude) addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil]];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@"Balloon"];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            line.title = @"GPSRoute";
            [naviMap addOverlay:line];
            NSLog(@"Rout Name : %@",rout.name);
            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
            
            NSArray *steps = [rout steps];
            
            NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
            
            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@"Rout Instruction : %@",[obj instructions]);
                NSLog(@"Rout Distance : %f",[obj distance]);
            }];
        }];
    }];
}

-(void)markPositionWithLatitude:(double)latitude andLongitude:(double)longitude andTitle:(NSString*) title andSubTitle:(NSString *)subtitle{
    
    
    CLLocationCoordinate2D annotationCoord;
    
    annotationCoord.latitude = latitude;
    annotationCoord.longitude = longitude;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title = title;
    annotationPoint.subtitle = subtitle;
    [naviMap addAnnotation:annotationPoint];
}

-(void)deletePositions{
    NSMutableArray * annotationsToRemove = [ naviMap.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:naviMap.userLocation ] ;
    [ naviMap removeAnnotations:annotationsToRemove ] ;
}



-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = nil;
    if(annotation != naviMap.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKAnnotationView *)[naviMap dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil )
            pinView = [[MKAnnotationView alloc]
                       initWithAnnotation:annotation reuseIdentifier:defaultPinID];
        
        //pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        //pinView.animatesDrop = YES;
        pinView.image = [UIImage imageNamed:@"balloonAnnotatioSmall.png"];    //as suggested by Squatch
    }
    return pinView;
}


@end
