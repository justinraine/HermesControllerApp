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
    kBluetoothNotPoweredOn,
};

typedef NS_ENUM(NSUInteger, MoveDirection) {
    kMoveLeft,
    kMoveRight,
};

@interface VMHHermesControllerManager : NSObject <CBCentralManagerDelegate, BLEInterfaceDelegateProtocol>

// Public Properties
@property (nonatomic, strong) NSMutableArray *discoveredHermesControllers;
@property (readonly) ControllerStatus status;


// Public Methods

// Utility Methods
+ (VMHHermesControllerManager *)sharedInstance;
- (void)scanForHermesController;
- (void)endScanForHermesController;
//- (void)continueScanForHermesController;
- (void)connectToHermesController:(CBPeripheral *)peripheral;
- (CBPeripheral *)getConnectedHermesController;
- (void)sendCommand:(NSString *)command;

// Operational Methods
- (void)beginRecording;
- (void)endRecording;
//- (void)moveLeftWithSpeed:(NSInteger)speed;
//- (void)moveRightWithSpeed:(NSInteger)speed;
- (void)beginMovementWithDirection:(MoveDirection)direction;
- (void)endMovement;
- (void)beginTimeLapseWithDuration:(NSInteger)durationSeconds
                     startPosition:(NSInteger)start
                       endPosition:(NSInteger)end
                           damping:(NSInteger)damping
                              loop:(BOOL)loop;
- (void)beginStopMotionWithInterval:(NSInteger)intervalSeconds
                      startPosition:(NSInteger)start
                        endPosition:(NSInteger)end
                            damping:(NSInteger)damping;
@end
