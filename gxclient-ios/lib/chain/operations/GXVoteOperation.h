//
//  VoteOperation.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/27.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"
#import "GXNewOptions.h"

/**
 export const account_update = new Serializer('account_update', {
   fee: asset,
   account: protocol_id_type('account'),
   owner: optional(authority),
   active: optional(authority),
   new_options: optional(account_options),
   extensions: set(future_extensions)
 });
 */

@interface GXVoteOperation : GXBaseOperation
@property(nonatomic,strong) NSString* account;
@property(nonatomic,strong) GXNewOptions* options;
@property (nonatomic,strong) NSArray* extensions;
@end
