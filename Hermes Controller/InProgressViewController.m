//
//  InProgressViewController.m
//  HermesControllerApp
//
//  Created by Wes Anderson on 2015-04-05.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "InProgressViewController.h"
#import "VMHHermesControllerManager.h"
#import "AppDelegate.h"

@interface InProgressViewController ()

@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressPercentLabel;
@property (nonatomic, strong) NSNumber *progressValue;

@end


@implementation InProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isTimeLapseMode]) {
        self.statusLabel.text = @"Time Lapse in Progress";
    } else {
        self.statusLabel.text = @"Stop Motion in Progress";
    }
    self.progressValue = @0;
    self.progressPercentLabel.text = @"0%";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(progressUpdated:)
                                                 name:kReceivedUpdatedProgressNotification
                                               object:[VMHHermesControllerManager sharedInstance]];
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


- (void)progressUpdated:(NSNotification *)notification {
    self.progressValue = [[notification userInfo] objectForKey:kProgressKey];
    self.progressPercentLabel.text = [NSString stringWithFormat:@"%@%%", self.progressValue];
    
    if ([self.progressValue intValue] >= 100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
