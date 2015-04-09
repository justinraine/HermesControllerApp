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

extern NSString *const kReceivedUpdatedPositionNotification;
extern NSString *const kReceivedUpdatedProgressNotification;
extern NSString *const kReceivedErrorCodeNotification;
extern NSString *const kPositionKey;
extern NSString *const kProgressKey;
extern NSString *const kErrorCodeKey;


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
- (BOOL)beginMovementLeftWithMaxSpeedRPM:(NSUInteger)speedRPM dampingPercent:(NSUInteger)dampingPercent;
- (BOOL)beginMovementRightWithMaxSpeedRPM:(NSUInteger)speedRPM dampingPercent:(NSUInteger)dampingPercent;
- (BOOL)endMovement;
- (BOOL)setPosition;
- (BOOL)beginTimeLapseWithDurationSeconds:(NSUInteger)durationSeconds
                       startPositionSteps:(NSUInteger)startPositionSteps
                         endPositionSteps:(NSUInteger)endPositionSteps
                           dampingPercent:(NSUInteger)dampingPercent
                                     loop:(BOOL)loop;
- (BOOL)endTimeLapse;
- (BOOL)beginStopMotionWithDurationSeconds:(NSUInteger)durationSeconds
                        startPositionSteps:(NSUInteger)startPositionSteps
                          endPositionSteps:(NSUInteger)endPositionSteps
                            dampingPercent:(NSUInteger)dampingPercent
                    captureIntervalSeconds:(NSUInteger)captureIntervalSeconds;
- (BOOL)endStopMotion;
@end
