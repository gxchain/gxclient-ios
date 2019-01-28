//
//  VoteOperation.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/27.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"
#import "GXNewOptions.h"

@interface GXVoteOperation : GXBaseOperation
@property(nonatomic,strong) NSString* account;
@property(nonatomic,strong) GXNewOptions* options;
@property (nonatomic,strong) NSArray* extensions;
@end
