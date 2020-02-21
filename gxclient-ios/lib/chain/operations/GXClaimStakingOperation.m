//
//  GXClaimStakingOperation.m
//  gxclient-ios
//
//  Created by David on 2020/2/21.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import "GXClaimStakingOperation.h"

@implementation GXClaimStakingOperation
-(int32_t)operation_id{
    return 82;
}
-(NSDictionary *)dictionaryValue{
    NSMutableDictionary* result=@{
                                     @"fee":[self.fee dictionaryValue],
                                     @"owner":_owner,
                                     @"staking_id":_staking_id,
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
