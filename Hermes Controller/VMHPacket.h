//
//  Packet.h
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RecordStatus){ 
    RecordingBegin,
    RecordingEnd,
};

typedef NS_ENUM(NSUInteger, MovementDirection) {
    MovementLeft,
    MovementRight,
    MovementStop,
};

typedef NS_ENUM(NSUInteger, VMHRxCommands) {
    VMHRxCommandCurrentPosition  = 0x00,
    VMHRxCommandCurrentProgress  = 0x01,
    VMHRxCommandError            = 0x02,
};

typedef NS_ENUM(NSUInteger, VMHPacketPositions) {
    VMHPacketModeIndex       = 0,
    VMHPacketCommandIndex    = 1,
    VMHPacketParam1Index     = 2, // 2 bytes long
    VMHPacketParam2Index     = 4, // 2 bytes long
    VMHPacketParam3Index     = 6, // 2 bytes long
    VMHPacketParam4Index     = 8,
    VMHPacketParam5Index     = 9,
};

extern const int kPacketByteLength;


@interface VMHPacket : NSObject

- (id)initWithData:(NSData *)data;

// Output Methods


- (void)printPacket:(BOOL)pretty;
- (NSData *)dataFormat;
- (int)mode;
- (int)command;
- (int)parameter1;
- (int)parameter2;

// Packet Configuration Methods
- (void)configureRecordingPacketWithStatus:(RecordStatus)status;
- (void)configureMovementPacketWithDirection:(MovementDirection)direction;
- (void)configureMovementPacketWithDirection:(MovementDirection)direction
                             maxSpeedRPM:(NSUInteger)speedRPM
                              dampingPercent:(NSUInteger)dampingPercent;
- (void)configureSetPositionPacket;
- (BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSUInteger)durationSeconds
                                     startPositionSteps:(NSUInteger)startPositionSteps
                                       endPositionSteps:(NSUInteger)endPositionSteps
                                         dampingPercent:(NSUInteger)dampingPercent
                                                   loop:(BOOL)loop;
- (void)configureTimeLapseModeEndRecordingPacket;
- (BOOL)configureStopMotionModePacketWithDurationSeconds:(NSUInteger)totalDurationSeconds
                                      startPositionSteps:(NSUInteger)startPositionSteps
                                        endPositionSteps:(NSUInteger)endPositionSteps
                                          dampingPercent:(NSUInteger)dampingPercent
                                  captureIntervalSeconds:(NSUInteger)captureIntervalSeconds;
- (void)configureStopMotionModeEndRecordingPacket;

@end
