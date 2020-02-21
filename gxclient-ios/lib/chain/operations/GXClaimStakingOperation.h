//
//  GXClaimStakingOperation.h
//  gxclient-ios
//
//  Created by David on 2020/2/21.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"

/**
 export const staking_claim = new Serializer('staking_claim', {
   fee: asset,
   owner: protocol_id_type('account'),
   staking_id: protocol_id_type('staking'),
   extensions: set(future_extensions)
 });
 */

NS_ASSUME_NONNULL_BEGIN

@interface GXClaimStakingOperation : GXBaseOperation
@property (nonatomic,strong) NSString* owner;
@property (nonatomic,strong) NSString* staking_id;
@property (nonatomic,strong) NSArray* extensions;
@end

NS_ASSUME_NONNULL_END
