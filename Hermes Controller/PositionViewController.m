//
//  PositionViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-16.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "PositionViewController.h"
#import "VMHHermesControllerManager.h"
#import "AppDelegate.h"

NSString *const kPositionUpdateNotification = @"positionUpdateNotification";
NSString *const kPositionStepsKey = @"positionStepsKey";
NSString *const kSetStartPositionKey = @"setStartPositionKey";

typedef void(^myCompletion)(BOOL);

@interface PositionViewController ()

@property (nonatomic, weak) IBOutlet UILabel *message;
@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;
@property (nonatomic, strong) NSNumber *currentPositionSteps;

@end


@implementation PositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self isSetStartPosition]) {
        self.message.text =  @"Move the camera to the desired start position and press Set.";
    } else {
        self.message.text =  @"Move the camera to the desired end position and press Set.";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionUpdated:)
                                                 name:kReceivedUpdatedPositionNotification
                                               object:[VMHHermesControllerManager sharedInstance]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setPosition:(id)sender {
    NSLog(@"Set button pressed -- Send command to Arduino requesting current step location");
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] showBasicHUD];
    [[VMHHermesControllerManager sharedInstance] setPosition];
}

- (IBAction)startLeftMovement:(id)sender {
    NSLog(@"Left button pressed -- Send command to Arduino to begin moving left");
    [[VMHHermesControllerManager sharedInstance] beginMovementLeft];
}


- (IBAction)startRightMovement:(id)sender {
    NSLog(@"Right button pressed -- Send command to Arduino to begin moving right");
    [[VMHHermesControllerManager sharedInstance] beginMovementRight];
}


- (IBAction)endMovement:(id)sender {
    if (sender == self.leftButton) {
        NSLog(@"Left button depressed -- Send command to Arduino to stop moving left");
    } else {
        NSLog(@"Right button depressed -- Send command to Arduino to stop moving right");
    }
    [[VMHHermesControllerManager sharedInstance] endMovement];
}



#pragma mark - Private Methods

- (void)positionUpdated:(NSNotification *)notification {
    self.currentPositionSteps = [[notification userInfo] objectForKey:kPositionKey];
    
    // Send updated position to either TimeLapseViewController or StopMotionViewController depending on who is currently observing
    NSDictionary *userInfo = @{kPositionStepsKey    : self.currentPositionSteps,
                               kSetStartPositionKey : [NSNumber numberWithBool:self.setStartPosition]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPositionUpdateNotification object:self userInfo:userInfo];
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] hideHUD];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
