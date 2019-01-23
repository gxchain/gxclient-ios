//
//  GXClient.m
//  gxclient-ios
//
//  Created by David Lan on 2019/1/21.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXClient.h"
#import "GXRPC.h"
#import "GXUtil.h"
#import "GXPrivateKey.h"
#import "GXPublicKey.h"
#import <AFNetworking.h>
#import "NSDictionary+Expand.h"

@interface GXClient()
@property(nonatomic,strong) GXRPC* rpc;
@property(nonatomic,strong) NSString* private_key;
@property(nonatomic,strong) NSString* account;
@property(nonatomic,strong) id<GXClientSignatureProvider> signatureProvider;
@end

@implementation GXClient

#pragma mark - Constructors

+(instancetype)clientWithEntryPoint:(NSString *)entryPoint{
    GXClient * client = [[GXClient alloc] init];
    client.rpc = [GXRPC rpcWithEntryPoint:entryPoint];
    return client;
}

+(instancetype)clientWithEntryPoint:(NSString *)entryPoint keyProvider:(NSString *)privateKey account:(NSString *)accountName{
    GXClient * client = [self clientWithEntryPoint:entryPoint];
    client.private_key= privateKey;
    client.account = accountName;
    return client;
}

+(instancetype)clientWithEntryPoint:(NSString *)entryPoint signatureProvider:(id<GXClientSignatureProvider>)provider account:(NSString *)accountName{
    GXClient * client = [self clientWithEntryPoint:entryPoint];
    client.signatureProvider =provider;
    client.account = accountName;
    return client;
}

#pragma mark - KeyPair API

-(NSDictionary *)generateKey:(NSString*)brain_key{
    NSString* brainKey = brain_key==nil||[brain_key isEqualToString:@""]? [GXUtil suggest_brain_key]:[GXUtil normalize_brain_key:brain_key];
    NSString* privateKey = [GXUtil get_brain_private_key:brainKey sequence:0];
    NSString* publicKey = [GXUtil private_to_public:privateKey];
    return @{
             @"brainKey":brainKey,
             @"privateKey":privateKey,
             @"publicKey":publicKey
             };
}

-(NSString*) privateToPublic:(NSString*)privateKey{
    return [GXUtil private_to_public:privateKey];
}

-(BOOL) isValidPrivate:(NSString*)privateKey{
    @try{
        return [GXPrivateKey fromWif:privateKey] != nil;
    }@catch(NSException* ex){
        return NO;
    }
}

-(BOOL) isValidPublic:(NSString*)publicKey{
    @try{
        return [GXPublicKey fromString:publicKey] != nil;
    }@catch(NSException* ex){
        return NO;
    }
}

#pragma mark - Faucet API
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey faucet:(NSString*)faucetUrl callback:(void (^)(NSError * error, id responseObject))callback{
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json", nil];
    manager.requestSerializer.timeoutInterval=10.0;
    manager.securityPolicy.allowInvalidCertificates=NO;
    manager.securityPolicy.validatesDomainName=YES;
    NSAssert([self isValidPublic:activeKey], @"invalid active key");
    if(ownerKey!=nil){
        NSAssert([self isValidPublic:ownerKey], @"invalid owner key");
    }
    if(memoKey!=nil){
        NSAssert([self isValidPublic:memoKey], @"invalid memo key");
    }
    NSDictionary* params = @{
                             @"account":@{
                                  @"name":accountName,
                                  @"active_key":activeKey,
                                  @"owner_key":ownerKey?ownerKey:activeKey,
                                  @"memo_key":memoKey?memoKey:activeKey
                              }
    };
    [manager POST:[NSString stringWithFormat:@"%@%@",faucetUrl,@"/account/register"] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        callback(nil,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString* responseText = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        callback(error,[NSDictionary fromJSON:responseText]);
    }];
}
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey callback:(void (^)(NSError * error, id responseObject))callback{
    [self registerAccount:accountName activeKey:activeKey ownerKey:ownerKey memoKey:memoKey faucet:@"https://opengateway.gxb.io" callback:callback];
}

@end

