//
//  BluetoothInterface.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-09.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothInterfaceDelegateProtocol;


@interface BluetoothInterface1 : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

// Public properties
@property CBCentralManager *centralManager; // Responsible for scanning and connecting to peripherals
@property CBPeripheral *connectedPeripheral;

// Public methods
- (id)initWithDelegate:(id)delegate;
- (BOOL)isReadyForCommand;
- (BOOL)beginScanForPeripheralWithServices:(NSArray *)services;
- (BOOL)endScanForPeripherals;
- (BOOL)connectToPeripheral:(CBPeripheral *)peripheral;
- (void)writeString:(NSString *)string;

// Methods copied from BLEAdapter
-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p on:(BOOL)on;

-(UInt16) swap:(UInt16) s;
-(int) controlSetup:(int) s;
//-(int) findBLEPeripherals:(int) timeout;
-(const char *) centralManagerStateToString:(int)state;
//-(void) scanTimer:(NSTimer *)timer;
//-(void) printKnownPeripherals;
-(void) printPeripheralInfo:(CBPeripheral*)peripheral;
//-(void) connectPeripheral:(CBPeripheral *)peripheral status:(BOOL)status;
-(NSString *)GetServiceName:(CBUUID *)UUID;
-(void) getAllCharacteristicsForService:(CBPeripheral *)p service:(CBService *)s;
-(void) getAllServicesFromPeripheral:(CBPeripheral *)p;
-(void) getAllCharacteristicsFromPeripheral:(CBPeripheral *)p;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(NSString *) CBUUIDToNSString:(CBUUID *) UUID;  // see CBUUID UUIDString in iOS 7.1
-(const char *) UUIDToString:(NSUUID *) UUID;
-(const char *) CBUUIDToString:(CBUUID *) UUID;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(int) compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;

@end


// ***
// *** Protocol Declaration
// ***
@protocol BluetoothInterfaceDelegateProtocol <NSObject>
@required
- (void)bluetoothInterface:(BluetoothInterface1 *)bluetoothInterface
     didDiscoverPeripheral:(CBPeripheral *)peripheral
         advertisementData:(NSDictionary *)advertisementData
                      RSSI:(NSNumber *)RSSI;

- (void)bluetoothInterface:(BluetoothInterface1 *)bluetoothInterface
      didConnectPeripheral:(CBPeripheral *)peripheral;

- (void)bluetoothInterface:(BluetoothInterface1 *)bluetoothInterface
didFailToConnectPeripheral:(CBPeripheral *)peripheral;

- (void)bluetoothInterface:(BluetoothInterface1 *)bluetoothInterface
   didDisconnectPeripheral:(CBPeripheral *)peripheral;

@end