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

typedef NS_ENUM(NSInteger, VMHRxCommands) {
    VMHRxCommandCurrentPosition  = 0x00,
    VMHRxCommandCurrentProgress  = 0x01,
    VMHRxCommandError            = 0x02,
};

typedef NS_ENUM(NSInteger, VMHPacketPositions) {
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

// Output Methods
- (void)printPacket:(BOOL)pretty;
- (NSData *)dataFormat;

// Packet Configuration Methods
- (void)configureRecordingPacketWithStatus:(RecordStatus)status;
- (void)configureMovementPacketWithDirection:(MovementDirection)direction;
- (void)configureMovementPacketWithDirection:(MovementDirection)direction
                             maxSpeedPercent:(NSInteger)speedPercent
                              dampingPercent:(NSInteger)dampingPercent;
- (void)configureSetPositionPacket;
- (BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSInteger)durationSeconds
                                     startPositionSteps:(NSInteger)startPositionSteps
                                       endPositionSteps:(NSInteger)endPositionSteps
                                         dampingPercent:(NSInteger)dampingPercent
                                                   loop:(BOOL)loop;
- (void)configureTimeLapseModeEndRecordingPacket;
- (BOOL)configureStopMotionModePacketWithDurationSeconds:(NSInteger)totalDurationSeconds
                                      startPositionSteps:(NSInteger)startPositionSteps
                                        endPositionSteps:(NSInteger)endPositionSteps
                                          dampingPercent:(NSInteger)dampingPercent
                                  captureIntervalSeconds:(NSInteger)captureIntervalSeconds;
- (void)configureStopMotionModeEndRecordingPacket;

@end
