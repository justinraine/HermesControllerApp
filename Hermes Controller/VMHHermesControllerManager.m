//
//  VMHHermesControllerManager.m
//  VMHHermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHHermesControllerManager.h"
@import CoreBluetooth;
#import "VMHPacket.h"
#import "Constants.h"

NSString *const kReceivedUpdatedPositionNotification = @"positionReceivedNotification";
NSString *const kReceivedUpdatedProgressNotification = @"progressReceivedNotification";
NSString *const kReceivedErrorCodeNotification = @"errorReceivedNotificiation";
NSString *const kPositionKey = @"absolutePositionKey";
NSString *const kProgressKey = @"progressKey";
NSString *const kErrorCodeKey = @"errorCodeKey";


@interface VMHHermesControllerManager()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) CBCharacteristic *txCharacteristic;
@property (nonatomic, strong) CBCharacteristic *rxCharacteristic;
@property (nonatomic, strong) VMHPacket *packet;
@property (nonatomic, getter=isReadyForCommand) BOOL readyForCommand;
@property (nonatomic, getter=isWaitingToScan) BOOL waitingToScan;
@property ControllerStatus status;
@property NSUInteger previouslyDiscoveredHermesControllersCount;

@end


@implementation VMHHermesControllerManager

static int scanTimeoutSecond = 2;
int kMaxRPM = 230;
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
                                                                   properties:CBCharacteristicPropertyWriteWithoutResponse
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
        [self beginScan];
    } else {
        NSLog(@"Could not complete scan request -- request queued. Bluetooth state: %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
        self.waitingToScan = YES;
    }
}


- (CBPeripheral *)getConnectedHermesController {
    if (self.connectedPeripheral) {
        NSLog(@"Hermes Controller is not connected\n\n");
    }
    
    return self.connectedPeripheral;
}



#pragma mark - Operational Methods

