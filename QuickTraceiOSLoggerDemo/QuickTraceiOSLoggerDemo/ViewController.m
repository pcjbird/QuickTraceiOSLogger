//
//  ViewController.m
//  QuickTraceiOSLoggerDemo
//
//  Created by pcjbird on 2018/3/28.
//  Copyright © 2018年 Zero Status. All rights reserved.
//

#import "ViewController.h"
#import <QuickTraceiOSLogger/QuickTraceiOSLogger.h>

@interface ViewController ()

- (IBAction)OnStop:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)OnStop:(id)sender {
    [QuickiOSLogServer stop];
}
@end
