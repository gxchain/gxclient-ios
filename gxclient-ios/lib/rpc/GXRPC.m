//
//  GXRPC.m
//  gxclient-ios
//
//  Created by David Lan on 2019/1/21.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import "GXRPC.h"
#import <AFNetworking.h>
#import "NSDictionary+Expand.h"

NSInteger callID = 0;

@interface GXRPC()
@property (nonatomic,strong) NSString* entryPoint;
@end

@implementation GXRPC

-(instancetype)init{
    self=[super init];
    self.entryPoint=@"https://node1.gxb.io";
    return self;
}

-(instancetype) initWithEntryPoint:(NSString*)entryPoint{
    self=[self init];
    self.entryPoint = entryPoint;
    return self;
}

+(instancetype) rpcWithEntryPoint:(NSString*)entryPoint{
    GXRPC* rpc = [[GXRPC alloc] initWithEntryPoint:entryPoint];
    return rpc;
}

-(AFHTTPSessionManager*) manager{
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval=10.0;
    manager.securityPolicy.allowInvalidCertificates=NO;
    manager.securityPolicy.validatesDomainName=YES;
    return manager;
}

-(void)query:(NSString *)method params:(NSArray *)params callback:(void (^)(NSError *, id))callback{
    AFHTTPSessionManager* manager = [self manager];
    NSDictionary* para = @{
                           @"jsonrpc":@"2.0",
                           @"method":method,
                           @"params":params,
                           @"id":@(callID++)
                           };
    [manager POST:self.entryPoint parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * err = [responseObject objectForKey:@"error"];
        if(err){
            callback([NSError errorWithDomain:@"GXRPC ERROR" code:400 userInfo:nil],err);
        } else{
            callback(nil,[responseObject objectForKey:@"result"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString* responseText = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        callback(error,[NSDictionary fromJSON:responseText]);
    }];
}

-(void)broadcast:(NSDictionary *)tx callback:(void (^)(NSError *, id))callback{
    AFHTTPSessionManager* manager =[self manager];
    NSDictionary* para = @{
                           @"jsonrpc":@"2.0",
                           @"method":@"call",
                           @"params":@[@2,@"broadcast_transaction_synchronous",@[tx]],
                           @"id":@(++callID)
                           };
    [manager POST:self.entryPoint parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * err = [responseObject objectForKey:@"error"];
        if(err){
            callback([NSError errorWithDomain:@"GXRPC ERROR" code:400 userInfo:nil],err);
        } else{
            callback(nil,[responseObject objectForKey:@"result"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSString* responseText = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        callback(error,[NSDictionary fromJSON:responseText]);
    }];
}

@end
