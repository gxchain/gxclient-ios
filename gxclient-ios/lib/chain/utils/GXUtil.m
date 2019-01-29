//
//  GXUtil.m
//  Graphene
//
//  Created by David Lan on 2018/12/12.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonKeyDerivation.h>
#import "GXUtil.h"
#import "NSDictionary+Expand.h"
#import "BTCData.h"
#import "NSData+BTCData.h"
#import "NSData+Expand.h"
#import "GXPrivateKey.h"

static uint64_t char_to_symbol( char c ) {
    if( c >= 'a' && c <= 'z' )
        return (c - 'a') + 6;
    if( c >= '1' && c <= '5' )
        return (c - '1') + 1;
    return 0;
}

// Each char of the string is encoded into 5-bit chunk and left-shifted
// to its 5-bit slot starting with the highest slot for the first char.
// The 13th char, if str is long enough, is encoded into 4-bit chunk
// and placed in the lowest 4 bits. 64 = 12 * 5 + 4
static uint64_t string_to_name( const char* str )
{
    uint64_t name = 0;
    int i = 0;
    for ( ; str[i] && i < 12; ++i) {
        // NOTE: char_to_symbol() returns char type, and without this explicit
        // expansion to uint64 type, the compilation fails at the point of usage
        // of string_to_name(), where the usage requires constant (compile time) expression.
        name |= (char_to_symbol(str[i]) & 0x1f) << (64 - 5 * (i + 1));
    }
    
    // The for-loop encoded up to 60 high bits into uint64 'name' variable,
    // if (strlen(str) > 12) then encode str[12] into the low (remaining)
    // 4 bits of 'name'
    if (i == 12)
        name |= char_to_symbol(str[12]) & 0x0F;
    return name;
}

@implementation GXUtil

+(uint64_t) string_to_name:(NSString*)str{
    return string_to_name([str UTF8String]);
}

+(NSString*) name_to_string :(uint64_t) name{
    static const char* charmap = ".12345abcdefghijklmnopqrstuvwxyz";
    
    char str[14]= ".............\0";
    
    uint64_t tmp = name;
    for( uint32_t i = 0; i <= 12; ++i ) {
        char c = charmap[tmp & (i == 0 ? 0x0f : 0x1f)];
        str[12-i] = c;
        tmp >>= (i == 0 ? 4 : 5);
    }
    
    for( int32_t i = 12; i >= 0; --i ) {
        char c = str[i];
        if(c=='.'){
            str[i] = ' ';
        }
        else{
            break;
        }
    }
    
    return [[NSString stringWithUTF8String:str] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSArray *)dictonary{
    static dispatch_once_t onceToken;
    static NSArray* arr = nil;
    dispatch_once(&onceToken, ^{
        NSBundle* bundle = [NSBundle bundleForClass:[GXUtil class]];
        NSString * path = [bundle pathForResource:@"gxclient.bundle/dictionary" ofType:@"txt"];
        NSData * dictData = [[NSData alloc]initWithContentsOfFile:path];
        NSString * dictText = [[NSString alloc]initWithData:dictData encoding:NSUTF8StringEncoding];
        arr= [dictText componentsSeparatedByString:@","];
    });
    return arr;
}

+(JSContext*)jsContext{
    static dispatch_once_t onceToken;
    static JSContext* instance;
    dispatch_once(&onceToken, ^{
        NSBundle* bundle = [NSBundle bundleForClass:[GXUtil class]];
        NSString * path = [bundle pathForResource:@"gxclient.bundle/tx_serializer.min" ofType:@"js"];
        NSData * jsData = [[NSData alloc]initWithContentsOfFile:path];
        NSString * jsCode = [[NSString alloc]initWithData:jsData encoding:NSUTF8StringEncoding];
        instance=[[JSContext alloc] init];
        [instance evaluateScript:jsCode];
    });
    
    return instance;
}

+(NSString*) serialize_action_data:(NSString*)action params:(NSDictionary*)params abi:(NSDictionary*)abi{
    NSString* jsCode = [NSString stringWithFormat:@"serializer.serializeCallData('%@',%@,%@).toString('hex')",action, [params json],[abi json]];
    NSString* result = [[[GXUtil jsContext] evaluateScript:jsCode] toString];
    return result;
}

+(NSString*) serialize_transaction:(NSDictionary*)transaction{
    NSString* jsCode = [NSString stringWithFormat:@"serializer.serializeTransaction(%@).toString('hex')", [transaction json]];
    NSString* result = [[[GXUtil jsContext] evaluateScript:jsCode] toString];
    return result;
}

+(NSString *)suggest_brain_key{
    NSMutableData *seedData = [NSMutableData dataWithLength:32];
    int status = SecRandomCopyBytes(kSecRandomDefault, seedData.length, seedData.mutableBytes);
    
    if(status == 0){
        NSMutableData *hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        CC_SHA256(seedData.bytes, (int)seedData.length, hash.mutableBytes);
        NSMutableArray* brainkey =[NSMutableArray array];
        const unsigned char *randomBuffer = (const unsigned char *)[hash bytes];
        NSArray* dictionary = [self dictonary];
        if (dictionary.count != 49744) {
            [NSException raise:@"Unexpected dictionary" format:@"expecting  49744 but got %ld dictionary words",dictionary.count];
        }
        for (NSInteger i = 0; i < 32; i += 2) {
            // randomBuffer has 256 bits / 16 bits per word == 16 words
            int num = (randomBuffer[i] << 8) + randomBuffer[i + 1];
            // convert into a number between 0 and 1 (inclusive)
            float rndMultiplier = num*1.0 / 65536;
            NSInteger wordIndex = (int)(dictionary.count * rndMultiplier);
            [brainkey addObject:dictionary[wordIndex]];
        }
        return [brainkey componentsJoinedByString:@" "];
    }
    else {
        [NSException raise:@"Unable to get random data!" format:@"Unable to get random data!"];
    }
    return nil;
}

+(NSString*) normalize_brain_key:(NSString*)brain_key{
    return [[brain_key componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@" "];
}

+(NSString*) get_brain_private_key:(NSString*)brain_key sequence:(NSInteger)sequence{
    brain_key=[GXUtil normalize_brain_key:brain_key];
    NSString* brain_key_with_seq=[NSString stringWithFormat:@"%@ %ld",brain_key,sequence];
    NSData* buffer = BTCSHA256(BTCSHA512([brain_key_with_seq dataUsingEncoding:NSUTF8StringEncoding]));
    GXPrivateKey* priv =  [GXPrivateKey fromBuffer:buffer];
    return [priv toWif];
}

+(NSString *)private_to_public:(NSString *)private_key{
    return [[[GXPrivateKey fromWif:private_key] getPublic] toString];
}

@end
