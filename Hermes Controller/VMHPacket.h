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
- (BOOL)configureLiveModeMoveLeftPacketWithSpeed:(int)speedPercent;
- (BOOL)configureLiveModeMoveRightPacketWithSpeed:(int)speedPercent;
- (BOOL)configureTimeLapseModePacketWithDuration:(int)durationSeconds
                                  startPosition:(int)startPositionSteps
                                    endPosition:(int)endPositionSteps
                                        damping:(int)dampingPercent
                                           loop:(BOOL)loop;
- (void)configureTimeLapseModeEndRecordingPacket;
- (BOOL)configureStopMotionModePacketWithCaptureInterval:(int)seconds
                                          startPosition:(int)startPositionSteps
                                            endPosition:(int)endPositionSteps
                                                damping:(int)dampingPercent;
- (void)configureStopMotionModeEndRecordingPacket;

@end
