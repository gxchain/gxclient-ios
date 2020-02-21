//
//  GXUpdateStakingOperation.h
//  gxclient-ios
//
//  Created by David on 2020/2/21.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import "GXBaseOperation.h"

/**
export const staking_update = new Serializer('staking_update', {
  fee: asset,
  owner: protocol_id_type('account'),
  trust_node: protocol_id_type('witness'),
  staking_id: protocol_id_type('staking'),
  extensions: set(future_extensions)
});
*/

NS_ASSUME_NONNULL_BEGIN

@interface GXUpdateStakingOperation : GXBaseOperation
@property (nonatomic,strong) NSString* owner;
@property (nonatomic,strong) NSString* trust_node;
@property (nonatomic,strong) NSString* staking_id;
@property (nonatomic,strong) NSArray* extensions;
@end

NS_ASSUME_NONNULL_END
