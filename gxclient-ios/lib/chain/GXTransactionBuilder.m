//
//  GXTransactionBuilder.m
//  Graphene
//
//  Created by David Lan on 2018/2/27.
//  Copyright © 2018年 GXChain. All rights reserved.
//

#import "GXTransactionBuilder.h"
#import "NSArray+Expand.h"
#import "NSDictionary+Expand.h"
#import "GXChainConfig.h"
#import "NSMutableData+ProtoBuff.h"
#import "GXUtil.h"

@interface GXTransactionBuilder()
@property(nonatomic,strong) NSMutableArray<GXPrivateKey*>* signer_private_keys;
@property(nonatomic,weak) GXRPC* rpc;
@property(nonatomic,strong) NSString* chain_id;
@end

@implementation GXTransactionBuilder

-(instancetype)initWithOperations:(NSArray<GXBaseOperation*>*)operations rpc:(GXRPC*)rpc chainID:(NSString*)chainID{
    self = [self init];
    self.operations=operations;
    self.signer_private_keys=[NSMutableArray array];
    self.rpc = rpc;
    self.chain_id= chainID;
    return self;
}

-(void)add_signer:(GXPrivateKey*)private_key{
    [self.signer_private_keys addObject:private_key];
}

-(void)sign{
    if(self.chain_id == nil){
        self.chain_id = GX_DEFAULT_CHAIN_ID;
    }
    NSMutableData* data=[NSMutableData data];
    [data appendData:BTCDataFromHex(self.chain_id)];
    [data appendData:[self serialize]];
    NSMutableArray* signatures = [NSMutableArray array];
    [_signer_private_keys enumerateObjectsUsingBlock:^(GXPrivateKey * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData* signature=[obj sign:data];
        [signatures addObject:signature];
    }];
    self.signatures=signatures;
}

-(void)setRequiredFees:(void(^)(void))callback{
    NSMutableArray* operations = [NSMutableArray array];
    NSString* asset_id = [(GXBaseOperation*)[self.operations objectAtIndex:0] fee].asset_id;
    
    [self.operations enumerateObjectsUsingBlock:^(GXBaseOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [operations addObject:[obj operation]];
    }];
    [self.rpc query:@"get_required_fees" params:@[operations,asset_id] callback:^(NSError *err, id resp) {
        __block int index=0;
        [self.operations enumerateObjectsUsingBlock:^(GXBaseOperation * _Nonnull op, NSUInteger idx, BOOL * _Nonnull stop) {
            [self setFee:resp[index++] forOperation:op];
            SEL sel_proposed_ops = NSSelectorFromString(@"proposed_ops");
            if([op respondsToSelector:sel_proposed_ops]){
                NSArray* proposed_ops = [op performSelector:sel_proposed_ops];
                [proposed_ops enumerateObjectsUsingBlock:^(GXBaseOperation *  _Nonnull pop, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self setFee:resp[index++] forOperation:pop];
                }];
            }
        }];
        if(callback){
            callback();
        }
    }];
}

-(void)setFee:(NSDictionary*)fee forOperation:(GXBaseOperation*)op{
    op.fee.amount=[[fee objectForKey:@"amount"] longValue];
    op.fee.asset_id=[fee objectForKey:@"asset_id"];
}

-(void)setBlockHeader:(void(^)(void))callback{
    __block GXTransactionBuilder* _self = self;
    [self.rpc query:@"get_objects" params:@[@[@"2.1.0"]] callback:^(NSError *err, id resp) {
        NSDate* time = [_self dateFromUTCString:[[resp objectAtIndex:0] objectForKey:@"time"]];
        _self.expiration=[time timeIntervalSince1970]+GX_EXPIRE_IN_SECOND;
        _self.ref_block_num = [resp[0][@"head_block_number"] longValue] & 0xFFFF;
        NSData* head_block_id = BTCDataFromHex([[resp objectAtIndex:0] objectForKey:@"head_block_id"]);
        uint32_t ref_block_prefix;
        const size_t length = sizeof(ref_block_prefix);
        Byte byte[length] = {};
        [head_block_id getBytes:byte range:NSMakeRange(4, 4+length)];
        ref_block_prefix = (uint32_t) (((byte[0] & 0xFF))
                                       | ((byte[1] & 0xFF)<<8)
                                       | ((byte[2] & 0xFF)<<16)
                                       | (byte[3] & 0xFF)<<24);
        _self.ref_block_prefix = ref_block_prefix;
        if(callback){
            callback();
        }
    }];
}
-(NSData *)dataWithHexString:(NSString *)hexString {
    const char *chars = [hexString UTF8String];
    int i = 0;
    NSUInteger len = hexString.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    return data;
}

