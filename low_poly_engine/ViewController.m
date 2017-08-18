//
//  ViewController.m
//  low_poly_engine
//
//  Created by DEV on 8/17/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "ViewController.h"
#import <Metal/Metal.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray <id<MTLDevice>> *allDevs;
    allDevs = MTLCopyAllDevices();
    NSObject<MTLDevice> *aDevice;
    
    if ((aDevice = allDevs.firstObject)) {
        NSLog(@"THERE IS A DEVICE");
    } else {
        NSLog(@"Your GPU does not support Metal!");
    }
    
    _metalLabel.stringValue = @"Your system has the following GPU(s):\n";
    
    for (NSObject<MTLDevice> *dev in allDevs) {
        _metalLabel.stringValue = [NSString stringWithFormat:@"%@\n%@",_metalLabel.stringValue, dev.name ];
    }
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
