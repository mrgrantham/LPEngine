//
//  EngineModelInterfaceFactory.m
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "LPEngineModelInterfaceFactory.h"
#import "EngineModelInterface.h"

@implementation LPEngineModelInterfaceFactory



+ (EngineModelInterface *)defaultInterface {
    EngineModelInterface *interface = [[EngineModelInterface alloc] init];
    // ...
    return interface;
}

@end
