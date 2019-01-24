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
+(instancetype) clientWithEntryPoint:(NSString *)entryPoint signatureProvider:(id<GXClientSignatureProvider>)provider account:(NSString*)accountName;

#pragma mark - KeyPair API
-(NSDictionary*) generateKey:(NSString* _Nullable)brain_key;
-(NSString*) privateToPublic:(NSString*)privateKey;
-(BOOL) isValidPrivate:(NSString*)privateKey;
-(BOOL) isValidPublic:(NSString*)publicKey;

#pragma mark - Chain API
-(void)query:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getChainID:(void(^)(NSError * error, id responseObject)) callback;
-(void)getDynamicGlobalProperties:(void(^)(NSError * error, id responseObject)) callback;
-(void)getBlock:(NSInteger)height callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)transfer:(NSString*)to memo:(NSString* _Nullable) memo amount:(NSString*)amountAsset feeAsset:(NSString*)feeAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)vote:(NSArray*) accounts feeAsset:(NSString*)feeAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)broadcast:(NSDictionary*)tx callback:(void(^)(NSError * error, id responseObject)) callback;

#pragma mark - Faucet API
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString * _Nullable)ownerKey memoKey:(NSString * _Nullable)memoKey faucet:(NSString*)faucetUrl callback:(void (^)(NSError * error, id responseObject))callback;
// register with default faucet
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey callback:(void (^)(NSError * error, id responseObject))callback;

#pragma mark - Account API
-(void)getAccount:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountBalances:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountByPublicKey:(NSString*)publicKey callback:(void(^)(NSError * error, id responseObject)) callback;

#pragma mark - Asset API
-(void)getAsset:(NSString*)symbol callback:(void(^)(NSError * error, id responseObject)) callback;

#pragma mark - Object API
-(void)getObject:(NSString*)objectID callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getObjects:(NSArray*)objectIDs callback:(void(^)(NSError * error, id responseObject)) callback;

#pragma mark - Contract API
-(void) callContract:(NSString*)contractName method:(NSString*)method params:(NSDictionary*)params amount:(NSString*)amountAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getContractABI:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getContractTables:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getTableObjects:(NSString*)contract table:(NSString*)tableName start:(uint64_t)start limit:(NSInteger)limit reverse:(BOOL)reverse callback:(void(^)(NSError * error, id responseObject)) callback;

@end


