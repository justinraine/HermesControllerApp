//
//  LiveModeViewController.m
//  HermesController
//
//  Created by Justin Raine on 2015-03-08.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "LiveModeViewController.h"
#import "DeviceUnsupportedViewController.h"
#import "VMHHermesControllerManager.h"
#import "VMHPacket.h"
#import "Constants.h"

@interface LiveModeViewController ()

@property (nonatomic, weak) IBOutlet UISlider *maxSpeedSlider;
@property (nonatomic, weak) IBOutlet UISlider *dampingSlider;
@property (nonatomic, weak) IBOutlet UILabel *maxSpeedDisplayValue;
@property (nonatomic, weak) IBOutlet UILabel *dampingDisplayValue;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, getter=isRecording) BOOL recording;

@end


@implementation LiveModeViewController

int kMaxRPM1 = 230;

#pragma mark - Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.recording = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UI Actions

- (IBAction)maxSpeedDidChange:(id)sender {
    self.maxSpeedDisplayValue.text = [NSString stringWithFormat:@"%.f%%", self.maxSpeedSlider.value*100];
}


- (IBAction)dampingDidChange:(id)sender {
    self.dampingDisplayValue.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
}


- (IBAction)recordButton:(id)sender {
    if ([self isRecording]) {
        NSLog(@"Stop button tapped -- Send command to Arduino to stop recording");
        
        // Update button properties
        [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
        self.recordButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        self.recording = NO;
        
        [[VMHHermesControllerManager sharedInstance] endRecording];
    } else {
        NSLog(@"Record button tapped -- Send command to Arduino to begin recording");
        
        // Update button properties
        [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.recordButton.backgroundColor = [UIColor colorWithRed:193.0/255.0 green:5.0/255.0 blue:46.0/255.0 alpha:1];
        self.recording = YES;
        
        [[VMHHermesControllerManager sharedInstance] beginRecording];
    }
}


- (IBAction)startLeftMovement:(id)sender {
    NSLog(@"Left button pressed -- Send command to Arduino to begin moving left");
    //[[VMHHermesControllerManager sharedInstance] beginMovementLeft];
    [[VMHHermesControllerManager sharedInstance] beginMovementLeftWithMaxSpeedPercent:roundf(self.maxSpeedSlider.value*100)
                                                                       dampingPercent:roundf(self.dampingSlider.value*100)];
}


- (IBAction)startRightMovement:(id)sender {
    NSLog(@"Right button pressed -- Send command to Arduino to begin moving right");
    //[[VMHHermesControllerManager sharedInstance] beginMovementRight];
    [[VMHHermesControllerManager sharedInstance] beginMovementRightWithMaxSpeedPercent:roundf(self.maxSpeedSlider.value*100)
                                                                        dampingPercent:roundf(self.dampingSlider.value*100)];
}


- (IBAction)endMovement:(id)sender {
    if (sender == self.leftButton) {
        NSLog(@"Left button depressed -- Send command to Arduino to stop moving left");
    } else {
        NSLog(@"Right button depressed -- Send command to Arduino to stop moving right");
    }
    [[VMHHermesControllerManager sharedInstance] endMovement];
}



#pragma mark - Getter Methods

- (BOOL)isRecording {
    return _recording;
}

@end