//
//  LPEngineModelSceneState.m
//  low_poly_engine
//
//  Created by DEV on 9/6/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "LPEngineSceneModelState.h"
#import "LPEngineTransformState.h"
@implementation LPEngineSceneModelState

- (id)initWithModel:(LPEngineModel*)model {
    if (self = [super init]) {
        _model = model;
        _normals = malloc(sizeof(LPPoint) * model.faceCount);
        _lightFactors = malloc(sizeof(float) * model.faceCount);
        _transformedVertices = malloc(sizeof(LPPoint) * model.vertexCount);

        _transformState = [[LPEngineTransformState alloc] init];
        memset(_normals,0,sizeof(LPPoint) * model.faceCount);
        memset(_lightFactors,0,sizeof(float) * model.faceCount);
        memset(_transformedVertices,0,sizeof(LPPoint) * model.vertexCount);

    }
    return self;
}
@end
