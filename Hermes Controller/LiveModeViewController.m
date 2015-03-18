//
//  LiveModeViewController.m
//  HermesController
//
//  Created by Justin Raine on 2015-03-08.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "LiveModeViewController.h"
#import "MBProgressHUD.h"
#import "Constants.h"
//#import "BluetoothInterface.h"
#import "HermesControllerManager.h"
#import "BLEInterface.h"

NS_ENUM(NSInteger, alertTag) {
    kHermesControllerFoundTag,
    kConnectionFailedTag,
    kTimeoutTag
};

@interface LiveModeViewController ()

@property (weak, nonatomic) IBOutlet UISlider *maxSpeedSlider;
@property (weak, nonatomic) IBOutlet UISlider *dampingSlider;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedDisplayValue;
@property (weak, nonatomic) IBOutlet UILabel *dampingDisplayValue;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) NSMutableArray *ignoredHermesControllers; // List of controllers skipped during auto-connect
@property (strong, nonatomic) CBPeripheral *potentialHermesController;
//@property BOOL isRecording;
@property MBProgressHUD *HUD;

@end


@implementation LiveModeViewController

#pragma mark - Utility Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ignoredHermesControllers = [NSMutableArray array];
    self.HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.HUD];
    
    // Setup KVO notifications from HermesControllerManager
    [[HermesControllerManager sharedInstance] addObserver:self
                                               forKeyPath:@"status"
                                                  options:0
                                                  context:nil];
    [[HermesControllerManager sharedInstance] addObserver:self
                                               forKeyPath:@"discoveredHermesControllers"
                                                  options:0 //*** what about comparing old vs new values for differences instead of using ignoredHermesControllers?
                                                  context:nil];
    
    [[HermesControllerManager sharedInstance] scanForHermesController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UI Actions

- (IBAction)maxSpeedDidChange:(id)sender {
    self.maxSpeedDisplayValue.text = [NSString stringWithFormat:@"%.f%%", self.maxSpeedSlider.value*100];
}


- (IBAction)dampingDidChange:(id)sender {
    self.dampingDisplayValue.text = [NSString stringWithFormat:@"%.f%%", self.dampingSlider.value*100];
}


- (IBAction)buttonTapped:(id)sender {
    if (sender == self.recordButton) {
        if ([self.recordButton.titleLabel.text isEqualToString:@"Record"]) {
            NSLog(@"Record button tapped -- Send command to Arduino to begin recording");
            
            [self.recordButton setTitle:@"Stop" forState:UIControlStateNormal];
            self.recordButton.backgroundColor = [UIColor colorWithRed:193.0/255.0 green:5.0/255.0 blue:46.0/255.0 alpha:1];
            //self.isRecording = YES;
            
            [[HermesControllerManager sharedInstance] beginRecording];
        } else if ([self.recordButton.titleLabel.text isEqualToString:@"Stop"]) {
            NSLog(@"Stop button tapped -- Send command to Arduino to stop recording");
            
            [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
            self.recordButton.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            //self.isRecording = NO;
            
            [[HermesControllerManager sharedInstance] stopRecording];
        }
    } else if (sender == self.leftButton) {
        NSLog(@"Left button tapped -- Send command to Arduino to move left");
        
    } else if (sender == self.rightButton) {
        NSLog(@"Right button tapped -- Send command to Arduino to move right");
        
    } else {
        NSLog(@"Error: Unknown sender to buttonTapped IBAction");
    }
}



#pragma mark - KVO handler

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        [self handleUpdatedStatus:[HermesControllerManager sharedInstance].status];
    }
    else if([keyPath isEqualToString:@"discoveredHermesControllers"]) {
        [self handleUpdatedHermesControllerArray];
    }
}

