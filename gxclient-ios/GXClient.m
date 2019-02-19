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
#import "GXTransactionBuilder.h"
#import "GXTransferOperation.h"
#import "GXMemoData.h"
#import "GXSafeMutableArray.h"
#import "GXVoteOperation.h"
#import "GXNewOptions.h"
#import "GXCallContractOperation.h"

#define account_not_exist @"account_not_exist"
#define account_not_exist_code -1
#define asset_not_exist @"asset_not_exist"
#define asset_not_exist_code -2

const NSString* DEFAULT_FAUCET=@"https://opengateway.gxb.io";

@interface GXClient()
@property(nonatomic,strong) GXRPC* rpc;
@property(nonatomic,strong) NSString* private_key;
@property(nonatomic,strong) NSString* account;
@property(nonatomic,strong) id<GXClientSignatureProvider> signatureProvider;
@property(nonatomic,strong) NSString* chain_id;
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
    client.signatureProvider = provider;
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

#pragma mark - Chain API

-(void) query:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError * error, id responseObject)) callback{
    [self.rpc query:method params:params callback:callback];
}

-(void) getChainID:(void (^)(NSError *, id))callback{
    if(self.chain_id){
        callback(nil,self.chain_id);
    } else{
        [self query:@"get_chain_id" params:@[] callback:^(NSError *error, id responseObject) {
            if(error == nil){
                self.chain_id = responseObject;
            }
            callback(error,responseObject);
        }];
    }
}
-(void)getDynamicGlobalProperties:(void(^)(NSError * error, id responseObject)) callback{
    [self query:@"get_dynamic_global_properties" params:@[] callback:callback];
}

-(void) getBlock:(NSInteger)height callback:(void (^)(NSError *, id))callback{
    [self query:@"get_block" params:@[@(height)] callback:callback];
}

-(void)transfer:(NSString *)to memo:(NSString *)memo amount:(NSString *)amountAsset feeAsset:(NSString *)feeAsset broadcast:(BOOL)broadcast callback:(void (^)(NSError *, id))callback{
    [self getChainID:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            [self getAccounts:@[self.account,to] callback:^(NSError *error, NSArray* accArr) {
                if(error){
                    callback(error,responseObject);
                } else{
                    NSDictionary* fromAccount = [accArr objectAtIndex:0];
                    NSDictionary* toAccount = [accArr objectAtIndex:1];
                    float amount = [[[amountAsset componentsSeparatedByString:@" "] objectAtIndex:0] floatValue];
                    NSString* asset = [[amountAsset componentsSeparatedByString:@" "] objectAtIndex:1];
                    if(asset == nil){
                        asset = @"GXC";
                    }
                    
                    NSMutableArray* assets = [NSMutableArray arrayWithObject:asset];
                    __block BOOL diffrentAsset = NO;
                    if(feeAsset!=nil && ![feeAsset isEqualToString:@""] && ![feeAsset isEqualToString:asset]){
                        [assets addObject:feeAsset];
                        diffrentAsset = YES;
                    }
                    
                    [self getAssets:assets callback:^(NSError *error, NSArray *assets) {
                        if(error){
                            callback(error,assets);
                        } else{
                            NSDictionary* asset = assets[0];
                            GXTransferOperation * op = [[GXTransferOperation alloc] init];
                            op.from=[fromAccount objectForKey:@"id"];
                            op.to=[toAccount objectForKey:@"id"];
                            uint64_t am = (int64_t)(amount*powf(10.0, [[asset objectForKey:@"precision"] floatValue]));
                            op.amount=[[GXAssetAmount alloc] initWithAsset:[asset objectForKey:@"id"] amount:am];
                            NSString* toMemoKey = [[toAccount objectForKey:@"options"] objectForKey:@"memo_key"];
                            op.memo=[GXMemoData memoWithPrivate:self.private_key public:toMemoKey message:memo];
                            op.extensions=@[];
                            
                            if(diffrentAsset){
                                op.fee=[[GXAssetAmount alloc] initWithAsset:[assets[1] objectForKey:@"id"] amount:0];
                            } else{
                                op.fee=[[GXAssetAmount alloc] initWithAsset:[assets[0] objectForKey:@"id"] amount:0];
                            }
                            GXTransactionBuilder * tx =[[GXTransactionBuilder alloc] initWithOperations:@[op] rpc:self.rpc chainID:self.chain_id];
                            [tx add_signer:[GXPrivateKey fromWif:self.private_key]];
                            
                            [tx processTransaction:^(NSError *err, NSDictionary *tx) {
                                callback(err,tx);
                            } broadcast:broadcast];
                            
                        }
                    }];
                }
            }];
        }
    }];
}


