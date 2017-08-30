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
@property (nonatomic, assign) BOOL rotateContinuous;
@property (nonatomic, assign) BOOL translateContinuous;
@property (nonatomic, assign) BOOL scaleContinuous;


+ (id)sharedManager;
- (id) init;
- (void) triangleDemo;
- (void) arwingDemo;
- (void) resetArwing;

@end

#endif /* EngineDemos_h */
