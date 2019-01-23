//
//  GXClientFaucetAPITest.m
//  gxclient-iosTests
//
//  Created by David Lan on 2019/1/23.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXClient.h"

@interface GXClientFaucetAPITest : XCTestCase
@property (nonatomic,strong) GXClient* client;
@end

@implementation GXClientFaucetAPITest

- (void)setUp {
    [super setUp];
    self.client = [GXClient new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegister {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Register fail exception"];
    [self.client registerAccount:@"test-register-01" activeKey:@"GXC8CJACbLWM3urXynUeqTTqTT7wUR2GZBVpoeP7SeE96qgv1c3pp" ownerKey:nil memoKey:nil callback:^(NSError *error, id responseObject) {
        if(error){
            NSLog(@"Register failed with error: %@",error.localizedDescription);
        } else{
            NSLog(@"%@",responseObject);
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
}

@end
