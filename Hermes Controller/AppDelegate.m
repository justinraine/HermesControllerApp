//
//  AppDelegate.m
//  HermesController
//
//  Created by Justin Raine on 2015-03-05.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "AppDelegate.h"
#import "VMHHermesControllerManager.h"
#import "Constants.h"
#import "DeviceUnsupportedViewController.h"
#import "ConnectionViewController.h"
#import "PositionViewController.h"
#import "InProgressViewController.h"

NS_ENUM(NSInteger, alertTag) {
    kUnsupportedTag,
    kConnectionUnsuccessfulTag
};

@interface AppDelegate ()

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, getter=isConnectionViewDisplayed) BOOL connectionViewDisplayed;
@property (nonatomic, getter=isDisplayingHUD) BOOL displayingHUD;

@end

@implementation AppDelegate

#pragma mark - AppDelegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Setup KVO notifications from HermesControllerManager
    [[VMHHermesControllerManager sharedInstance] addObserver:self
                                                  forKeyPath:@"status"
                                                     options:0
                                                     context:nil];
    
    [self.window makeKeyAndVisible];
    [self showBasicHUD];
    [[VMHHermesControllerManager sharedInstance] connectToNearbyHermesController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark - Public Methods

- (void)showBasicHUD {
    //NSLog(@"showBasicHUD");
    [self HUDSetup];
}

- (void)showCaptureHUD {
    //NSLog(@"showCaptureHUD");
    [self HUDSetup];
    self.HUD.labelText = @"Capturing...";
    self.HUD.mode = MBProgressHUDModeAnnularDeterminate;
}

- (void)hideHUD {
    if ([self isDisplayingHUD]) {
        //NSLog(@"hideHUD isDisplayingHUD");
        self.displayingHUD = NO;
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self.HUD hide:YES];
    }
}

- (void)updateCaptureProgress:(int)progress {
    self.HUD.progress = progress;
}



#pragma mark - Private Methods

- (void)HUDSetup {
    //NSLog(@"HUDSetup");
    // Hide any currently displaying HUD
    //[self.HUD hide:YES]; // necessary?
    
    // Display HUD
    UIWindow *windowForHud = [[UIApplication sharedApplication] delegate].window;
    self.HUD = [MBProgressHUD showHUDAddedTo:windowForHud animated:YES];
    self.displayingHUD = YES;
    
    // Configure basic HUD
    self.HUD.minShowTime = 0.1;
    self.HUD.labelText = @"";
    self.HUD.detailsLabelText = @"";
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


// Alert response handler function
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kConnectionUnsuccessfulTag) {
        UIViewController *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *connectionNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"ConnectionNav"];
        
        if(![self isConnectionViewDisplayed]) {
            self.connectionViewDisplayed = YES;
            [rootView presentViewController:connectionNavigationController animated:YES completion:nil];
        }
    } else if (alertView.tag == kUnsupportedTag) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        DeviceUnsupportedViewController *deviceUnsupportedViewController = [storyboard instantiateViewControllerWithIdentifier:@"DeviceUnsupportedView"];
        [rootView presentViewController:deviceUnsupportedViewController animated:YES completion:nil];
    }
}


- (BOOL)isConnectionViewDisplayed {
    return _connectionViewDisplayed;
}


- (BOOL)isDisplayingHUD {
    return _displayingHUD;
}


- (UIViewController*) topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}



#pragma mark - KVO handler

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        [self handleUpdatedStatus:[VMHHermesControllerManager sharedInstance].status];
    }
}

- (void)handleUpdatedStatus:(ControllerStatus)updatedStatus {
    if (updatedStatus == kScanning) {
        self.HUD.labelText = @"Scanning...";
    } else if (updatedStatus == kConnecting) {
        self.HUD.labelText = @"Connecting...";
    } else if (updatedStatus == kConnectionFailed) {
        [self hideHUD];
        [self displayUnsuccessfulAlertWithTitle:@"Connection Failed"
                                        message:@"Unable to connect to Hermes Controller"];
    } else if (updatedStatus == kConnected) {
        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"Connected!";
        
        [self.HUD show:YES];
        
        // Wait 1 second
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if ([self isConnectionViewDisplayed]) {
                UIViewController *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController]; //***
                [rootView dismissViewControllerAnimated:YES completion:^{
                    self.connectionViewDisplayed = NO;
                    [self hideHUD];
                }];
            } else {
                [self hideHUD];
            }
        });
    } else if (updatedStatus == kDisconnected) {
        UIViewController *rootView = [UIApplication sharedApplication].keyWindow.rootViewController;
        NSLog(@"%@", [self.window.rootViewController.presentedViewController class]);
        if ([self.window.rootViewController.presentedViewController class] && [VMHHermesControllerManager sharedInstance].status == kDisconnected) {
            [rootView dismissViewControllerAnimated:YES completion:nil];
        }
        
        [self hideHUD];
        [self displayUnsuccessfulAlertWithTitle:@"Bluetooth Disconnection"
                                        message:@"Hermes has been disconnected"];
    } else if (updatedStatus == kTimeout) {
        [self hideHUD];
        [self displayUnsuccessfulAlertWithTitle:@"Device Not Found"
                                        message:@"Please ensure your Hermes Controller is on and within range"];
    } else if (updatedStatus == kIdle) {
        // do nothing?
    } else if (updatedStatus == kBluetoothPoweredOff) {
        [self hideHUD];
        [self displayUnsuccessfulAlertWithTitle:@"Bluetooth Disabled"
                                        message:@"Please enable Bluetooth and connect to a Hermes Controller"];
    } else if (updatedStatus == kUnsupported) {
        [self hideHUD];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Bluetooth Not Supported"
                              message:@"This device does not support Bluetooth LE"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        alert.tag = kUnsupportedTag;
        [alert show];
    } else if (updatedStatus == kError) {
        [self hideHUD];
        [self displayUnsuccessfulAlertWithTitle:@"Bluetooth Error"
                                        message:@"An unknown error occurred"];
    }
}


- (void)displayUnsuccessfulAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    alert.tag = kConnectionUnsuccessfulTag;
    [alert show];
}

@end
