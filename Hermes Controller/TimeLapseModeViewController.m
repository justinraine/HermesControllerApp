//
//  TimeLapseModeViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-14.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "TimeLapseModeViewController.h"

@interface TimeLapseModeViewController ()

@property (strong, nonatomic) NSMutableArray *hours;
@property (strong, nonatomic) NSMutableArray *minutes;
@property (strong, nonatomic) NSMutableArray *seconds;

@end

@implementation TimeLapseModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (int i = 0; i < 6; i++) {
        [self.hours addObject:@(i)];
    }
    
    for (int i = 0; i < 60; i++) {
        [self.minutes addObject:@(i)];
        [self.seconds addObject:@(i)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3; // hour, minute, seconds
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 1;
}


# pragma mark - UIPickerViewDelegate



@end
