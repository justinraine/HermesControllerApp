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

extern const int kPacketByteLength;


@interface VMHPacket : NSObject

// Output Methods
- (void)printPacket;
- (void)printPacketPretty;
- (NSData *)dataFormat;

// Packet Configuration Methods
- (void)configureRecordingPacketWithStatus:(RecordStatus)status;
- (void)configureMovementPacketWithDirection:(MovementDirection)direction;
- (BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSInteger)durationSeconds
                                     startPositionSteps:(NSInteger)startPositionSteps
                                       endPositionSteps:(NSInteger)endPositionSteps
                                         dampingPercent:(NSInteger)dampingPercent
                                                   loop:(BOOL)loop;
- (void)configureTimeLapseModeEndRecordingPacket;
- (BOOL)configureStopMotionModePacketWithCaptureIntervalSeconds:(NSInteger)captureIntervalSeconds
                                             startPositionSteps:(NSInteger)startPositionSteps
                                               endPositionSteps:(NSInteger)endPositionSteps
                                                 dampingPercent:(NSInteger)dampingPercent;
- (void)configureStopMotionModeEndRecordingPacket;

@end
