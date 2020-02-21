//
//  GXStakingAPITest.m
//  gxclient-iosTests
//
//  Created by David on 2020/2/20.
//  Copyright © 2020 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXClient.h"

@interface GXStakingAPITest : XCTestCase
@property (nonatomic,strong) GXClient* client;
@end

@implementation GXStakingAPITest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.client=[GXClient clientWithEntryPoint:@"https://testnet.gxchain.org" keyProvider:@"5J7Yu8zZD5oV9Ex7npmsT3XBbpSdPZPBKBzLLQnXz5JHQVQVfNT" account:@"gxb122"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGetStakingPrograms {
    XCTestExpectation * expectation = [self expectationWithDescription:@"get staking programs"];
    [self.client getStakingPrograms:^(NSError *error, NSArray *programs) {
        NSLog(@"%@,%@",error,programs);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)testCreateStaking {
    XCTestExpectation * expectation = [self expectationWithDescription:@"create staking"];
    [self.client createStaking:@"init1" withAmount:10 stakingProgram:@"5" feeAsset:@"GXC" boradcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)testUpdateStaking {
    XCTestExpectation * expectation = [self expectationWithDescription:@"create staking"];
    [self.client updateStaking:@"init1" stakingId:@"1.27.10123" feeAsset:@"GXC" boradcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

- (void)testClaimStaking {
    XCTestExpectation * expectation = [self expectationWithDescription:@"create staking"];
    [self.client claimStaking:@"1.27.10123" feeAsset:@"GXC" boradcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
