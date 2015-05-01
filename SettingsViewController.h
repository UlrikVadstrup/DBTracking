//
//  SecondViewController.h
//  DBTracking
//
//  Created by Ulrik Vadstrup on 25/04/15.
//  Copyright (c) 2015 Ulrik Vadstrup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsViewController : UIViewController{
    NSArray *pilots;
    AppDelegate *appDelegate;
}

@property (weak, nonatomic) IBOutlet UIPickerView *pilotSelector;
@property (weak, nonatomic) IBOutlet UISwitch *swCenterMap;
@property (weak, nonatomic) IBOutlet UISwitch *swCenterBalloon;
@property (weak, nonatomic) IBOutlet UISwitch *swShowRouteOnOff;
@property (weak, nonatomic) IBOutlet UITextField *edtTime;
@property (weak, nonatomic) IBOutlet UIStepper *stpTime;


- (IBAction)centerMapOnOff:(UISwitch *)sender;
- (IBAction)centerBalloonOnOff:(UISwitch *)sender;
- (IBAction)showRouteOnOff:(UISwitch *)sender;
- (IBAction)stepperchanged:(UIStepper *)sender;




@end

