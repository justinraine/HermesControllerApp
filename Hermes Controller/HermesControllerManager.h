//
//  HermesControllerManager.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>
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

@interface HermesControllerManager : NSObject <BLEInterfaceDelegateProtocol>

// Public Properties
@property (strong, nonatomic) NSMutableArray *discoveredHermesControllers;
@property (readonly) ControllerStatus status;


// Public Methods
+ (HermesControllerManager *)sharedInstance;
- (void)scanForHermesController;
- (void)endScanForHermesController;
//- (void)continueScanForHermesController;
- (void)connectToHermesController:(CBPeripheral *)peripheral;
- (CBPeripheral *)getConnectedHermesController;
- (void)sendCommand:(NSString *)command;
- (void)beginRecording;
- (void)stopRecording;

@end