-(void)getVoteIdsByAccounts:(NSArray*)accountNames callback:(void(^)(NSError * error, NSArray* voteIds )) callback{
    
    [self getAccounts:accountNames callback:^(NSError *error, NSArray *accArr) {
        if(error){
            callback(error,accArr);
        } else{
            dispatch_group_t dispatchGroup = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            GXSafeMutableArray* voteids =[GXSafeMutableArray arrayWithCapacity:accArr.count*2];
            [accArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_group_async(dispatchGroup,queue, ^{
                    dispatch_group_enter(dispatchGroup);
                    [self query:@"get_witness_by_account" params:@[accArr[idx][@"id"]] callback:^(NSError *error, id responseObject) {
                        if([responseObject objectForKey:@"vote_id"]){
                            [voteids addObject:[responseObject objectForKey:@"vote_id"]];
                        }
                        dispatch_group_leave(dispatchGroup);
                    }];
                });
                dispatch_group_async(dispatchGroup,queue, ^{
                    dispatch_group_enter(dispatchGroup);
                    [self query:@"get_committee_member_by_account" params:@[accArr[idx][@"id"]] callback:^(NSError *error, id responseObject) {
                        if([responseObject objectForKey:@"vote_id"]){
                            [voteids addObject:[responseObject objectForKey:@"vote_id"]];
                        }
                        dispatch_group_leave(dispatchGroup);
                    }];
                });
            }];
            dispatch_notify(dispatchGroup, queue, ^{
                callback(nil,voteids);
            });
        }
    }];
}

-(void)vote:(NSArray *)accounts proxyAccount:(NSString* _Nullable)proxyAccount feeAsset:(NSString *)feeAsset broadcast:(BOOL)broadcast callback:(void (^)(NSError *, id))callback{
    [self getChainID:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            NSMutableArray* arr = [NSMutableArray arrayWithObject:self.account];
            if (proxyAccount!=nil && [proxyAccount isEqualToString:@""]) {
                [arr addObject:proxyAccount];
            }
            [self getAccounts:arr callback:^(NSError *error, NSArray* accArr) {
                if(error){
                    callback(error,accArr);
                } else {
                    NSDictionary* myAccount = [accArr objectAtIndex:0];
                    NSString* account_id = [myAccount objectForKey:@"id"];
                    NSString* voting_account = [[myAccount objectForKey:@"options"] objectForKey:@"voting_account"];
                    NSString* memo_key = [[myAccount objectForKey:@"options"] objectForKey:@"memo_key"];
                    if(voting_account == nil){
                        voting_account = proxyAccount==nil && [proxyAccount isEqualToString:@""]? @"1.2.5": [accArr[1] objectForKey:@"id"];
                    }
                    if(memo_key == nil){
                        memo_key = @"";
                    }
                    
                    NSString* fee_asset_symbol = feeAsset;
                    if(fee_asset_symbol ==nil || [fee_asset_symbol isEqualToString:@""]){
                        fee_asset_symbol = @"GXC";
                    }
                    [self getAsset:fee_asset_symbol callback:^(NSError *error, id responseObject) {
                        if(error){
                            callback(error, responseObject);
                        } else if([responseObject objectForKey:@"id"]){
                            NSString* feeAssetId = [responseObject objectForKey:@"id"];
                            [self getVoteIdsByAccounts:accounts callback:^(NSError *error, NSArray *voteIds) {
                                [self getObject:@"2.0.0" callback:^(NSError *error, id responseObject) {
                                    if(error){
                                        callback(error, responseObject);
                                    } else{
                                        GXVoteOperation* op = [[GXVoteOperation alloc] init];
                                        GXNewOptions* options = [[GXNewOptions alloc] init];
                                        __block NSInteger num_witness = 0;
                                        __block NSInteger num_committee = 0;
                                        [voteIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            NSArray* vote = [obj componentsSeparatedByString:@":"];
                                            if([[vote objectAtIndex:0] isEqualToString:@"0"]){
                                                num_committee+=1;
                                            }
                                            if([[vote objectAtIndex:0] isEqualToString:@"1"]){
                                                num_witness+=1;
                                            }
                                        }];
                                        NSInteger maximum_committee_count = [[[responseObject objectForKey:@"parameters"] objectForKey:@"maximum_committee_count"] integerValue];
                                        NSInteger maximum_witness_count = [[[responseObject objectForKey:@"parameters"] objectForKey:@"maximum_witness_count"] integerValue];
                                        options.num_witness = MIN(num_witness, maximum_witness_count);
                                        options.num_committee = MIN(num_committee, maximum_committee_count);
                                        options.memo_key = memo_key;
                                        options.voting_account = voting_account;
                                        NSArray* origVotes = [[myAccount objectForKey:@"options"] objectForKey:@"votes"];
                                        NSMutableArray * newVotes = [NSMutableArray arrayWithArray:origVotes];
                                        [voteIds enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            if(![newVotes containsObject:obj]){
                                                [newVotes addObject:obj];
                                            }
                                        }];
                                        options.votes = [newVotes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                            NSArray* vote1 = [obj1 componentsSeparatedByString:@":"];
                                            NSArray* vote2 = [obj2 componentsSeparatedByString:@":"];
                                            if([vote1[1] integerValue]>[vote2[1] integerValue]){
                                                return NSOrderedDescending;
                                            } else if([vote1[1] integerValue]==[vote2[1] integerValue]){
                                                return NSOrderedSame;
                                            } else {
                                                return NSOrderedAscending;
                                            }
                                        }];
                                        op.account = account_id;
                                        op.fee=[[GXAssetAmount alloc] initWithAsset:feeAssetId amount:0];
                                        op.options = options;
                                        op.extensions=@[];
                                        GXTransactionBuilder* tx =[[GXTransactionBuilder alloc] initWithOperations:@[op] rpc:self.rpc chainID:self.chain_id];
                                        [tx add_signer:[GXPrivateKey fromWif:self.private_key]];
                                        [tx processTransaction:^(NSError *err, NSDictionary *tx) {
                                            callback(err,tx);
                                        } broadcast:broadcast];
                                    }
                                }];
                            }];
                        } else{
                            NSError* err = [NSError errorWithDomain:asset_not_exist code:asset_not_exist_code userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"%@ not exist", feeAsset]}];
                            callback(err,nil);
                        }
                    }];
                }
            }];
        }
    }];
}

