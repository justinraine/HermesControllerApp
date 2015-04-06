//
//  Packet.m
//  HermesControllerApp
//
//  Created by Justin Raine on 2015-03-23.
//  Copyright (c) 2015 vitaMotu. All rights reserved.
//

#import "VMHPacket.h"

typedef NS_ENUM(NSInteger, VMHModes) {
    VMHModeGeneral           = 0x00,
    VMHModeTimeLapse         = 0x01,
    VMHModeStopMotion        = 0x02,
};

typedef NS_ENUM(NSInteger, VMHTxCommands) {
    VMHTxCommandBeginRecording = 0x00,
    VMHTxCommandEndRecording   = 0x01,
    VMHTxCommandMoveLeft       = 0x02,
    VMHTxCommandMoveRight      = 0x03,
    VMHTxCommandMoveStop       = 0x04,
    VMHTxCommandSetPosition    = 0x05,
};

const int kPacketByteLength = 12;
const int kDefaultSpeedPercent = 50;
const int kDefaultDampingPercent = 50;


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

- (void)printPacket:(BOOL)pretty {
    // Create packet string
    NSString *packetString = @"";
    for (int i = 0; i < kPacketByteLength; i++) {
        NSString *nextByte = [NSString stringWithFormat:@"%02lX ", (long)[self.data[i] integerValue]];
        packetString = [packetString stringByAppendingString:nextByte];
    }
    
    if (!pretty) {
        NSLog(@"Command Packet: %@\n\n", packetString);
    } else {
        int mode = [self.data[VMHPacketModeIndex] intValue];
        int command = [self.data[VMHPacketCommandIndex] intValue];
        int parameter1 = ([self.data[VMHPacketParam1Index] intValue] << 8) + [self.data[VMHPacketParam1Index+1] intValue];
        int parameter2 = ([self.data[VMHPacketParam2Index] intValue] << 8) + [self.data[VMHPacketParam2Index+1] intValue];
        int parameter3 = ([self.data[VMHPacketParam3Index] intValue] << 8) + [self.data[VMHPacketParam3Index+1] intValue];
        int parameter4 = [self.data[VMHPacketParam4Index] intValue];
        int parameter5 = [self.data[VMHPacketParam5Index] intValue];
        NSString *modeString;
        NSString *commandString;
        
        // Determine Mode
        if (mode == 0x00) {
            modeString = @"Live/General";
        } else if (mode == 0x01) {
            modeString = @"Time Lapse";
        } else if (mode == 0x02) {
            modeString = @"Stop Motion";
        } else {
            modeString = @"Unknown";
        }
        
        // Determine Command
        if (command == 0x00) {
            commandString = @"Begin Recording";
        } else if (command == 0x01) {
            commandString  = @"End Recording";
        } else if (command == 0x02) {
            commandString = @"Move Left";
        } else if (command == 0x03) {
            commandString = @"Move Right";
        } else if (command == 0x04){
            commandString = @"Stop Move";
        } else {
            commandString = @"Unknown Command";
        }
        
        // Print packet
        NSLog(@"********** Packet **********");
        NSLog(@"Packet:             %@", packetString);
        NSLog(@"Mode:               %@", modeString);
        NSLog(@"Command:            %@", commandString);
        
        if (mode == 0x00) {
            if (parameter1 == 0) {
                NSLog(@"Speed:              --\n\n");
            } else {
                NSLog(@"Speed:              %d rpm\n\n", parameter1);
            }
        } else if (mode == 0x01) {
            if (command == 0x00) {
                NSLog(@"Duration:           %d seconds", parameter1);
                NSLog(@"Start Position:     Step %d", parameter2);
                NSLog(@"End Position:       Step %d", parameter3);
                NSLog(@"Damping:            %d%%", parameter4);
                if (parameter5 == 0) {
                    NSLog(@"Repeat:             Disabled\n\n");
                } else {
                    NSLog(@"Repeat:             Enabled\n\n");
                }
            } else {
                NSLog(@"Duration:           --");
                NSLog(@"Start Position:     --");
                NSLog(@"End Position:       --");
                NSLog(@"Damping:            --\n\n");
            }
        } else if (mode == 0x02) {
            if (command == 0x00) {
                NSLog(@"Total Duration:     %d seconds", parameter1);
                NSLog(@"Start Position:     %d steps", parameter2);
                NSLog(@"End Position:       %d steps", parameter3);
                NSLog(@"Damping:            %d%%", parameter4);
                NSLog(@"Capture Interval:   %d seconds\n\n", parameter5);
            } else {
                NSLog(@"Total Duration:     --");
                NSLog(@"Start Position:     --");
                NSLog(@"End Position:       --");
                NSLog(@"Damping:            --");
                NSLog(@"Capture Interval:   --\n\n");
            }
        }
    }
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

#pragma mark // Live/General Mode
- (void)configureRecordingPacketWithStatus:(RecordStatus)status {
    [self.data removeAllObjects];
    
    // Configure packet
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:VMHPacketModeIndex];
    if (status == RecordingBegin) {
        [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandBeginRecording] atIndex:VMHPacketCommandIndex];
    } else {
        [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandEndRecording] atIndex:VMHPacketCommandIndex];
    }
    [self padRemainderOfPacket];
}


