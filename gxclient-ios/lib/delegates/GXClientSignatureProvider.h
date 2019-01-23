//
//  GXClientSignatureProvider.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/21.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GXClientSignatureProvider
-(void)sign:(NSDictionary*)tx withCallback:(void(^)(NSError *err,NSDictionary* tx))callback;
@end
