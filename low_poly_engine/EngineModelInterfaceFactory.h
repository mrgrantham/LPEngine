//
//  EngineModelInterfaceFactory.h
//  low_poly_engine
//
//  Created by DEV on 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineModelInterface.h"

@interface EngineModelInterfaceFactory : NSObject

+ (EngineModelInterface *)defaultInterface;

@end
