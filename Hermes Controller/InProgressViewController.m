//
//  InProgressViewController.m
//  HermesControllerApp
//
//  Created by Wes Anderson on 2015-04-05.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "InProgressViewController.h"
#import "VMHHermesControllerManager.h"

@interface InProgressViewController ()

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end


@implementation InProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self isTimeLapseMode]) {
        self.progressLabel.text = @"Time Lapse in Progress";
    } else {
        self.progressLabel.text = @"Stop Motion in Progress";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)stopButton:(id)sender {
    if ([self isTimeLapseMode]) {
        [[VMHHermesControllerManager sharedInstance] endTimeLapse];
    } else {
        [[VMHHermesControllerManager sharedInstance] endStopMotion];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isTimeLapseMode {
    return _timeLapseMode;
}

@end
