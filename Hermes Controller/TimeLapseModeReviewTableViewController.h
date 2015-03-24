//
//  TimeLapseModeReviewTableViewController.h
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeLapseModeReviewTableViewController : UITableViewController

@property NSInteger captureDurationSeconds;
@property NSInteger startPositionSteps;
@property NSInteger endPositionSteps;
@property NSInteger dampingPercent;
@property BOOL loop;

@end
