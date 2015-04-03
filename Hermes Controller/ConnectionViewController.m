//
//  ConnectionViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-04-02.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "ConnectionViewController.h"
#import "HelpViewController.h"
#import "VMHHermesControllerManager.h"
#import "AppDelegate.h"

@interface ConnectionViewController ()

@end

@implementation ConnectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectButton:(id)sender {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] showBasicHUD];
    [[VMHHermesControllerManager sharedInstance] connectToNearbyHermesController];
}

- (IBAction)helpButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HelpViewController *helpViewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpView"];
    [self.navigationController pushViewController:helpViewController animated:YES];
}

@end
