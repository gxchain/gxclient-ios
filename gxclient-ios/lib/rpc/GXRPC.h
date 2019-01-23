//
//  GXRPC.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/21.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXRPC : NSObject
-(instancetype) initWithEntryPoint:(NSString*)entryPoint;
+(instancetype) rpcWithEntryPoint:(NSString*)entryPoint;

-(void)query:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError* err,id resp))callback;
-(void)broadcast:(NSDictionary*)tx callback:(void(^)(NSError* err,id resp))callback;
@end
