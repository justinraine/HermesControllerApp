//
//  Constants.h
//  HermesController
//
//  Created by Justin Raine on 2015-03-09.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#ifndef HermesController_Constants_h
#define HermesController_Constants_h

#import <Foundation/Foundation.h>

// Used to generate CBUUIDs
extern NSString *const kUARTServiceUUIDString;
extern NSString *const kTransmitCharacteristicUUIDString;
extern NSString *const kReceiveCharacteristicUUIDString;

// Used for BLEInterface calls which request the UUID of service/characteristic in integer format
extern int const kUARTServiceUUIDInt;
extern int const kTransmitCharacteristicUUIDInt;
extern int const kReceiveCharacteristicUUIDInt;

#endif