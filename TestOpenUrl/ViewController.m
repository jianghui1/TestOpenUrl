//
//  ViewController.m
//  TestOpenUrl
//
//  Created by ys on 2018/9/11.
//  Copyright © 2018年 ys. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)openUrlAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"ms://www.baidu.com"]];
}

- (IBAction)openUrlAction2:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx"]];
    
}

- (IBAction)openUrlAction3:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxx"] options:nil completionHandler:nil];
}

@end