-(void)broadcast:(NSDictionary *)tx callback:(void (^)(NSError *, id))callback{
    [self.rpc broadcast:tx callback:callback];
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
    [self registerAccount:accountName activeKey:activeKey ownerKey:ownerKey memoKey:memoKey faucet:[DEFAULT_FAUCET copy] callback:callback];
}

#pragma mark - Account API
-(void)getAccount:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback{
    [self query:@"get_account_by_name" params:@[accountName] callback:callback];
}

-(void) getAccounts:(NSArray*)accountNames callback:(void(^)(NSError * error, NSArray* accounts)) callback{
    GXSafeMutableArray* accArr = [[GXSafeMutableArray alloc] init];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    [accountNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_async(dispatchGroup,queue, ^{
            dispatch_group_enter(dispatchGroup);
            [self getAccount:obj callback:^(NSError *error, id responseObject) {
                [accArr addObject:responseObject];
                dispatch_group_leave(dispatchGroup);
            }];
        });
    }];
    dispatch_notify(dispatchGroup, queue, (^{
        __block BOOL hasError = NO;
        [accArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj objectForKey:@"id"]==nil){
                NSString* errorMessage = [NSString stringWithFormat:@"%@ not exist",[accountNames objectAtIndex:idx]];
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey:errorMessage};
                NSError* err = [NSError errorWithDomain:account_not_exist code:account_not_exist_code userInfo:userInfo];
                hasError=YES;
                *stop=YES;
                callback(err,nil);
            }
        }];
        if(!hasError){
            NSMutableArray* result = [NSMutableArray array];
            [accountNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString* accName = obj;
                [accArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([[obj objectForKey:@"name"] isEqualToString:accName]){
                        *stop=YES;
                        [result addObject:obj];
                    }
                }];
            }];
            callback(nil, result);
        } else{
            NSError* err = [NSError errorWithDomain:account_not_exist code:account_not_exist_code userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"one of the account in %@ does not exist", accountNames]}];
            callback(err,nil);
        }
        
    }));
}

-(void)getAccountBalances:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getAccount:accountName callback:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            [self query:@"get_account_balances" params:@[[responseObject objectForKey:@"id"]] callback:callback];
        }
    }];
}
-(void)getAccountByPublicKey:(NSString*)publicKey callback:(void(^)(NSError * error, id responseObject)) callback{
    [self query:@"get_key_references" params:@[@[publicKey]] callback:callback];
}

#pragma mark - Asset API
-(void) getAsset:(NSString*)symbol callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getAssets:@[symbol] callback:^(NSError *error, NSArray *assets) {
        if(error){
            callback(error,nil);
        } else{
            callback(nil,[assets objectAtIndex:0]);
        }
    }];
}

