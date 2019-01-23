//
//  GXRPCTest.m
//  gxclient-iosTests
//
//  Created by David Lan on 2019/1/22.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXRPC.h"
#import "GXUtil.h"

@interface GXRPCTest : XCTestCase
@property(nonatomic,strong) GXRPC* rpc;
@end

@implementation GXRPCTest

- (void)setUp {
    [super setUp];
    self.rpc = [GXRPC rpcWithEntryPoint:@"https://testnet.gxchain.org"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testQuery {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Connection Exception"];
    [self.rpc query:@"get_objects" params:@[@[@"2.1.0"]] callback:^(NSError *err, id resp) {
        NSLog(@"%@",resp);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