- (BOOL)beginRecording {
    if (self.status == kConnected) {
        [self.packet configureRecordingPacketWithStatus:RecordingBegin];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endRecording {
    if (self.status == kConnected) {
        [self.packet configureRecordingPacketWithStatus:RecordingEnd];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovementLeft {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementLeft];
        [self.packet printPacket:YES]; //***
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovementRight {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementRight];
        [self.packet printPacket:YES]; //***
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovementLeftWithMaxSpeedRPM:(NSUInteger)speedRPM dampingPercent:(NSUInteger)dampingPercent{
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementLeft
                                              maxSpeedRPM:speedRPM
                                           dampingPercent:dampingPercent];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginMovementRightWithMaxSpeedRPM:(NSUInteger)speedRPM dampingPercent:(NSUInteger)dampingPercent {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementRight
                                              maxSpeedRPM:speedRPM
                                           dampingPercent:dampingPercent];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endMovement {
    if (self.status == kConnected) {
        [self.packet configureMovementPacketWithDirection:MovementStop];
        BOOL sendEndPacket = YES;
        
        if (sendEndPacket) {
            [self.packet printPacket:YES];
            [self.connectedPeripheral writeValue:[self.packet dataFormat]
                               forCharacteristic:self.txCharacteristic
                                            type:CBCharacteristicWriteWithoutResponse];
        } else {
            NSLog(@"Command Packet: NO PACKET SENT\n\n");
        }
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)setPosition {
    if (self.status == kConnected) {
        [self.packet configureSetPositionPacket];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginTimeLapseWithDurationSeconds:(NSUInteger)durationSeconds
                       startPositionSteps:(NSUInteger)startPositionSteps
                         endPositionSteps:(NSUInteger)endPositionSteps
                           dampingPercent:(NSUInteger)dampingPercent
                                     loop:(BOOL)loop {
    if (self.status == kConnected) {
        [self.packet configureTimeLapseModePacketWithDurationSeconds:durationSeconds
                                                  startPositionSteps:startPositionSteps
                                                    endPositionSteps:endPositionSteps
                                                      dampingPercent:dampingPercent
                                                                loop:loop];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endTimeLapse {
    if (self.status == kConnected) {
        [self.packet configureTimeLapseModeEndRecordingPacket];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)beginStopMotionWithDurationSeconds:(NSUInteger)durationSeconds
                        startPositionSteps:(NSUInteger)startPositionSteps
                          endPositionSteps:(NSUInteger)endPositionSteps
                            dampingPercent:(NSUInteger)dampingPercent
                    captureIntervalSeconds:(NSUInteger)captureIntervalSeconds {
    if (self.status == kConnected) {
        [self.packet configureStopMotionModePacketWithDurationSeconds:durationSeconds
                                                   startPositionSteps:startPositionSteps
                                                     endPositionSteps:endPositionSteps
                                                       dampingPercent:dampingPercent
                                               captureIntervalSeconds:captureIntervalSeconds];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
        return YES;
    } else {
        return NO;
    }
}


- (BOOL)endStopMotion {
    if (self.status == kConnected) {
        [self.packet configureStopMotionModeEndRecordingPacket];
        [self.packet printPacket:YES];
        [self.connectedPeripheral writeValue:[self.packet dataFormat]
                           forCharacteristic:self.txCharacteristic
                                        type:CBCharacteristicWriteWithoutResponse];
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
            NSLog(@"CoreBluetooth BLE hardware is powered off\n\n");
            self.status = kBluetoothPoweredOff;
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready\n\n");
            NSLog(@"***** Connection Stage *****");
            self.readyForCommand = YES;
            self.status = kIdle;
            
            if ([self isWaitingToScan]) {
                NSLog(@"Queued scan detected. Initiating scan...");
                [self beginScan];
            }
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting\n\n");
            self.status = kBluetoothPoweredOff;
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized\n\n");
            self.status = kError;
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown\n\n");
            self.status = kError;
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform\n\n");
            self.status = kUnsupported;
            break;
        default:
            NSLog(@"Error: Could not determine CoreBluetooth BLE state\n\n");
            self.status = kError;
            break;
    }
}


// Automatically connects to discovered peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Found %@ peripheral with device UUID: %@", peripheral.name, [[peripheral identifier] UUIDString]);
    
    self.discoveredPeripheral = peripheral;
    self.discoveredPeripheral.delegate = self;
    [self connectToHermesController:self.discoveredPeripheral];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connected to %@ peripheral", peripheral.name);
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;
    self.status = kConnected;
    
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kUARTServiceUUIDString]]];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to %@ peripheral with UUID : %@\n\n", peripheral.name, [[peripheral identifier] UUIDString]);
    self.connectedPeripheral = nil;
    self.status = kConnectionFailed;
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error) {
        NSLog(@"Error: %@ disconnected. %@\n\n", peripheral.name, [error localizedDescription]);
    } else {
        NSLog(@"Successfully disconnected from peripheral with UUID: %@\n\n", [[peripheral identifier] UUIDString]);
    }
    
    self.connectedPeripheral = nil;
    self.rxCharacteristic = nil;
    self.txCharacteristic = nil;
    self.status = kDisconnected;
}



#pragma mark - CBPeripheralDelegate Protocol Methods

/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        // Deal with errors (if any)
        if (error) {
            NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
            return;
        }
        
        // Again, we loop through the array, just in case.
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kTransmitCharacteristicUUIDString]]) {
                self.txCharacteristic = characteristic;
                NSLog(@"Transmit characteristic found");
            } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReceiveCharacteristicUUIDString]]) {
                self.rxCharacteristic = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                NSLog(@"Receive characteristic found");
            } else {
                NSLog(@"Unknown characteristic found with UUID: %@", characteristic.UUID);
            }
        }
    } else {
        NSLog(@"Characteristic discorvery unsuccessful!\n\n");
    }
    
    if (self.txCharacteristic && self.rxCharacteristic) {
        NSLog(@"Connection Setup!\n\n\n");
        NSLog(@"***** Transfer Stage *****");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        NSLog(@"Services of %@ peripheral found",peripheral.name);
        for (CBService *service in peripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kUARTServiceUUIDString]]) {
                NSLog(@"Discovered UART service with UUID: %@", service.UUID);
            } else {
                NSLog(@"Discovered unknown service with UUID: %@", service.UUID);
            }
            [peripheral discoverCharacteristics:nil forService:service];
        }
    } else {
        NSLog(@"Service discovery was unsuccessfull!\r\n");
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //    if (!error) {
    //        printf("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[[[peripheral identifier] UUIDString] UTF8String]);
    //    }
    //    else {
    //        printf("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[[[peripheral identifier] UUIDString] UTF8String]);
    //        printf("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    //    }
    
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        //NSLog(@"Services of peripheral with UUID: %s found",[[[peripheral identifier] UUIDString] UTF8String]);
        if (characteristic.UUID == self.rxCharacteristic.UUID) {
            NSLog(@"Data received from Rx Channel");
            [self processDataFromCharacteristic:characteristic];
        }
    }
    else {
        NSLog(@"updateValueForCharacteristic failed!");
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Successfully wrote to characteristic UUID: %@", characteristic.UUID);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    //NSLog(@"Peripheral RSSI updated: %@", peripheral.RSSI);
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

- (void)beginScan {
    NSLog(@"Scanning for Bluetooth peripherals with UART service UUID: %@", kUARTServiceUUIDString);
    
    // Begin scan timeout timer
    [NSTimer scheduledTimerWithTimeInterval:scanTimeoutSecond
                                     target:self
                                   selector:@selector(scanTimer)
                                   userInfo:nil
                                    repeats:NO];
    
    // Begin scanning
    NSArray *services = @[[CBUUID UUIDWithString:kUARTServiceUUIDString]];
    [self.centralManager scanForPeripheralsWithServices:services options:nil];
    self.status = kScanning;
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
        NSLog(@"Connecting to %@ peripheral...", peripheral.name);
        
        self.status = kConnecting;
        [self.centralManager connectPeripheral:peripheral options:nil];
    } else {
        NSLog(@"Error: Unexpected condition - endScanForHermesController request while Bluetooth is in state %d (%s)",
              (int)self.centralManager.state, [self centralManagerStateToString:self.centralManager.state]);
    }
}

