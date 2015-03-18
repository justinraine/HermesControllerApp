//
//  PositionViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-16.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "PositionViewController.h"

@interface PositionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *message;


@end

@implementation PositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.customMessage != nil) {
        self.message.text = self.customMessage;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setPosition:(id)sender {
    NSLog(@"Position set ** Not Impemented **");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)moveLeft:(id)sender {
    NSLog(@"Move left command sent ** Not Impemented **");
}

- (IBAction)moveRight:(id)sender {
    NSLog(@"Move right command sent ** Not Impemented **");
}


@end
