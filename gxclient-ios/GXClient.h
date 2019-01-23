//
//  gxclient_ios.h
//  gxclient-ios
//
//  Created by David Lan on 2019/1/21.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GXClientSignatureProvider.h"

@interface GXClient:NSObject

#pragma mark - Constructors
// init with no signer
+(instancetype) clientWithEntryPoint:(NSString*)entryPoint;
// init with private key
+(instancetype) clientWithEntryPoint:(NSString*)entryPoint keyProvider:(NSString*)privateKey account:(NSString*)accountName;
// init with signature provider
+(instancetype) clientWithEntryPoint:(NSString *)entryPoint signatureProvider:(id<GXClientSignatureProvider>*)provider account:(NSString*)accountName;

#pragma mark - KeyPair API
-(NSDictionary*) generateKey:(NSString*)brain_key;
-(NSString*) privateToPublic:(NSString*)privateKey;
-(BOOL) isValidPrivate:(NSString*)privateKey;
-(BOOL) isValidPublic:(NSString*)publicKey;

#pragma mark - Faucet API
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey faucet:(NSString*)faucetUrl callback:(void (^)(NSError * error, id responseObject))callback;
// register with default facet
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey callback:(void (^)(NSError * error, id responseObject))callback;


@end


