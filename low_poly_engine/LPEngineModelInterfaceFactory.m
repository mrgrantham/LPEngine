//
//  EngineModelInterfaceFactory.m
//  low_poly_engine
//
//  Created by James Granthamon 8/20/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#import "LPEngineModelInterfaceFactory.h"
#import "LPEngineModelInterface.h"

@implementation LPEngineModelInterfaceFactory



+ (LPEngineModelInterface *)defaultInterface {
    LPEngineModelInterface *interface = [[LPEngineModelInterface alloc] init];
    // ...
    return interface;
}

@end
