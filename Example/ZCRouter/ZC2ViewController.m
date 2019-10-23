//
//  ZC2ViewController.m
//  ZCRouter_Example
//
//  Created by Chuan on 2019/10/16.
//  Copyright © 2019 ZackXXC. All rights reserved.
//

#import "ZC2ViewController.h"

#import <ZCRouter/ZCRouter.h>

@interface ZC2ViewController () <ZCRouter>

@end

@implementation ZC2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
    
    self.title = self.aaa;
}

+ (NSString *)zc_router {
    return @"zcp://main/2";
}

@end
