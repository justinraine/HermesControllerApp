//
//  Packet.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHPacket.h"

typedef NS_ENUM(NSInteger, VMHModes) {
    VMHModeGeneral = 0x00,
    VMHModeTimeLapse = 0x01,
    VMHModeStopMotion = 0x02,
};

typedef NS_ENUM(NSInteger, VMHCommands) {
    VMHCommandBeginRecording = 0x00,
    VMHCommandEndRecording = 0x01,
    VMHCommandMoveLeft = 0x02,
    VMHCommandMoveRight = 0x03,
    VMHCommandMoveStop = 0x04,
};

const int kPacketByteLength = 12;
const int kModePosition = 0;
const int kCommandPosition = 1;
const int kParam1Position = 2;
const int kParam2Position = 4;
const int kParam3Position = 6;
const int kParam4Position = 8;
const int kParam5Position = 9;


@interface VMHPacket()

@property (nonatomic, strong) NSMutableArray *data; // Array of NSNumbers, each element storing a byte of the packet

@end


@implementation VMHPacket

#pragma mark - Lifecycle Methods

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


- (void)printPacketPretty {
//    NSString *mode;
//    NSString *command;
//    NSString *instantaneousSpeed;
//    
//    if ([self.data[0] integerValue] == 0) {
//        mode = @"Live Mode";
//        
//    } else if ([self.data[0] integerValue] == 1) {
//        mode = @"Time Lapse Mode";
//    } else if ([self.data[0] integerValue] == 2) {
//        mode = @"Stop Motion Mode";
//    } else {
//        mode = @"Unknown Mode";
//    }
//    
//    if ([self.data[1] integerValue] == 0) {
//        command = @"Begin Recording";
//    } else if ([self.data[1] integerValue] == 1) {
//        command  = @"End Recording";
//    } else if ([self.data[1] integerValue] == 2) {
//        command = @"Move Left";
//    } else if ([self.data[1] integerValue] == 3) {
//        command = @"Move Right";
//    } else {
//        command = @"Unknown Command";
//    }
//    
//    if ([self.data[0] integerValue] == 0) {
//        mode = @"Live Mode";
//    } else if ([self.data[0] integerValue] == 1) {
//        mode = @"Time Lapse Mode";
//    } else if ([self.data[0] integerValue] == 2) {
//        mode = @"Stop Motion Mode";
//    } else {
//        mode = @"Unknown Mode";
//    }
//    
//    NSLog(@"\n\n*** Packet ***\n\n");
//    NSLog(@"Mode: ");
//
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

- (void)configureRecordingPacketWithStatus:(RecordStatus)status {
    [self.data removeAllObjects];
    
    // Configure packet
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    if (status == RecordingBegin) {
        [self.data insertObject:[NSNumber numberWithInt:VMHCommandBeginRecording] atIndex:kCommandPosition];
    } else {
        [self.data insertObject:[NSNumber numberWithInt:VMHCommandEndRecording] atIndex:kCommandPosition];
    }
    [self padRemainderOfPacket];
}


- (void)configureMovementPacketWithDirection:(MovementDirection)direction {
    [self.data removeAllObjects];
    
    // Configure packet
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    if (direction == MovementLeft) {
        [self.data insertObject:[NSNumber numberWithInt:VMHCommandMoveLeft] atIndex:kCommandPosition];
    } else if (direction == MovementRight) {
        [self.data insertObject:[NSNumber numberWithInt:VMHCommandMoveRight] atIndex:kCommandPosition];
    } else {
        [self.data insertObject:[NSNumber numberWithInt:VMHCommandMoveStop] atIndex:kCommandPosition];
    }
    [self padRemainderOfPacket];
}

/*
- (void)configureLiveModeBeginRecordingPacket {
    [self.data removeAllObjects];
    
    // Configure packet
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandBeginRecording] atIndex:kCommandPosition];
    [self padRemainderOfPacket];
}


- (void)configureLiveModeEndRecordingPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandEndRecording] atIndex:kCommandPosition];
    
    [self padRemainderOfPacket];
}


- (BOOL)configureLiveModeMoveLeftPacketWithSpeedPercent:(NSInteger)speedPercent {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandMoveLeft] atIndex:kCommandPosition];
    
    if (speedPercent > 0 || speedPercent<= 100) {
        [self.data insertObject:[NSNumber numberWithInteger:speedPercent] atIndex:kParam1Position];
    } else {
        NSLog(@"Speed must be specified as a percentage from 1 to 100");
        return NO;
    }
    
    [self padRemainderOfPacket];
    
    return YES;
}


- (BOOL)configureLiveModeMoveRightPacketWithSpeedPercent:(NSInteger)speedPercent {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandMoveRight] atIndex:kCommandPosition];
    
    if (speedPercent > 0 || speedPercent <= 100) {
        [self.data insertObject:[NSNumber numberWithInteger:speedPercent] atIndex:kParam1Position];
    } else {
        NSLog(@"Speed must be specified as a percentage from 1 to 100");
        return NO;
    }
    
    [self padRemainderOfPacket];
    
    return YES;
}
 */


-(BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSInteger)durationSeconds
                                    startPositionSteps:(NSInteger)startPositionSteps
                                      endPositionSteps:(NSInteger)endPositionSteps
                                        dampingPercent:(NSInteger)dampingPercent
                                                  loop:(BOOL)loop {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeTimeLapse] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandBeginRecording] atIndex:kCommandPosition];
    
    if (![self setParametersForPacket:self.data
                      durationSeconds:durationSeconds
                   startPositionSteps:startPositionSteps
                     endPositionSteps:endPositionSteps
                       dampingPercent:dampingPercent]) {
        return NO;
    }
    
    [self.data insertObject:[NSNumber numberWithBool:loop] atIndex:kParam5Position];
    
    [self padRemainderOfPacket];
    
    return YES;
}


- (void)configureTimeLapseModeEndRecordingPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeTimeLapse] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandEndRecording] atIndex:kCommandPosition];
    
    [self padRemainderOfPacket];
}


- (BOOL)configureStopMotionModePacketWithCaptureIntervalSeconds:(NSInteger)captureIntervalSeconds
                                             startPositionSteps:(NSInteger)startPositionSteps
                                               endPositionSteps:(NSInteger)endPositionSteps
                                                 dampingPercent:(NSInteger)dampingPercent {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeStopMotion] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandBeginRecording] atIndex:kCommandPosition];
    
    
    if (![self setParametersForPacket:self.data
                      durationSeconds:captureIntervalSeconds
                   startPositionSteps:startPositionSteps
                     endPositionSteps:endPositionSteps
                       dampingPercent:dampingPercent]) {
        // set parameters failed
        return NO;
    }
    
    [self padRemainderOfPacket];
    
    return YES;
}


- (void)configureStopMotionModeEndRecordingPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeStopMotion] atIndex:kModePosition];
    [self.data insertObject:[NSNumber numberWithInt:VMHCommandEndRecording] atIndex:kCommandPosition];
    
    [self padRemainderOfPacket];
}



#pragma mark - Private Methods

- (BOOL)setParametersForPacket:(NSMutableArray *)packet
               durationSeconds:(NSInteger)seconds
            startPositionSteps:(NSInteger)startPositionSteps
              endPositionSteps:(NSInteger)endPositionSteps
                dampingPercent:(NSInteger)dampingPercent {
    if (seconds > 0 && seconds < 65535) {
        int16_t higherBits = (seconds & 0xFF00) >> 8;
        int16_t lowerBits = seconds & 0x00FF;
        
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam1Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam1Position+1];
    } else {
        NSLog(@"Error: Duration must be between 1 and 65 534 seconds");
        return NO;
    }
    
    if (startPositionSteps >= 0 && startPositionSteps < 65535) {
        int16_t higherBits = (startPositionSteps & 0xFF00) >> 8;
        int16_t lowerBits = startPositionSteps & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam2Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam2Position+1];
    } else {
        NSLog(@"Error: Start position must be between 0 and 65 534 steps");
        return NO;
    }
    
    if (endPositionSteps >= 0 && endPositionSteps < 65535) {
        int16_t higherBits = (endPositionSteps & 0xFF00) >> 8;
        int16_t lowerBits = endPositionSteps & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:kParam3Position];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:kParam3Position+1];
    } else {
        NSLog(@"Error: End position must be between 0 and 65 534 steps");
        return NO;
    }
    
    if (dampingPercent >= 0 && dampingPercent <= 100) {
        [packet insertObject:[NSNumber numberWithInteger:dampingPercent] atIndex:kParam4Position];
    } else {
        NSLog(@"Error: Damping must be a percent between 0 and 100");
        return NO;
    }
    
    return YES;
}

// Fills nil elements in data array with zeros and appends 0xFFFF to end of packet to signal End of Packet
- (void)padRemainderOfPacket{
    NSNumber *zero = [NSNumber numberWithInt:0x00];
    for (int i = 0; i < kPacketByteLength-2; i++) {
        if (self.data.count <= i) {
            [self.data insertObject:zero atIndex:i];
        }
    }
    
    // End of packet denoted by 0xFF FF
    self.data[kPacketByteLength-2] = [NSNumber numberWithInt:0xFF];
    self.data[kPacketByteLength-1] = [NSNumber numberWithInt:0xFF];
}

@end
