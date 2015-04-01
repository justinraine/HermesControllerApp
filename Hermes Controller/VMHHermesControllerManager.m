//
//  VMHHermesControllerManager.m
//  VMHHermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHHermesControllerManager.h"
@import CoreBluetooth;
#import "VMHPeripheral.h"
#import "Constants.h"
#import "BLEInterface.h"
#import "VMHPacket.h"

@interface VMHHermesControllerManager()

//@property (nonatomic, strong) BLEInterface *BLEInterface;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;
@property (nonatomic, strong) CBCharacteristic *rxCharacteristic;
@property (nonatomic, strong) VMHPacket *packet;
@property (nonatomic, getter=isReadyForCommand) BOOL readyForCommand;
@property (nonatomic, getter=isWaitingToScan) BOOL waitingToScan;
@property ControllerStatus status;
@property NSUInteger previouslyDiscoveredHermesControllersCount;

@end


@implementation VMHHermesControllerManager

static int scanTimeoutSecond = 15;
//@synthesize status;

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    
    if (self) {
        // Setup CoreBluetooth Properties
        self.centralManager = [[CBCentralManager alloc]
                               initWithDelegate:self
                               queue:nil
                               options:nil /*@{CBCentralManagerOptionRestoreIdentifierKey:@"BLESericeBrowser"}*/];
        self.txCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kTransmitCharacteristicUUIDString]
                                                                   properties:CBCharacteristicPropertyWrite
                                                                        value:nil
                                                                  permissions:CBAttributePermissionsWriteable];
        self.rxCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:kReceiveCharacteristicUUIDString]
                                                                   properties:CBCharacteristicPropertyRead
                                                                        value:nil
                                                                  permissions:CBAttributePermissionsReadable];
        
        
        // Initialize other variables
        self.status = kBluetoothPoweredOff;
        self.discoveredHermesControllers = [NSMutableArray array];
        self.packet = [[VMHPacket alloc] init];
    }
    
    return self;
}


#pragma mark - Utility Methods


