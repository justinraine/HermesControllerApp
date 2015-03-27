//
//  PositionViewController.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-16.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "PositionViewController.h"

NSString *const kPositionUpdateNotification = @"positionSetNotification";
NSString *const kPositionStepsKey = @"positionStepsKey";
NSString *const kSetStartPositionKey = @"setStartPositionKey";

@interface PositionViewController ()

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) NSNumber *currentPosition;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setPosition:(id)sender {
    self.currentPosition = [NSNumber numberWithInt:arc4random() % 3000]; // get response from Controller
    NSLog(@"Position set: %@ ** Dummy Value **", self.currentPosition);
    
    NSDictionary *currentPosition = @{kPositionStepsKey : self.currentPosition,
                                      kSetStartPositionKey : [NSNumber numberWithBool:self.setStartPosition]};
    [[NSNotificationCenter defaultCenter] postNotificationName:kPositionUpdateNotification object:self userInfo:currentPosition];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)moveLeft:(id)sender {
    NSLog(@"Move left command sent ** Not Impemented **");
}

- (IBAction)moveRight:(id)sender {
    NSLog(@"Move right command sent ** Not Impemented **");
}


@end
