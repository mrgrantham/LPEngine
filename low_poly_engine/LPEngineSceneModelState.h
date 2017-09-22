//
//  LPEngineModelSceneState.h
//  low_poly_engine
//
//  Created by James Granthamon 9/6/17.
//  Copyright © 2017 James Grantham All rights reserved.
//

#ifndef LPENGINESCENEMODELSTATE_H
#define LPENGINESCENEMODELSTATE_H

#import <Foundation/Foundation.h>
#import "LPEngineModel.h"
#import "LPEngineTransforms.h"
#import "LPEngineTransformState.h"
#import "LPEnginePrimitives.h"

@interface LPEngineSceneModelState : NSObject

@property (nonatomic, strong) LPEngineModel *model;
@property (nonatomic, strong) LPEngineTransformState *transformState;
@property (nonatomic, assign) LPPoint *transformedVertices;
@property (nonatomic, assign) float *lightFactors;
@property (nonatomic, assign) LPPoint *normals;
@property (nonatomic, assign) LPPoint modelCenter;

- (id)init NS_UNAVAILABLE;
- (id)initWithModel:(LPEngineModel*)model NS_DESIGNATED_INITIALIZER;

@end

#endif
