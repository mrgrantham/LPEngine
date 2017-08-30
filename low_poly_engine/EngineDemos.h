//
//  EngineDemos.h
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineDemos_h
#define EngineDemos_h

#import "EngineModel.h"

@interface EngineDemos : NSObject

@property (nonatomic, strong) EngineModel* arwing;

+ (id)sharedManager;
- (void) triangleDemo;
- (void) arwingDemo;

@end

#endif /* EngineDemos_h */
