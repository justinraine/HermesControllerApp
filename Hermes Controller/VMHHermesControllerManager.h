//
//  HermesControllerManager.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;

typedef NS_ENUM(NSUInteger, ControllerStatus) {
    kScanning,
    kConnecting,
    kConnectionFailed,
    kConnected,
    kDisconnected,
    kTimeout,
    kIdle,
    kBluetoothPoweredOff,
    kUnsupported,
    kError,
};

@interface VMHHermesControllerManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

// Public Properties
@property (nonatomic, strong) NSMutableArray *discoveredHermesControllers;
@property (readonly) ControllerStatus status;


// Utility Methods
+ (VMHHermesControllerManager *)sharedInstance;
- (void)connectToNearbyHermesController;
- (CBPeripheral *)getConnectedHermesController;

// Operational Methods
- (BOOL)beginRecording;
- (BOOL)endRecording;
- (BOOL)beginMovementRight;
- (BOOL)beginMovementLeft;
- (BOOL)beginMovementRightWithMaxSpeed:(int)speed damping:(int)damping;
- (BOOL)beginMovementLeftWithMaxSpeed:(int)speed damping:(int)damping;
- (BOOL)endMovement;
- (BOOL)beginTimeLapseWithDurationSeconds:(NSInteger)durationSeconds
                       startPositionSteps:(NSInteger)startPositionSteps
                         endPositionSteps:(NSInteger)endPositionSteps
                           dampingPercent:(NSInteger)dampingPercent
                                     loop:(BOOL)loop;
- (BOOL)endTimeLapse;
- (BOOL)beginStopMotionWithDurationSeconds:(NSInteger)durationSeconds
                        startPositionSteps:(NSInteger)startPositionSteps
                          endPositionSteps:(NSInteger)endPositionSteps
                            dampingPercent:(NSInteger)dampingPercent
                    captureIntervalSeconds:(NSInteger)captureIntervalSeconds;
- (BOOL)endStopMotion;
@end
