//
//  GXCreateStakingOperation.m
//  gxclient-ios
//
//  Created by David on 2020/2/20.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import "GXCreateStakingOperation.h"

@implementation GXCreateStakingOperation

-(int32_t)operation_id{
    return 80;
}

-(NSDictionary *)dictionaryValue{
    NSMutableDictionary* result=@{
                                  @"fee":[self.fee dictionaryValue],
                                  @"owner":_owner,
                                  @"trust_node":_trust_node,
                                  @"amount":[_amount dictionaryValue],
                                  @"program_id":_program_id,
                                  @"weight":@(_weight),
                                  @"staking_days":@(_staking_days)
                                  }.mutableCopy;
    NSMutableArray* exts=[NSMutableArray array];
    if(_extensions){
        [_extensions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj respondsToSelector:NSSelectorFromString(@"dictionaryValue")]){
                [exts addObject:[obj performSelector:NSSelectorFromString(@"dictionaryValue") withObject:nil]];
            }
            else{
                NSLog(@"Unknow extension object,%@", obj);
            }
        }];
    }
    [result setObject:exts forKey:@"extensions"];
    return result;
}

@end