- (void)processDataFromCharacteristic:(CBCharacteristic *)characteristic {
    VMHPacket *receivedPacket = [[VMHPacket alloc] initWithData:characteristic.value];

    // If the received packet is a Hardware Response packet
    if ([receivedPacket mode] == 0x00) {
        
        if ([receivedPacket command] == VMHRxCommandCurrentPosition) {
            // Send currentPositionSteps to PositionViewController
            NSLog(@"Received Current Position Packet");
            NSNumber *currentPositionSteps = [NSNumber numberWithInt:[receivedPacket parameter1]];
            NSDictionary *userInfo = @{kPositionKey : currentPositionSteps};
            [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedUpdatedPositionNotification
                                                                object:self userInfo:userInfo];
            
            // Send currentProgressPercent to InProgressViewController
            NSLog(@"Received Current Progress Packet");
            NSNumber *progressPercent = [NSNumber numberWithInt:[receivedPacket parameter2]];
            userInfo = @{kProgressKey : progressPercent};
            [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedUpdatedProgressNotification
                                                                object:self userInfo:userInfo];
        } else if ([receivedPacket command] == VMHRxCommandCurrentProgress) {
            // Send currentProgressPercent to InProgressViewController
            NSLog(@"Received Current Progress Packet");
            NSNumber *progressPercent = [NSNumber numberWithInt:[receivedPacket parameter1]];
            NSDictionary *userInfo = @{kProgressKey : progressPercent};
            [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedUpdatedProgressNotification
                                                                object:self userInfo:userInfo];
        } else if ([receivedPacket command] == VMHRxCommandError) {
            // Send errorCode to AppDelegate
            NSLog(@"Received Error Packet");
            NSNumber *errorCode = [NSNumber numberWithInt:[receivedPacket parameter1]];
            NSDictionary *userInfo = @{kErrorCodeKey : errorCode};
            [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedErrorCodeNotification
                                                                object:self userInfo:userInfo];
        }
    }
}

@end
