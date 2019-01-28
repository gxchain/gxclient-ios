//
//  GXChainAPITest.m
//  gxclient-iosTests
//
//  Created by David Lan on 2019/1/23.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXClient.h"
#import "NSDictionary+Expand.h"

@interface GXChainAPITest : XCTestCase
@property (nonatomic,strong) GXClient* client;
@end

@implementation GXChainAPITest

- (void)setUp {
    [super setUp];
    self.client=[GXClient clientWithEntryPoint:@"https://testnet.gxchain.org" keyProvider:@"5J7Yu8zZD5oV9Ex7npmsT3XBbpSdPZPBKBzLLQnXz5JHQVQVfNT" account:@"gxb122"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testGetBlock{
    XCTestExpectation * expectation = [self expectationWithDescription:@"get block"];
    [self.client getBlock:100 callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void) testGetChainId{
    XCTestExpectation * expectation = [self expectationWithDescription:@"get chain id"];
    [self.client getChainID:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void) testGetDynamicGlobalProperties{
    XCTestExpectation * expectation = [self expectationWithDescription:@"get dynamic global properties"];
    [self.client getDynamicGlobalProperties:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void) testTransfer{
    XCTestExpectation * expectation = [self expectationWithDescription:@"transfer"];
    [self.client transfer:@"gxb121" memo:@"屌不屌" amount:@"10 GXC" feeAsset:@"GXC" broadcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void) testVote{
    XCTestExpectation * expectation = [self expectationWithDescription:@"vote"];
    [self.client vote:@[@"w1",@"w2"] proxyAccount:nil feeAsset:@"GXC" broadcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@", error, [responseObject json]);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

-(void) testGetVoteIds{
    XCTestExpectation * expectation = [self expectationWithDescription:@"get vote ids"];
    [self.client getVoteIdsByAccounts:@[@"w1",@"w2"] callback:^(NSError *error, NSArray *voteIds) {
        NSLog(@"%@,%@",error,voteIds);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
