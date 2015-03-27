//
//  BLEInterface.h
//  HermesControllerApp
//
//  Adapted version of BLEAdapter - Copyright (c) 2013 Bluetooth SIG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "constants.h"

//NSString *const kBLEAdapterCommandReadyDidChangeNotification = @"readyChangeNotification";


@protocol BLEAdapterDelegate
@optional
-(void) OnDiscoverServices:(NSArray *)s;
-(void) OnConnected:(BOOL)status;
@end





@interface BLEInterface : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

// Public Properties
@property (nonatomic, strong) NSMutableArray *peripherals;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *activePeripheral;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;


- (id)initWithDelegate:(id)delegate;
- (void)beginScanForPeripheralWithServices:(NSArray *)services;
- (void)endScanForPeripherals;
- (void)connectToPeripheral:(CBPeripheral *)peripheral;


// Peripheral Setup, Discovery, and Connection Methods
//+ (BLEInterface *)sharedBLEAdapter;
//- (void)controlSetup;
- (int)findBLEPeripheralsWithServices:(NSArray *)services timeout:(int)timeout;
- (void)scanTimer:(NSTimer *)timer;
- (void)connectPeripheral:(CBPeripheral *)peripheral status:(BOOL)status;


// Peripheral Interation Methods
- (void)writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;
- (void)readValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p;
- (void)notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on;


// Get Methods
- (void)getAllCharacteristicsForService:(CBPeripheral *)p service:(CBService *)s;
- (void)getAllServicesFromPeripheral:(CBPeripheral *)p;
- (void)getAllCharacteristicsFromPeripheral:(CBPeripheral *)p;
- (NSString *)getServiceName:(CBUUID *)UUID;


// Print Methods
- (void)printKnownPeripherals;
- (void)printPeripheralInfo:(CBPeripheral*)peripheral;


// Helper Methods
- (const char *)centralManagerStateToString:(int)state;
- (UInt16)swap:(UInt16) s;
- (CBService *)findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
- (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
- (int)compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
- (int)compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
- (NSString *)CBUUIDToNSString:(CBUUID *) UUID;  // see CBUUID UUIDString in iOS 7.1
- (const char *)UUIDToString:(NSUUID *) UUID;
- (const char *)CBUUIDToString:(CBUUID *) UUID;
- (UInt16)CBUUIDToInt:(CBUUID *) UUID;

@end




// ***
// *** Protocol Declaration
// ***
@protocol BLEInterfaceDelegateProtocol <NSObject>

@optional
- (void)BLEInterfaceWillScanForPeripherals:(BLEInterface *)BLEInterface;

- (void)BLEInterfaceDidEndScanForPeripherals:(BLEInterface *)BLEInterface;

- (void)BLEInterface:(BLEInterface *)BLEInterface didDiscoverPeripheral:(CBPeripheral *)peripheral
   advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)BLEInterface:(BLEInterface *)BLEInterface willConnectToPeripheral:(CBPeripheral *)peripheral;

- (void)BLEInterface:(BLEInterface *)BLEInterface didConnectPeripheral:(CBPeripheral *)peripheral;

- (void)BLEInterface:(BLEInterface *)BLEInterface didFailToConnectPeripheral:(CBPeripheral *)peripheral;

- (void)BLEInterface:(BLEInterface *)BLEInterface didDisconnectPeripheral:(CBPeripheral *)peripheral;

@end
