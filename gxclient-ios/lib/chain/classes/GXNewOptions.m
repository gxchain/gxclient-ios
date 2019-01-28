//
//  GXNewOptions.m
//  gxclient-ios
//
//  Created by David Lan on 2019/1/28.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXNewOptions.h"

@implementation GXNewOptions
-(NSDictionary *)dictionaryValue{
    return @{
             @"memo_key":self.memo_key,
             @"voting_account":self.voting_account,
             @"num_witness":@(self.num_witness),
             @"num_committee":@(self.num_committee),
             @"votes":self.votes,
             @"extensions":@[]
             };
}
@end
