//
//  GXClientKeyPairAPITest.m
//  gxclient-iosTests
//
//  Created by David Lan on 2019/1/23.
//  Copyright © 2019年 GXChain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GXClient.h"

@interface GXKeyPairAPITest : XCTestCase
@property (nonatomic,strong) GXClient* client;
@end

@implementation GXKeyPairAPITest

- (void)setUp {
    [super setUp];
    self.client = [GXClient new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGenerateKey {
    NSLog(@"%@",[self.client generateKey:@"shrover gusher learner crare raj sindle girse cobiron bunchy trimly unbled ley dagger ama pelter brunet"]);
}

- (void)testPrivateToPublic{
    NSAssert([[self.client privateToPublic:@"5KixM6Kk5kf7pY6Wdz9QmahwhupkZJF9ETXWKeofRtLbV93NrMh"] isEqualToString:@"GXC82nDW5K3rrfKrBELJL22AUTmn1H7TvAQSMrnb7cCdCaCfNQ8cG"], @"Invalid Private Key");
}

- (void)testIsValidPrivate{
    NSAssert([self.client isValidPrivate:@"5KixM6Kk5kf7pY6Wdz9QmahwhupkZJF9ETXWKeofRtLbV93NrMh"], @"Invalid Private Key");
}

- (void)testIsValidPublic{
    NSAssert([self.client isValidPublic:@"GXC82nDW5K3rrfKrBELJL22AUTmn1H7TvAQSMrnb7cCdCaCfNQ8cG"],@"Invalid Public Key");
}

@end
