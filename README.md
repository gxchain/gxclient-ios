# gxclient-ios
A client to interact with gxchain implemented in Objective-C

<p>
 <a href='javascript:;'>
   <img width="300px" src='https://raw.githubusercontent.com/gxchain/gxips/master/assets/images/task-gxclient.png'/>
 </a>
 <a href='javascript:;'>
   <img width="300px" src='https://raw.githubusercontent.com/gxchain/gxips/master/assets/images/task-gxclient-en.png'/>
 </a>
</p> 

## APIs

- [x] [Keypair API](#keypair-api)
- [x] [Chain API](#chain-api)
- [x] [Faucet API](#faucet-api)
- [x] [Account API](#account-api)
- [x] [Asset API](#asset-api)
- [x] [Contract API](#contract-api)

### Constructors
```Objective-C
// init with no signer
+(instancetype) clientWithEntryPoint:(NSString*)entryPoint;
// init with private key
+(instancetype) clientWithEntryPoint:(NSString*)entryPoint keyProvider:(NSString*)privateKey account:(NSString*)accountName;
// init with signature provider
+(instancetype) clientWithEntryPoint:(NSString *)entryPoint signatureProvider:(id<GXClientSignatureProvider>*)provider account:(NSString*)accountName;
```

### Keypair API
```Objective-C
-(NSDictionary*) generateKey:(NSString* _Nullable)brain_key;
-(NSString*) privateToPublic:(NSString*)privateKey;
-(BOOL) isValidPrivate:(NSString*)privateKey;
-(BOOL) isValidPublic:(NSString*)publicKey;
```

### Chain API
```Objective-C
-(void)query:(NSString*)method params:(NSArray*)params callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getChainID:(void(^)(NSError * error, id responseObject)) callback;
-(void)getDynamicGlobalProperties:(void(^)(NSError * error, id responseObject)) callback;
-(void)getBlock:(NSInteger)height callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getObject:(NSString*)objectID callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getObjects:(NSArray*)objectIDs callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)transfer:(NSString*)to memo:(NSString* _Nullable) memo amount:(NSString*)amountAsset feeAsset:(NSString*)feeAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getVoteIdsByAccounts:(NSArray*)accountNames callback:(void(^)(NSError * error, NSArray* voteIds )) callback;
-(void)vote:(NSArray*) accounts proxyAccount:(NSString* _Nullable)proxyAcccount feeAsset:(NSString*)feeAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)broadcast:(NSDictionary*)tx callback:(void(^)(NSError * error, id responseObject)) callback;
```

### Faucet API
```Objective-C
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString * _Nullable)ownerKey memoKey:(NSString * _Nullable)memoKey faucet:(NSString*)faucetUrl callback:(void (^)(NSError * error, id responseObject))callback;
// register with default facet
-(void)registerAccount:(NSString *)accountName activeKey:(NSString *)activeKey ownerKey:(NSString *)ownerKey memoKey:(NSString *)memoKey callback:(void (^)(NSError * error, id responseObject))callback;
```

### Account API
```Objective-C
-(void)getAccounts:(NSArray*)accountNames callback:(void(^)(NSError * error, NSArray* accounts)) callback;
-(void)getAccount:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountBalances:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountByPublicKey:(NSString*)publicKey callback:(void(^)(NSError * error, id responseObject)) callback;
```

### Asset API
```Objective-C
-(void)getAsset:(NSString*)symbol callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAssets:(NSArray*)symbols callback:(void(^)(NSError * error, NSArray* assets)) callback;
```

### Contract API

```Objective-C
-(void) callContract:(NSString*)contractName method:(NSString*)method params:(NSDictionary*)params amount:(NSString*)amountAsset broadcast:(BOOL)broadcast callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getContractABI:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getContractTables:(NSString*)contract callback:(void(^)(NSError * error, id responseObject)) callback;
-(void) getTableObjects:(NSString*)contract table:(NSString*)tableName start:(uint64_t)start limit:(NSInteger)limit callback:(void(^)(NSError * error, id responseObject)) callback;

```

