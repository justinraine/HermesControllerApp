//
//  VMHCentral.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-31.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHCentral.h"

@interface VMHCentral()

@property (nonatomic, strong) id delegate;

@end

@implementation VMHCentral

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}

- (void) centralManagerDidUpdateState:(CBCentralManager *)central {
    self.delegate.readyForCommand = NO;
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            self.readyForCommand = YES;
            
            if (self.waitingToScanForServices) {
                NSLog(@"Queued request to scan found -- attempting to begin scan...");
                [self beginScanForPeripheralWithServices:self.waitingToScanForServices];
                self.waitingToScanForServices = nil;
            } else if (self.waitingToConnectToPeripheral) {
                NSLog(@"Queued connection request found -- attempting to connect...");
                [self connectToPeripheral:self.waitingToConnectToPeripheral];
                self.waitingToConnectToPeripheral = nil;
            }
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            NSLog(@"Error: Could not determine CoreBluetooth BLE state");
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    self.peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"didDiscoverPeripheral");
    
    if ([self.delegate respondsToSelector:@selector(BLEInterface:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        [self.delegate BLEInterface:self didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    printf("Connection to peripheral with UUID : %s successfull\r\n",[[[peripheral identifier] UUIDString] UTF8String]);
    self.activePeripheral = peripheral;
    
    //    if(dvController)
    //    {
    //        [(DeviceViewController *) [self dvController] OnConnected:TRUE];
    //    }
    
    //[self.activePeripheral discoverServices:nil];
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
    printf("Failed to connect to peripheral %s\r\n",[[[peripheral identifier] UUIDString] UTF8String]);
    self.activePeripheral = peripheral;
    
    //    if(dvController)
    //    {
    //        [(DeviceViewController *) [self dvController] OnConnected:FALSE];
    //    }
    
    //[self.activePeripheral discoverServices:nil];
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"KeyfobViewController didDisconnectPeripheral");
    
    //    if(dvController)
    //    {
    //        [(DeviceViewController *) [self dvController] OnConnected:FALSE];
    //    }
}

@end
