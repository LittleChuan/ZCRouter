//
//  ZCViewController.m
//  ZCRouter
//
//  Created by ZackXXC on 10/16/2019.
//  Copyright (c) 2019 ZackXXC. All rights reserved.
//

#import "ZCViewController.h"
#import <ZCRouter/ZCRouter.h>

@interface ZCViewController ()

@end

@implementation ZCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)push:(id)sender {
        [ZCRouter open:@"zcp://main/2?aaa=bbb"];
//        [ZCRouter open:@"2" params:@{@"aaa": @"bbb"}];
}


@end