// Returns singleton instance of VMHHermesControllerManager
+ (VMHHermesControllerManager *)sharedInstance {
    static VMHHermesControllerManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


// Checks status of Bluetooth interface and begins scan if possible otherwise reports an error
- (void)connectToNearbyHermesController {
    if ([self isReadyForCommand]) {
        NSLog(@"Scanning for Bluetooth peripherals with UUID %@", kUARTServiceUUIDString);
        
        // Begin scan timeout timer
        [NSTimer scheduledTimerWithTimeInterval:scanTimeoutSecond
                                         target:self
                                       selector:@selector(scanTimer:)
                                       userInfo:nil
                                        repeats:NO];
        
        // Begin scanning
        NSArray *services = @[[CBUUID UUIDWithString:kUARTServiceUUIDString]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
        self.status = kScanning;
    } else {
        NSLog(@"Could not complete scan request -- request queued. Bluetooth state: %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
        self.waitingToScan = YES;
    }
}


- (CBPeripheral *)getConnectedHermesController {
    if (self.connectedPeripheral) {
        return self.connectedPeripheral;
    } else {
        NSLog(@"Hermes Controller is not connected");
        return nil;
    }
}

/* Old Methods
- (void)scanForHermesController {
    if ([self isReadyForCommand]) {
        NSLog(@"Scanning for Bluetooth peripherals with UUID %@", kUARTServiceUUIDString);
        
        [NSTimer scheduledTimerWithTimeInterval:scanTimeoutSecond
                                         target:self
                                       selector:@selector(scanTimer:)
                                       userInfo:nil
                                        repeats:NO];
        
        NSArray *services = @[[CBUUID UUIDWithString:kUARTServiceUUIDString]];
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
        self.status = kScanning;
    } else {
        NSLog(@"Could not complete scan request -- request queued. Bluetooth state: %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
        self.waitingToScan = YES;
        self.status = kIdle;
    }
}


- (void)continueScanForHermesController {
    NSNumber *foundControllerCount = [NSNumber numberWithInteger:self.discoveredHermesControllers.count];
    [NSTimer scheduledTimerWithTimeInterval:(float)scanTimeoutSecond
                                     target:self
                                   selector:@selector(continueScanTimer:)
                                   userInfo:foundControllerCount
                                    repeats:NO];
}


- (void)continueScanTimer:(NSTimer *)timer {
    int previousControllerCount = [((NSNumber *)[timer userInfo]) intValue];
    if (self.status == kScanning && self.discoveredHermesControllers.count == previousControllerCount) {
        NSLog(@"Scan timed out - sending endScanForPeripherals message to Bluetooth interface");
        [self.BLEInterface endScanForPeripherals];
        self.status = kTimeout;
    }
}
 */



#pragma mark - Operational Methods

- (BOOL)beginRecording {
    if (self.status == kConnected) {
        [self.packet configureRecordingPacketWithStatus:RecordingBegin];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endRecording {
    if (self.status == kConnected) {
        [self.packet configureRecordingPacketWithStatus:RecordingEnd];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovingLeft {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementLeft];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovingRight {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementRight];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endMovement {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementStop];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


-(BOOL)beginTimeLapseWithDuration:(NSInteger)durationSeconds
                    startPosition:(NSInteger)start
                      endPosition:(NSInteger)end
                          damping:(NSInteger)damping
                             loop:(BOOL)loop {
    if (self.status == kConnected) {
        [self.packet configureTimeLapseModePacketWithDurationSeconds:durationSeconds
                                                  startPositionSteps:start
                                                    endPositionSteps:end
                                                      dampingPercent:damping loop:loop];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endTimeLapse {
    if (self.status == kConnected) {
        [self.packet configureTimeLapseModeEndRecordingPacket];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


-(BOOL)beginStopMotionWithInterval:(NSInteger)intervalSeconds
                     startPosition:(NSInteger)start
                       endPosition:(NSInteger)end
                           damping:(NSInteger)damping {
    if (self.status == kConnected) {
        [self.packet configureStopMotionModePacketWithCaptureIntervalSeconds:intervalSeconds
                                                          startPositionSteps:start
                                                            endPositionSteps:end
                                                              dampingPercent:damping];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endStopMotion {
    if (self.status == kConnected) {
        [self.packet configureStopMotionModeEndRecordingPacket];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithResponse];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - CBCentralManagerDelegate Methods

/*--------------------------------------------------------------------------------------------------
 *
 *                              CBCentralManagerDelegate Methods
 *
 *------------------------------------------------------------------------------------------------*/

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    self.readyForCommand = NO;
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            self.status = kBluetoothPoweredOff;
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            self.readyForCommand = YES;
            self.status = kIdle;
            
            if ([self isWaitingToScan]) {
                self.status = kScanning;
                NSArray *services = @[[CBUUID UUIDWithString:kUARTServiceUUIDString]];
                [self.centralManager scanForPeripheralsWithServices:services options:nil];
            }
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            self.status = kBluetoothPoweredOff;
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            self.status = kError;
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            self.status = kError;
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            self.status = kError;
            break;
        default:
            NSLog(@"Error: Could not determine CoreBluetooth BLE state");
            self.status = kError;
            break;
    }
}


// Automatically connects to discovered peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Found peripheral with UUID : %@\n\n", [[peripheral identifier] UUIDString]);
    
    [self connectToHermesController:peripheral];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to peripheral with UUID : %@\n\n", [[peripheral identifier] UUIDString]);
    self.connectedPeripheral = peripheral;
    self.status = kConnected;
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to peripheral with UUID : %@\n\n", [[peripheral identifier] UUIDString]);
    self.connectedPeripheral = nil;
    self.status = kConnectionFailed;
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Error: %@. Unexpectedly disconnected from peripheral with UUID: %@\n\n", [error localizedDescription], [[peripheral identifier] UUIDString]);
    } else {
        NSLog(@"Successfully disconnected from peripheral with UUID : %@\n\n", [[peripheral identifier] UUIDString]);
    }
    
    self.connectedPeripheral = nil;
    self.status = kDisconnected;
}



#pragma mark - Getter Methods

- (BOOL)isReadyForCommand {
    return _readyForCommand;
}


- (BOOL)isWaitingToScan {
    return _waitingToScan;
}



#pragma mark - Private Methods

- (const char *)centralManagerStateToString: (int)state {
    switch(state) {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}


- (void)scanTimer {
    if (self.status == kScanning) {
        NSLog(@"Scan timed out");
        
        self.status = kTimeout;
        [self endScanForHermesController];
    }
}


- (void)endScanForHermesController {
    if ([self isReadyForCommand]) {
        NSLog(@"Ending Bluetooth scan for peripherals");
        [self.centralManager stopScan];
    } else {
        NSLog(@"Error: Unexpected condition - endScanForHermesController request while Bluetooth is in state %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
    }
    
    self.status = kIdle;
}


- (void)connectToHermesController:(CBPeripheral *)peripheral {
    if ([self isReadyForCommand]) {
        NSLog(@"Attempting to connect to %@", peripheral.name);
        
        self.status = kConnecting;
        [self.centralManager connectPeripheral:peripheral options:nil];
    } else {
        NSLog(@"Error: Unexpected condition - endScanForHermesController request while Bluetooth is in state %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
    }
}

@end
