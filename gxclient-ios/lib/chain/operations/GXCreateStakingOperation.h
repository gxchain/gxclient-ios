//
//  GXCreateStakingOperation.h
//  gxclient-ios
//
//  Created by David on 2020/2/20.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"
#import "GXAssetAmount.h"

/**
 export const staking_create = new Serializer('staking_create', {
   fee: asset,
   owner: protocol_id_type('account'),
   trust_node: protocol_id_type('witness'),
   amount: asset,
   program_id: string,
   weight: uint32,
   staking_days: uint32,
   extensions: set(future_extensions)
 });
 */

NS_ASSUME_NONNULL_BEGIN

@interface GXCreateStakingOperation : GXBaseOperation
@property (nonatomic,strong) NSString* owner;
@property (nonatomic,strong) NSString* trust_node;
@property (nonatomic,strong) GXAssetAmount* amount;
@property (nonatomic,strong) NSString* program_id;
@property (nonatomic,assign) uint32_t weight;
@property (nonatomic,assign) uint32_t staking_days;
@property (nonatomic,strong) NSArray* extensions;
@end

NS_ASSUME_NONNULL_END
