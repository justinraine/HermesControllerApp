//
//  PositionViewController.h
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-16.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kPositionUpdateNotification;
extern NSString *const kPositionStepsKey;
extern NSString *const kSetStartPositionKey;

@interface PositionViewController : UIViewController

@property (getter=isSetStartPosition) BOOL setStartPosition; // false == setEndPosition

@end