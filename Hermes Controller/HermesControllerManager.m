//
//  HermesControllerManager.m
//  HermesController
//
//  Created by Justin Raine on 2015-03-10.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "HermesControllerManager.h"
#import "Constants.h"
#import "BLEInterface.h"

@interface HermesControllerManager()

@property (strong, nonatomic) BLEInterface *BLEInterface;
@property ControllerStatus status;
@property NSUInteger previouslyDiscoveredHermesControllersCount;

@end


@implementation HermesControllerManager

static int scanTimeoutSecond = 5; // CBCentralManager scan timeout duration
//@synthesize status;

- (id)init {
    self = [super init];
    
    if (self) {
        self.BLEInterface = [[BLEInterface alloc] initWithDelegate:self];
        self.status = kIdle; //*** necessary?
    }
    
    return self;
}


#pragma mark - Public Methods

+ (HermesControllerManager *)sharedInstance {
    static HermesControllerManager *sharedInstance;
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


- (void)beginRecording {
    if (self.status == kConnected) {
        [self.BLEInterface writeValue:kUARTServiceUUIDInt
                   characteristicUUID:kTransmitCharacteristicUUIDInt
                                    p:self.BLEInterface.connectedPeripheral
                                 data:[self createRecordStartCommand]];
    }
}


- (void)stopRecording {
    if (self.status == kConnected) {
        [self.BLEInterface writeValue:kUARTServiceUUIDInt
                   characteristicUUID:kTransmitCharacteristicUUIDInt
                                    p:self.BLEInterface.connectedPeripheral
                                 data:[self createRecordStopCommand]];
    }
}



#pragma mark – Create Command Methods

- (NSData *)createRecordStartCommand {
    NSString *recordCommand = @"Start the recording!";
    return [recordCommand dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)createRecordStopCommand {
    NSString *recordCommand = @"Stop recording dummy";
    return [recordCommand dataUsingEncoding:NSUTF8StringEncoding];
}



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
    [self.discoveredHermesControllers insertObject:newlyDiscoveredPeripheral atIndex:0];
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
