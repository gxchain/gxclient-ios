# gxclient-ios
A client to interact with gxchain implemented in Objective-C

## APIs

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
-(void)getChainIDWithCallback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getBlock:(NSInteger)height callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)transfer:(NSString*)to memo:(NSString* _Nullable) memo amount:(NSString*)amountAsset feeAsset:(NSString*)feeAsset callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)vote:(NSArray*) accounts feeAsset:(NSString*)feeAsset callback:(void(^)(NSError * error, id responseObject)) callback;
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
-(void)getAccount:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountBalances:(NSString*)accountName callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getAccountByPublicKey:(NSString*)publicKey callback:(void(^)(NSError * error, id responseObject)) callback;
```

### Asset API
```Objective-C
-(void)getAsset:(NSString*)symbol callback:(void(^)(NSError * error, id responseObject)) callback;
```

### Object API

```Objective-C
-(void)getObject:(NSString*)objectID callback:(void(^)(NSError * error, id responseObject)) callback;
-(void)getObjects:(NSArray*)objectIDs callback:(void(^)(NSError * error, id responseObject)) callback;
```

### Contract API

```Objective-C

```

