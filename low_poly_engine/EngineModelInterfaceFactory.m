//
//  EngineModelInterfaceFactory.m
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "EngineModelInterfaceFactory.h"
#import "EngineModelInterface.h"

@implementation EngineModelInterfaceFactory



+ (EngineModelInterface *)defaultInterface {
    EngineModelInterface *interface = [[EngineModelInterface alloc] init];
    // ...
    return interface;
}

@end
