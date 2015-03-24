//
//  Packet.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHPacket.h"

typedef NS_ENUM(NSInteger, VMHModes) {
    VMHLiveMode = 0x00,
    VMHTimeLapseMode = 0x01,
    VMHStopMotionMode = 0x02,
};

typedef NS_ENUM(NSInteger, VMHCommands) {
    VMHBeginRecording = 0x00,
    VMHEndRecording = 0x01,
    VMHMoveLeft = 0x02,
    VMHMoveRight = 0x03,
    VMHZeroPadding = 0x00,
};

const int kPacketByteLength = 20;
const int kModePosition = 0;
const int kCommandPosition = 1;
const int kParam1Position = 2;
const int kParam2Position = 4;
const int kParam3Position = 6;
const int kParam4Position = 8;
const int kParam5Position = 9;


@interface VMHPacket()

@property (strong, nonatomic) NSMutableArray *data;

@end


@implementation VMHPacket

#pragma mark - Utility Methods

- (id)init {
    self = [super init];
    
    if (self) {
        self.data = [NSMutableArray arrayWithCapacity:kPacketByteLength];
    }
    
    return self;
}



#pragma mark - Output Methods

- (void)printPacket {
    NSString *packetString = @"";
    
    for (int i = 0; i < kPacketByteLength; i++) {
        NSString *nextByte = [NSString stringWithFormat:@"%02lX ", (long)[self.data[i] integerValue]];
        packetString = [packetString stringByAppendingString:nextByte];
    }
    
    NSLog(@"Command Packet: %@\n\n", packetString);
}


- (NSData *)dataFormat {
    // Transfer self.data array of bytes into packetString
    NSString *packetString = @"";
    for (int i = 0; i < kPacketByteLength; i++) {
        NSString *nextByte = [NSString stringWithFormat:@"%02lX", (long)[self.data[i] integerValue]];
        packetString = [packetString stringByAppendingString:nextByte];
    }
    
    // Create an NSData object from packetString
    NSMutableData *packetData= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i = 0; i < kPacketByteLength; i++) {
        byte_chars[0] = [packetString characterAtIndex:i*2];
        byte_chars[1] = [packetString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [packetData appendBytes:&whole_byte length:1];
    }
    
    return packetData;
}



#pragma mark - Packet Configuration Methods

- (void)configureLiveModeBeginRecordingPacket {
    [self.data insertObject:[NSNumber numberWithInt:VMHLiveMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHBeginRecording] atIndex:kCommandPosition];
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kCommandPosition+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
}


- (void)configureLiveModeEndRecordingPacket {
    [self.data insertObject:[NSNumber numberWithInt:VMHLiveMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHEndRecording] atIndex:kCommandPosition];
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kCommandPosition+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
}


- (BOOL)configureLiveModeMoveLeftPacketWithSpeed:(int)speedPercent {
    [self.data insertObject:[NSNumber numberWithInt:VMHLiveMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHMoveLeft] atIndex:kCommandPosition];
    if (speedPercent > 0 || speedPercent<= 100) {
        [self.data insertObject:[NSNumber numberWithInt:speedPercent] atIndex:kParam1Position];
    } else {
        NSLog(@"Speed must be specified as a percentage from 0 to 100");
        return NO;
    }
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kParam1Position+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
    
    return YES;
}


- (BOOL)configureLiveModeMoveRightPacketWithSpeed:(int)speedPercent {
    [self.data insertObject:[NSNumber numberWithInt:VMHLiveMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHMoveRight] atIndex:kCommandPosition];
    if (speedPercent > 0 || speedPercent<= 100) {
        [self.data insertObject:[NSNumber numberWithInt:speedPercent] atIndex:kParam1Position];
    } else {
        NSLog(@"Speed must be specified as a percentage from 0 to 100");
        return NO;
    }
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kParam1Position+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
    
    return YES;
}


-(BOOL)configureTimeLapseModePacketWithDuration:(int)durationSeconds
                                 startPosition:(int)startPositionSteps
                                   endPosition:(int)endPositionSteps
                                       damping:(int)dampingPercent
                                          loop:(BOOL)loop {
    [self.data insertObject:[NSNumber numberWithInt:VMHTimeLapseMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHBeginRecording] atIndex:kCommandPosition];
    
    if (![self setParametersForPacket:self.data duration:durationSeconds startPosition:startPositionSteps endPosition:endPositionSteps damping:dampingPercent]) {
        return NO;
    }
    
    [self.data insertObject:[NSNumber numberWithBool:loop] atIndex:kParam5Position];
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kParam5Position+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
    
    return YES;
}


- (void)configureTimeLapseModeEndRecordingPacket {
    [self.data insertObject:[NSNumber numberWithInt:VMHTimeLapseMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHEndRecording] atIndex:kCommandPosition];
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kCommandPosition+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
}


- (BOOL)configureStopMotionModePacketWithCaptureInterval:(int)seconds startPosition:(int)startPositionSteps endPosition:(int)endPositionSteps damping:(int)dampingPercent {
    [self.data insertObject:[NSNumber numberWithInt:VMHStopMotionMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHBeginRecording] atIndex:kCommandPosition];
    
    if (![self setParametersForPacket:self.data duration:seconds startPosition:startPositionSteps endPosition:endPositionSteps damping:dampingPercent]) {
        // set parameters failed
        return NO;
    }
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kParam4Position+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
    
    return YES;
}


- (void)configureStopMotionModeEndRecordingPacket {
    [self.data insertObject:[NSNumber numberWithInt:VMHStopMotionMode] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHEndRecording] atIndex:kCommandPosition];
    
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = kCommandPosition+1; i < kPacketByteLength; i++) {
        [self.data insertObject:zero atIndex:i];
    }
}



#pragma mark - Helper Function

- (BOOL)setParametersForPacket:(NSMutableArray *)packet duration:(int)seconds startPosition:(int)startPositionSteps endPosition:(int)endPositionSteps damping:(int)dampingPercent {
    if (seconds > 0 && seconds < 65535) {
        int16_t higherBits = (seconds & 0xFF00) >> 8;
        int16_t lowerBits = seconds & 0x00FF;
        
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam1Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam1Position+1];
    } else {
        NSLog(@"Error: Duration must be between 1 and 65 535 seconds");
        return NO;
    }
    
    if (startPositionSteps >= 0 && startPositionSteps < 65535) {
        int16_t higherBits = (startPositionSteps & 0xFF00) >> 8;
        int16_t lowerBits = startPositionSteps & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam2Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam2Position+1];
    } else {
        NSLog(@"Error: Start position must be between 0 and 65 535 steps");
        return NO;
    }
    
    if (endPositionSteps >= 0 && endPositionSteps < 65535) {
        int16_t higherBits = (endPositionSteps & 0xFF00) >> 8;
        int16_t lowerBits = endPositionSteps & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam3Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam3Position+1];
    } else {
        NSLog(@"Error: End position must be between 0 and 65 535 steps");
        return NO;
    }
    
    if (dampingPercent >= 0 && dampingPercent < 100) {
        [packet insertObject:[NSNumber numberWithInt:dampingPercent] atIndex:kParam4Position];
    } else {
        NSLog(@"Error: Damping must be a percent between 0 and 100");
        return NO;
    }
    
    return YES;
}

@end