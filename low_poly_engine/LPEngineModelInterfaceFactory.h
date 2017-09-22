//
//  EngineModelInterfaceFactory.h
//  low_poly_engine
//
//  Created by James Granthamon 8/20/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPEngineModelInterface.h"

@interface LPEngineModelInterfaceFactory : NSObject

+ (LPEngineModelInterface *)defaultInterface;

@end
