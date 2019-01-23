//
//  NSData+Expand.m
//  gxclient-ios
//
//  Created by David Lan on 2019/1/22.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "NSData+Expand.h"

@implementation NSData (Expand)

- (NSString *)hexString{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    if(!dataBuffer){
        return [NSString string];
    }
    NSUInteger dataLength = [self length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0 ; i < dataLength ; ++i){
        [hexString appendString:[NSString stringWithFormat:@"%02lx",(unsigned long)dataBuffer[i]]];
    }
    return [NSString stringWithString:hexString];
}

-(NSString *)binaryString{
    static const unsigned char mask = 0x01;
    NSMutableString *str = [NSMutableString stringWithString:
                            @"0          1          2           3\n"
                            @"01234567 89012345 67890123 45678901\n"
                            @"-----------------------------------\n"];
    NSUInteger length = self.length;
    const unsigned char* bytes = self.bytes;
    for (NSUInteger offset = 0; offset < length; offset++) {
        if (offset > 0) {
            if (offset % 4 == 0) {
                [str appendString:@"\n"];
            }
            else {
                [str appendString:@" "];
            }
        }
        for (char bit = 7; bit >= 0; bit--) {
            if ((mask << bit) & *(bytes+offset)) {
                [str appendString:@"1"];
            }
            else {
                [str appendString:@"0"];
            }
        }
    }
    return [str copy];
}

-(NSArray *)hexToBitArray{
    NSMutableArray *bitArray = [NSMutableArray arrayWithCapacity:(int)self.length * 8];
    NSString *hexStr = [self hexString];
    for(NSUInteger i = 0 ; i < [hexStr length] ; i++){
        NSString *bin = [self hexToBinary:[hexStr characterAtIndex:i]];
        
        for(NSUInteger j = 0 ; j < bin.length ; j++){
            [bitArray addObject:@([[NSString stringWithFormat:@"%C",[bin characterAtIndex:j]] intValue])];
        }
        
    }
    return [NSArray arrayWithArray:bitArray];
}

- (NSString *)hexToBinary:(unichar)value{
    switch (value){
        case '0': return @"0000";
        case '1': return @"0001";
        case '2': return @"0010";
        case '3': return @"0011";
        case '4': return @"0100";
        case '5': return @"0101";
        case '6': return @"0110";
        case '7': return @"0111";
        case '8': return @"1000";
        case '9': return @"1001";
        case 'a':
        case 'A':
            return @"1010";
        case 'b':
        case 'B':
            return @"1011";
        case 'c':
        case 'C':
            return @"1100";
        case 'd':
        case 'D':
            return @"1101";
        case 'e':
        case 'E':
            return @"1110";
        case 'f':
        case 'F':
            return @"1111";
            
    }
    return @"-1";
}
@end
