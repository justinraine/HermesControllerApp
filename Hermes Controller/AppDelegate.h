//
//  AppDelegate.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-05.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIWindow *window;

- (void)showBasicHUD;
- (void)showCaptureHUD;
- (void)updateCaptureProgress:(int)progress;
- (void)hideHUD;

@end