- (void)handleUpdatedStatus:(ControllerStatus)updatedStatus {
    if (updatedStatus == kScanning) {
        self.HUD.labelText = @"Scanning...";
        [self.HUD show:YES];
    } else if (updatedStatus == kConnecting) {
        self.HUD.labelText = @"Connecting...";
        [self.HUD show:YES];
    } else if (updatedStatus == kConnectionFailed) {
        [self.HUD hide:YES];
        
        UIAlertView *connectionFailedAlert = [[UIAlertView alloc]
                                              initWithTitle:@"Connection Failed"
                                              message:@"Unable to connect to Hermes Controller"
                                              delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Try again", nil];
        connectionFailedAlert.tag = kConnectionFailedTag;
        
        [connectionFailedAlert show];
    } else if (updatedStatus == kConnected) {
        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        self.HUD.mode = MBProgressHUDModeCustomView;
        
        self.HUD.labelText = @"Connected!";
        self.HUD.userInteractionEnabled = NO;
        
        [self.HUD show:YES];
        
        // Wait 1 second
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
        });
        
//        [self.HUD hide:YES];
//        UIAlertView *alert = [[UIAlertView alloc]
//                                     initWithTitle:@"Connection Success!"
//                                     message:nil
//                                     delegate:self
//                                     cancelButtonTitle:nil
//                                     otherButtonTitles:@"Try again", nil];
//        [alert show];
 
        
        //*************************** probably causes deadlock! ************************************
        
//        // UIImageView is a UIKit class, we have to initialize it on the main thread
//        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
//        self.HUD.mode = MBProgressHUDModeCustomView;
//        
//        self.HUD.labelText = @"Connected!";
//        self.HUD.userInteractionEnabled = NO;
//        
//        [self.HUD show:YES];
//        [self.HUD hide:YES afterDelay:1.5f];
//        
//        
//        __block UIImageView *imageView;
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
//            imageView = [[UIImageView alloc] initWithImage:image];
//        });
//        self.HUD.customView = imageView;
//        self.HUD.mode = MBProgressHUDModeCustomView;
//        self.HUD.labelText = @"Completed";
//        sleep(1);
//        [self.HUD hide:YES];
        
        //**********
        
    } else if (updatedStatus == kDisconnected) {
        
    } else if (updatedStatus == kTimeout) {
        [self.HUD hide:YES];
        
        UIAlertView *timeoutAlert = [[UIAlertView alloc]
                                               initWithTitle:@"Device Not Found"
                                               message:@"Please ensure your Hermes Controller is on and within range"
                                               delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"Try again", nil];
        timeoutAlert.tag = kTimeoutTag;
        [timeoutAlert show];
        
    } else if (updatedStatus == kIdle) {
        
    } else if (updatedStatus == kBluetoothNotPoweredOn) {
        // Alert user the command failed -> bluetooth is not powered on
    }
}

         
- (void)handleUpdatedHermesControllerArray {
    // hermesControllerArray is an array of dictionaries, one for each discovered CBPeripheral
    // Each dictionary contains all received scan properties with keys: peripheral, advertisementData, RSSI
    NSArray *hermesControllerArray = [HermesControllerManager sharedInstance].discoveredHermesControllers;
    
    for (id hermesController in hermesControllerArray) {
        CBPeripheral *discoveredController = [hermesController objectForKey:@"peripheral"];
        
        if (![self.ignoredHermesControllers containsObject:discoveredController]) {
            NSString *message = [NSString stringWithFormat:@"Connect to %@?", discoveredController.name];
            UIAlertView *hermesControllerFoundAlert = [[UIAlertView alloc]
                                                       initWithTitle:@"Hermes Controller Found"
                                                       message:message
                                                       delegate:self
                                                       cancelButtonTitle:@"No"
                                                       otherButtonTitles:@"Yes", nil];
            hermesControllerFoundAlert.tag = kHermesControllerFoundTag;
            
            self.potentialHermesController = discoveredController;
            
            if ([HermesControllerManager sharedInstance].status == kScanning) {
                [[HermesControllerManager sharedInstance] endScanForHermesController]; // stop scan during UI interaction
                [self.HUD hide:YES];
            }
            
            [hermesControllerFoundAlert show];
        }
    }
}

#pragma mark - Other Methods

// Alert response handler function
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kTimeoutTag) {
        [[HermesControllerManager sharedInstance] scanForHermesController];
    }
    else if (alertView.tag == kHermesControllerFoundTag) {
        if (buttonIndex==alertView.cancelButtonIndex) {
            [self.ignoredHermesControllers addObject:self.potentialHermesController];
            self.potentialHermesController = nil;
            
            [[HermesControllerManager sharedInstance] scanForHermesController]; // continue scanning
            [self.HUD show:YES]; // Show scanning HUD again
        } else {
            [[HermesControllerManager sharedInstance] connectToHermesController:self.potentialHermesController];
        }
    }
    else if (alertView.tag == kConnectionFailedTag) {
        [[HermesControllerManager sharedInstance] connectToHermesController:self.potentialHermesController];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end