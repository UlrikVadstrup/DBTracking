//
//  SecondViewController.m
//  DBTracking
//
//  Created by Ulrik Vadstrup on 25/04/15.
//  Copyright (c) 2015 Ulrik Vadstrup. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize pilotSelector;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    pilots = @[@"Bartek", @"Philip"];
    
    [pilotSelector reloadAllComponents];
    [pilotSelector selectRow:appDelegate.logCaptainIndex inComponent:0 animated:YES];
    
    [self.swCenterBalloon setOn:appDelegate.zoomBalloon];
    [self.swCenterBalloon setEnabled:appDelegate.centerMap];
    [self.swCenterMap setOn:appDelegate.centerMap];
    [self.swShowRouteOnOff setOn:appDelegate.showroute];
    self.edtTime.text = [NSString stringWithFormat:@"%d", appDelegate.estimatedFlightTime];
    self.stpTime.value = appDelegate.estimatedFlightTime;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// The number of columns of data
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)pilots.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pilots[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    appDelegate.logCaptain = [pilots objectAtIndex:row];
    appDelegate.logCaptainIndex = row;
}

- (IBAction)centerMapOnOff:(UISwitch *)sender {
    appDelegate.centerMap = sender.on;
    [self.swCenterBalloon setEnabled:sender.on];
}
- (IBAction)centerBalloonOnOff:(UISwitch *)sender {
    appDelegate.zoomBalloon = sender.on;
}

- (IBAction)showRouteOnOff:(UISwitch *)sender {
    appDelegate.showroute = sender.on;
}

- (IBAction)stepperchanged:(UIStepper *)sender {
    appDelegate.estimatedFlightTime = sender.value;
    self.edtTime.text = [NSString stringWithFormat:@"%d", appDelegate.estimatedFlightTime];
}

@end
