//
//  VMHHermesControllerManager.m
//  VMHHermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHHermesControllerManager.h"
#import "Constants.h"
#import "BLEInterface.h"
#import "VMHPacket.h"

@interface VMHHermesControllerManager()

@property (strong, nonatomic) BLEInterface *BLEInterface;
@property ControllerStatus status;
@property NSUInteger previouslyDiscoveredHermesControllersCount;

@end


@implementation VMHHermesControllerManager

static int scanTimeoutSecond = 15; // CBCentralManager scan timeout duration
//@synthesize status;

- (id)init {
    self = [super init];
    
    if (self) {
        self.BLEInterface = [[BLEInterface alloc] initWithDelegate:self];
        self.status = kIdle; //*** necessary?
        self.discoveredHermesControllers = [NSMutableArray array];
    }
    
    return self;
}


#pragma mark - Utility Methods

+ (VMHHermesControllerManager *)sharedInstance {
    static VMHHermesControllerManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (void)scanForHermesController {
    NSLog(@"Sending beginScanForPeripheralWithServices message to Bluetooth interface");

    if (!self.BLEInterface) {
        self.BLEInterface = [[BLEInterface alloc] initWithDelegate:self];
    }
    
    NSArray *services = @[[CBUUID UUIDWithString:kUARTServiceUUIDString]];
    [self.BLEInterface beginScanForPeripheralWithServices:services];
}


- (void)scanTimer {
    if (self.status == kScanning &&
        self.discoveredHermesControllers.count == self.previouslyDiscoveredHermesControllersCount) {
        NSLog(@"Scan timed out - sending endScanForPeripherals message to Bluetooth interface");
        [self.BLEInterface endScanForPeripherals];
        self.status = kTimeout;
    }
}


- (void)endScanForHermesController {
    [self.BLEInterface endScanForPeripherals];
    self.status = kIdle;
}


//- (void)continueScanForHermesController {
//    NSNumber *foundControllerCount = [NSNumber numberWithInteger:self.discoveredHermesControllers.count];
//    [NSTimer scheduledTimerWithTimeInterval:(float)scanTimeoutSecond
//                                     target:self
//                                   selector:@selector(continueScanTimer:)
//                                   userInfo:foundControllerCount
//                                    repeats:NO];
//}
//
//
//- (void)continueScanTimer:(NSTimer *)timer {
//    int previousControllerCount = [((NSNumber *)[timer userInfo]) intValue];
//    if (self.status == kScanning && self.discoveredHermesControllers.count == previousControllerCount) {
//        NSLog(@"Scan timed out - sending endScanForPeripherals message to Bluetooth interface");
//        [self.BLEInterface endScanForPeripherals];
//        self.status = kTimeout;
//    }
//}


- (void)connectToHermesController:(CBPeripheral *)peripheral {
    NSLog(@"Sending connectToPeripheral message to Bluetooth interface");
    [self.BLEInterface connectToPeripheral:peripheral];
}


- (CBPeripheral *)getConnectedHermesController {
    return self.BLEInterface.connectedPeripheral;
}


- (void)sendCommand:(NSString *)command {
    if (self.status == kConnected) {
        NSLog(@"Sending command to connected device");
        //[self.BTInterface writeString:command];
    } else {
        NSLog(@"Error: Unable to send command - no connected peripheral");
    }
}



#pragma mark - Operational Methods

- (void)beginRecording {
    VMHPacket *packet = [[VMHPacket alloc] init];
    [packet configureLiveModeMoveRightPacketWithSpeed:80];
    [packet printPacket];
    [packet dataFormat];
    
    if (self.status == kConnected) {
        [self.BLEInterface writeValue:kUARTServiceUUIDInt
                   characteristicUUID:kTransmitCharacteristicUUIDInt
                                    p:self.BLEInterface.connectedPeripheral
                                 data:[self createRecordStartCommand]];
    }
}


- (void)endRecording {
    if (self.status == kConnected) {
        [self.BLEInterface writeValue:kUARTServiceUUIDInt
                   characteristicUUID:kTransmitCharacteristicUUIDInt
                                    p:self.BLEInterface.connectedPeripheral
                                 data:[self createRecordStopCommand]];
    }
}


-(void)moveLeftWithSpeed:(NSInteger)speed {
    
}


-(void)moveRightWithSpeed:(NSInteger)speed {
    
}


-(void)beginTimeLapseWithDuration:(NSInteger)durationSeconds startPosition:(NSInteger)start endPosition:(NSInteger)end damping:(NSInteger)damping loop:(BOOL)loop {
    
}


-(void)beginStopMotionWithInterval:(NSInteger)intervalSeconds startPosition:(NSInteger)start endPosition:(NSInteger)end damping:(NSInteger)damping {
    
}


- (NSData *)createRecordStartCommand {
    NSString *recordCommand = @"Start the recording!";
    return [recordCommand dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSData *)createRecordStopCommand {
    NSString *recordCommand = @"Stop recording dummy";
    return [recordCommand dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - Packet Creation Methods

//- (void)createLiveModeBeginRecordingPacket:(char *)packet {
//    packet[19] = JRLiveMode;
//    packet[18] = JRBeginRecording;
//    for (int i = 0; i < 18; i++) {
//        packet[i] = JRZeroPadding;
//    }
//}
//
//
//- (void)createLiveModeEndRecordingPacket:(char *)packet {
//    packet[19] = JRLiveMode;
//    packet[18] = JREndRecording;
//    for (int i = 0; i < 18; i++) {
//        packet[i] = JRZeroPadding;
//    }
//}
//
//
//- (void)createMoveLeftPacket:(char *)packet speed:(int)speed {
//    packet[19] = JRLiveMode;
//    packet[18] = JRMoveLeft;
//    packet[17] = speed;
//    for (int i = 0; i < 17; i++) {
//        packet[i] = JRZeroPadding;
//    }
//}
//
//
//- (void)createMoveRightPacket:(char *)packet speed:(int)speed {
//    packet[19] = JRLiveMode;
//    packet[18] = JRMoveRight;
//    packet[17] = speed;
//    for (int i = 0; i < 17; i++) {
//        packet[i] = JRZeroPadding;
//    }
//}



#pragma  mark - BluetoothInterface Delegate Methods

/*--------------------------------------------------------------------------------------------------
 *
 *                                 BLEInterface Delegate Methods
 *
 *------------------------------------------------------------------------------------------------*/

- (void)BLEInterfaceWillScanForPeripherals:(BLEInterface *)BLEInterface {
    self.status = kScanning;
    self.previouslyDiscoveredHermesControllersCount = self.discoveredHermesControllers.count;
    [NSTimer scheduledTimerWithTimeInterval:(float)scanTimeoutSecond
                                     target:self
                                   selector:@selector(scanTimer)
                                   userInfo:nil
                                    repeats:NO];
}

//- (void)BLEInterfaceDidEndScanForPeripherals:(BLEInterface *)BLEInterface {
//    NSLog(@"BLEInterfaceDidEndScanForPeripherals method");
//}

- (void)BLEInterface:(BLEInterface *)BLEInterface didDiscoverPeripheral:(CBPeripheral *)peripheral
   advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSDictionary *newlyDiscoveredPeripheral = @{@"peripheral"        : peripheral,
                                                @"advertisementData" : advertisementData,
                                                @"RSSI"              : RSSI};
    
    // Add to discoveredHermesControllers -> KVO notification triggers user prompt to connect
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:0 forKey:@"discoveredHermesControllers"]; //*** Manual invokation of KVO notifications.  Does it work?!
    [self.discoveredHermesControllers insertObject:newlyDiscoveredPeripheral atIndex:0];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:0 forKey:@"discoveredHermesControllers"]; //***
}

-(void)BLEInterface:(BLEInterface *)BLEInterface willConnectToPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connceting to peripheral %@", peripheral.name);
    self.status = kConnecting;
}

- (void)BLEInterface:(BLEInterface *)BLEInterface didConnectPeripheral:(CBPeripheral *)peripheral {
    // If here, peripheral is connected and Rx and Tx characteristics have been initialized in BluetoothInterface
    NSLog(@"HermesControllerManager connected to %@", peripheral.name);
    self.status = kConnected;
}


- (void)BLEInterface:(BLEInterface *)BLEInterface didFailToConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"HermesControllerManager failed to connect to %@", peripheral.name);
    self.status = kConnectionFailed;
}


- (void)BLEInterface:(BLEInterface *)BLEInterface didDisconnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"HermesControlManager was disconnected from %@", peripheral.name);
    self.status = kDisconnected;
}

@end