-(void) getAssets:(NSArray*)symbols callback:(void (^)(NSError *, NSArray*))callback{
    [self query:@"lookup_asset_symbols" params:@[symbols] callback:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            __block BOOL hasError = NO;
            [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqual:[NSNull null]]) {
                    *stop = YES;
                    hasError = YES;
                    NSError* err = [NSError errorWithDomain:asset_not_exist code:asset_not_exist_code userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"one of the asset in %@ does not exist", symbols]}];
                    callback(err,nil);
                }
            }];
            if(!hasError){
                callback(nil,responseObject);
            }
        }
    }];
}

#pragma mark - Object API

-(void)getObject:(NSString*)objectID callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getObjects:@[objectID] callback:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            callback(nil,[responseObject objectAtIndex:0]);
        }
    }];
}

-(void)getObjects:(NSArray*)objectIDs callback:(void(^)(NSError * error, id responseObject)) callback{
    [self query:@"get_objects" params:@[objectIDs] callback:callback];
}

#pragma mark - Contract API

-(void) callContract:(NSString*)contractName method:(NSString*)method params:(NSDictionary* _Nullable)params amount:(NSString* _Nullable)amountAsset feeAsset:(NSString* _Nullable)feeAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getChainID:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            [self getAccounts:@[self.account,contractName] callback:^(NSError *error, NSArray *accounts) {
                NSData* paramData= BTCDataFromHex([GXUtil serialize_action_data:method params:params abi:[[accounts objectAtIndex:1] objectForKey:@"abi"]]);
                NSString* fee_asset_symbol = [feeAsset isEqualToString:@""]||feeAsset==nil?@"GXC":feeAsset;
                NSMutableArray* assets = [NSMutableArray arrayWithObject:fee_asset_symbol];
                CGFloat amount = 0.0f;
                __block BOOL hasAmount = amountAsset !=nil && ![amountAsset isEqualToString:@""];
                if (hasAmount) {
                    amount = [[amountAsset componentsSeparatedByString:@" "][0] floatValue];
                    if(![[amountAsset componentsSeparatedByString:@" "][1] isEqualToString:fee_asset_symbol]){
                        [assets addObject:[amountAsset componentsSeparatedByString:@" "][1]];
                    }
                }
                [self getAssets:assets callback:^(NSError *error, NSArray *assets) {
                    GXCallContractOperation* op = [[GXCallContractOperation alloc] init];
                    op.data= paramData;
                    op.method_name = method;
                    op.account = [[accounts objectAtIndex:0] objectForKey:@"id"];
                    op.contract_id = [[accounts objectAtIndex:1] objectForKey:@"id"];
                    op.fee = [[GXAssetAmount alloc] initWithAsset:[assets[0] objectForKey:@"id"] amount:0];
                    if (hasAmount) {
                        NSDictionary* assetInfo = assets.count>1?assets[1]:assets[0];
                        uint64_t am = (int64_t)(amount*powf(10.0, [[assetInfo objectForKey:@"precision"] floatValue]));
                        op.amount=[[GXAssetAmount alloc] initWithAsset:[assetInfo objectForKey:@"id"] amount:am];
                    }
                    GXTransactionBuilder* tx = [[GXTransactionBuilder alloc] initWithOperations:@[op] rpc:self.rpc chainID:self.chain_id];
                    [tx add_signer:[GXPrivateKey fromWif:self.private_key]];
                    [tx processTransaction:^(NSError *err, NSDictionary *tx) {
                        callback(err,tx);
                    } broadcast:broadcast];
                }];
            }];
        }
    }];
}

-(void) getContractABI:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getAccount:contract callback:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            callback(nil, [responseObject objectForKey:@"abi"]);
        }
    }];
}

-(void) getContractTables:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback{
    [self getAccount:contract callback:^(NSError *error, id responseObject) {
        if(error){
            callback(error,responseObject);
        } else{
            callback(nil, [[responseObject objectForKey:@"abi"] objectForKey:@"tables"]);
        }
    }];
}

-(void) getTableObjects:(NSString*)contract table:(NSString*)tableName start:(uint64_t)start limit:(NSInteger)limit reverse:(BOOL)reverse callback:(void(^)(NSError * error, id responseObject)) callback{
    [self query:@"get_table_rows_ex" params:@[contract,tableName,@{@"lower_bound":@(start),@"upper_bound":@(-1),@"limit":@(limit),@"reverse":@(reverse)}] callback:callback];
}
@end

