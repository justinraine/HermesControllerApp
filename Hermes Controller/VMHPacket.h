//
//  Packet.h
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int kPacketByteLength;

@interface VMHPacket : NSObject

// Output Methods
- (void)printPacket;
- (NSData *)dataFormat;

// Packet Configuration Methods
- (void)configureLiveModeBeginRecordingPacket;
- (void)configureLiveModeEndRecordingPacket;
- (BOOL)configureLiveModeMoveLeftPacketWithSpeedPercent:(NSInteger)speedPercent;
- (BOOL)configureLiveModeMoveRightPacketWithSpeedPercent:(NSInteger)speedPercent;
- (BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSInteger)durationSeconds
                                     startPositionSteps:(NSInteger)startPositionSteps
                                       endPositionSteps:(NSInteger)endPositionSteps
                                         dampingPercent:(NSInteger)dampingPercent
                                                 repeat:(BOOL)repeat;
- (void)configureTimeLapseModeEndRecordingPacket;
- (BOOL)configureStopMotionModePacketWithCaptureIntervalSeconds:(NSInteger)captureIntervalSeconds
                                             startPositionSteps:(NSInteger)startPositionSteps
                                               endPositionSteps:(NSInteger)endPositionSteps
                                                 dampingPercent:(NSInteger)dampingPercent;
- (void)configureStopMotionModeEndRecordingPacket;

@end
