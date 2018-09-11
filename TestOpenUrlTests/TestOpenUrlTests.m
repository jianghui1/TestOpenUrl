//
//  TestOpenUrlTests.m
//  TestOpenUrlTests
//
//  Created by ys on 2018/9/11.
//  Copyright © 2018年 ys. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface TestOpenUrlTests : XCTestCase

@end

@implementation TestOpenUrlTests

- (void)test_111
{
    NSLog(@"111 - start");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
    NSLog(@"222 - end");
    
    // 打印日志
    /*
     2018-09-11 17:34:45.106242+0800 TestOpenUrl[10813:16592945] 111 - start
     2018-09-11 17:34:55.161707+0800 TestOpenUrl[10813:16592945] 222 - end
     */
}

- (void)test_222
{
    NSLog(@"222 - start");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx"]];
    });
    NSLog(@"222 - end");
    
    // 打印日志
    /*
     2018-09-11 17:36:24.810128+0800 TestOpenUrl[10896:16598430] 222 - start
     2018-09-11 17:36:24.853829+0800 TestOpenUrl[10896:16598430] 222 - end
     */
}

- (void)test_333
{
    NSLog(@"333 - start");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
     NSLog(@"333 - end");
    
    // 打印日志
    /*
     2018-09-11 17:37:17.812804+0800 TestOpenUrl[10945:16601725] 333 - start
     2018-09-11 17:37:17.813552+0800 TestOpenUrl[10945:16601725] 333 - end
     */
}

@end
