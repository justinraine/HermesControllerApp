//
//  HermesControllerManager.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreBluetooth;
#import "BLEInterface.h"

typedef NS_ENUM(NSUInteger, ControllerStatus) {
    kScanning,
    kConnecting,
    kConnectionFailed,
    kConnected,
    kDisconnected,
    kTimeout,
    kIdle,
    kBluetoothPoweredOff,
    kError,
};

@interface VMHHermesControllerManager : NSObject <CBCentralManagerDelegate, BLEInterfaceDelegateProtocol>

// Public Properties
@property (nonatomic, strong) NSMutableArray *discoveredHermesControllers;
@property (readonly) ControllerStatus status;


// Public Methods

// Utility Methods
+ (VMHHermesControllerManager *)sharedInstance;
//- (void)scanForHermesController;
//- (void)endScanForHermesController;
//- (void)continueScanForHermesController;
//- (void)connectToHermesController:(CBPeripheral *)peripheral;
- (void)connectToNearbyHermesController;
- (CBPeripheral *)getConnectedHermesController;

// Operational Methods
- (BOOL)beginRecording;
- (BOOL)endRecording;
- (BOOL)beginMovingRight;
- (BOOL)beginMovingLeft;
- (BOOL)endMovement;
- (BOOL)beginTimeLapseWithDuration:(NSInteger)durationSeconds
                     startPosition:(NSInteger)start
                       endPosition:(NSInteger)end
                           damping:(NSInteger)damping
                              loop:(BOOL)loop;
- (BOOL)endTimeLapse;
- (BOOL)beginStopMotionWithInterval:(NSInteger)intervalSeconds
                      startPosition:(NSInteger)start
                        endPosition:(NSInteger)end
                            damping:(NSInteger)damping;
- (BOOL)endStopMotion;
@end
