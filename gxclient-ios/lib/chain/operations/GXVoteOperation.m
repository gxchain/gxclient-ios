//
//  VoteOperation.m
//  gxclient-ios
//
//  Created by David Lan on 2019/1/27.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXVoteOperation.h"

@implementation GXVoteOperation

-(int32_t)operation_id{
    return 6;
}

-(NSDictionary *)dictionaryValue{
    NSMutableDictionary* result=@{
                                  @"fee":[self.fee dictionaryValue],
                                  @"account":_account,
                                  @"new_options":[self.options dictionaryValue],
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