- (void)configureMovementPacketWithDirection:(MovementDirection)direction {
    [self configureMovementPacketWithDirection:direction
                               maxSpeedPercent:kDefaultSpeedPercent
                                dampingPercent:kDefaultDampingPercent];
}


- (void)configureMovementPacketWithDirection:(MovementDirection)direction
                             maxSpeedPercent:(NSInteger)speedPercent
                              dampingPercent:(NSInteger)dampingPercent {
    if (speedPercent < 0 || speedPercent > 100) {
        NSLog(@"Error: maxSpeedPercent argument must be between 0 and 100");
        return;
    }
    if (dampingPercent < 0 || dampingPercent > 100) {
        NSLog(@"Error: dampingPercent argument must be between 0 and 100");
        return;
    }
    
    [self.data removeAllObjects];
    
    // Configure packet
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:VMHPacketModeIndex];
    if (direction == MovementLeft || direction == MovementRight) {
        if (direction == MovementLeft) {
            [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandMoveLeft] atIndex:VMHPacketCommandIndex];
        } else {
            [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandMoveRight] atIndex:VMHPacketCommandIndex];
        }
        
        [self.data insertObject:[NSNumber numberWithInt:0] atIndex:VMHPacketParam1Index];
        [self.data insertObject:[NSNumber numberWithInteger:speedPercent] atIndex:VMHPacketParam1Index+1];
        [self.data insertObject:[NSNumber numberWithInt:0] atIndex:VMHPacketParam2Index];
        [self.data insertObject:[NSNumber numberWithInteger:dampingPercent] atIndex:VMHPacketParam2Index+1];
    } else {
        [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandMoveStop] atIndex:VMHPacketCommandIndex];
    }
    [self padRemainderOfPacket];
}


- (void)configureSetPositionPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeGeneral] atIndex:VMHPacketModeIndex];
    [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandSetPosition] atIndex:VMHPacketCommandIndex];
    
    [self padRemainderOfPacket];
}


#pragma mark // Time Lapse Mode

- (BOOL)configureTimeLapseModePacketWithDurationSeconds:(NSInteger)durationSeconds
                                     startPositionSteps:(NSInteger)startPositionSteps
                                       endPositionSteps:(NSInteger)endPositionSteps
                                         dampingPercent:(NSInteger)dampingPercent
                                                   loop:(BOOL)loop {
    if (dampingPercent < 0 || dampingPercent > 100) {
        NSLog(@"Error: dampingPercent argument must be between 0 and 100");
        return NO;
    }
    
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeTimeLapse] atIndex:VMHPacketModeIndex];
    [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandBeginRecording] atIndex:VMHPacketCommandIndex];
    
    if (![self setParametersForPacket:self.data
                           parameter1:durationSeconds
                           parameter2:startPositionSteps
                           parameter3:endPositionSteps
                           parameter4:dampingPercent
                           parameter5:loop]) {
        return NO;
    }
    
    [self padRemainderOfPacket];
    
    return YES;
}


- (void)configureTimeLapseModeEndRecordingPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeTimeLapse] atIndex:VMHPacketModeIndex];
    [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandEndRecording] atIndex:VMHPacketCommandIndex];
    
    [self padRemainderOfPacket];
}


#pragma mark // Stop Motion Mode

- (BOOL)configureStopMotionModePacketWithDurationSeconds:(NSInteger)totalDurationSeconds
                                      startPositionSteps:(NSInteger)startPositionSteps
                                        endPositionSteps:(NSInteger)endPositionSteps
                                          dampingPercent:(NSInteger)dampingPercent
                                  captureIntervalSeconds:(NSInteger)captureIntervalSeconds {
    if (dampingPercent < 0 || dampingPercent > 100) {
        NSLog(@"Error: dampingPercent argument must be between 0 and 100");
        return NO;
    }
    
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeStopMotion] atIndex:VMHPacketModeIndex];
    [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandBeginRecording] atIndex:VMHPacketCommandIndex];
    
    
    if (![self setParametersForPacket:self.data
                           parameter1:totalDurationSeconds
                           parameter2:startPositionSteps
                           parameter3:endPositionSteps
                           parameter4:dampingPercent
                           parameter5:captureIntervalSeconds]) {
        return NO;
    }
    
    [self padRemainderOfPacket];
    
    return YES;
}


- (void)configureStopMotionModeEndRecordingPacket {
    [self.data removeAllObjects];
    
    [self.data insertObject:[NSNumber numberWithInt:VMHModeStopMotion] atIndex:VMHPacketModeIndex];
    [self.data insertObject:[NSNumber numberWithInt:VMHTxCommandEndRecording] atIndex:VMHPacketCommandIndex];
    
    [self padRemainderOfPacket];
}



#pragma mark - Private Methods

- (BOOL)setParametersForPacket:(NSMutableArray *)packet
                    parameter1:(NSInteger)parameter1
                    parameter2:(NSInteger)parameter2
                    parameter3:(NSInteger)parameter3
                    parameter4:(NSInteger)parameter4
                    parameter5:(NSInteger)parameter5 {
    if (parameter1 >= 0 && parameter1 < 65536) {
        int16_t higherBits = (parameter1 & 0xFF00) >> 8;
        int16_t lowerBits = parameter1 & 0x00FF;
        
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:VMHPacketParam1Index];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:VMHPacketParam1Index+1];
    } else {
        NSLog(@"Error: parameter1 must be between 0 and 65 535 seconds");
        return NO;
    }
    
    if (parameter2 >= 0 && parameter2 < 65536) {
        int16_t higherBits = (parameter2 & 0xFF00) >> 8;
        int16_t lowerBits = parameter2 & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:VMHPacketParam2Index];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:VMHPacketParam2Index+1];
    } else {
        NSLog(@"Error: parameter2 must be between 0 and 65 535 steps");
        return NO;
    }
    
    if (parameter3 >= 0 && parameter3 < 65536) {
        int16_t higherBits = (parameter3 & 0xFF00) >> 8;
        int16_t lowerBits = parameter3 & 0x00FF;
        [packet insertObject:[NSNumber numberWithInt:higherBits] atIndex:VMHPacketParam3Index];
        [packet insertObject:[NSNumber numberWithInt:lowerBits] atIndex:VMHPacketParam3Index+1];
    } else {
        NSLog(@"Error: parameter3 must be between 0 and 65 535 steps");
        return NO;
    }
    
    if (parameter4 >= 0 && parameter4 < 256) {
        [packet insertObject:[NSNumber numberWithInteger:parameter4] atIndex:VMHPacketParam4Index];
    } else {
        NSLog(@"Error: parameter4 must be between 0 and 255");
        return NO;
    }
    
    if (parameter5 >= 0 && parameter5 < 256) {
        [packet insertObject:[NSNumber numberWithInteger:parameter5] atIndex:VMHPacketParam5Index];
    } else {
        NSLog(@"Error: parameter5 must be between 0 and 255");
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
