//
//  GXContractAPITest.m
//  gxclient-iosTests
//
//  Created by David Lan on 2019/1/29.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXClient.h"
#import "NSDictionary+Expand.h"

@interface GXContractAPITest : XCTestCase
@property (nonatomic,strong) GXClient* client;
@end

@implementation GXContractAPITest

- (void)setUp {
    [super setUp];
    self.client=[GXClient clientWithEntryPoint:@"https://testnet.gxchain.org" keyProvider:@"5J7Yu8zZD5oV9Ex7npmsT3XBbpSdPZPBKBzLLQnXz5JHQVQVfNT" account:@"gxb122"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testCallContract{
    XCTestExpectation * expectation = [self expectationWithDescription:@"vote"];
    [self.client callContract:@"bank" method:@"deposit" params:nil amount:@"10 GXC" feeAsset:@"GXC" broadcast:YES callback:^(NSError *error, id responseObject) {
        NSLog(@"%@,%@",error,responseObject);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}


@end