-(NSDate*)dateFromUTCString:(NSString*)dateStr{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [df dateFromString:dateStr];
}

-(NSString*)utcStringFromDate:(NSDate*)date{
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [df setTimeZone:timeZone];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    return [df stringFromDate:date];
}

-(void)broadcast:(void(^)(NSError *err,NSDictionary* tx))callback{
    [self.rpc broadcast:[self signedTransaction] callback:^(NSError *err, id resp) {
        callback(err,(NSDictionary*)resp);
    }];
}

-(void)processTransaction:(void(^)(NSError *err,NSDictionary* tx))callback broadcast:(BOOL)broadcast{
    if(_signer_private_keys==nil||_signer_private_keys.count==0){
        [[NSException exceptionWithName:@"Process transaction" reason:@"no signer key" userInfo:nil] raise];
    }
    __weak GXTransactionBuilder* weakSelf = self;
    [self setRequiredFees:^(){
        __strong GXTransactionBuilder* strongSelf = weakSelf;
        __weak GXTransactionBuilder* weakSelf = strongSelf;
        [strongSelf setBlockHeader:^(){
            __strong GXTransactionBuilder* strongSelf = weakSelf;
            if (broadcast) {
                [strongSelf broadcast:callback];
            }
            else{
                callback(nil,[strongSelf signedTransaction]);
            }
        }];
    }];
}


-(NSDictionary*)signedTransaction{
    [self sign];
    NSMutableDictionary* tx=[self dictionaryValue].mutableCopy;
    NSMutableArray* signatures = [NSMutableArray array];
    [self.signatures enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [signatures addObject:BTCHexFromData(obj)];
    }];
    [tx setObject:signatures forKey:@"signatures"];
    return tx;
}

#pragma mark - serialize delegate methods
-(NSData*)serialize{
    NSDictionary* dict = [self dictionaryValue];
    NSString* result=  [GXUtil serialize_transaction:dict];
    return BTCDataFromHex(result);
}

-(NSArray*)sortedOperations{
    return [_operations sortedArrayUsingComparator:^NSComparisonResult(GXBaseOperation*  _Nonnull op1, GXBaseOperation*  _Nonnull op2) {
        return op1.operation_id-op2.operation_id;
    }];
}

-(NSDictionary *)dictionaryValue{
    NSDate* _exp = [NSDate dateWithTimeIntervalSince1970:_expiration];
    NSMutableDictionary* result=@{
                                  @"ref_block_num":@(_ref_block_num),
                                  @"ref_block_prefix":@(_ref_block_prefix),
                                  @"expiration":[self utcStringFromDate:_exp]
                                  }.mutableCopy;
    NSMutableArray* ops=[NSMutableArray array];
    if(_operations){
        _operations=[self sortedOperations];
        [_operations enumerateObjectsUsingBlock:^(GXBaseOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ops addObject:[obj operation]];
        }];
    }
    [result setObject:ops forKey:@"operations"];
    if(!_extensions){
        _extensions=@[];
    }
    NSMutableArray* exts = [NSMutableArray array];
    [_extensions enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj respondsToSelector:NSSelectorFromString(@"dictionaryValue")]){
            [exts addObject:[obj performSelector:NSSelectorFromString(@"dictionaryValue")]];
        }
        else{
            NSLog(@"Unknow extension object,%@", obj);
        }
    }];
    [result setObject:exts forKey:@"extensions"];
    return result;
}
@end
