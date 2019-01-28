//
//  GXNewOptions.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/28.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXSerializeDelegate.h"

@interface GXNewOptions : NSObject<GXSerializeDelegate>
@property (nonatomic, strong) NSString* memo_key;
@property (nonatomic, strong) NSString* voting_account;
@property (nonatomic, assign) NSInteger num_witness;
@property (nonatomic, assign) NSInteger num_committee;
@property (nonatomic, strong) NSArray* votes;
@end
