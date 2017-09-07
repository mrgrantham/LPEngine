//
//  EngineScene.h
//  low_poly_engine
//
//  Created by DEV on 8/21/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPEngineModel.h"
#import "LPEngineTransforms.h"
#import "LPEnginePrimitives.h"
#import "LPEngineSceneModelState.h"

typedef NS_ENUM(NSInteger, LPEngineModelTransform) {
    LPEngineModelTransformRotate,
    LPEngineModelTransformScale,
    LPEngineModelTransformTranslate
};




@interface LPEngineScene : NSObject

@property (nonatomic, strong) NSMutableArray<LPEngineSceneModelState *> *models;
@property (nonatomic, strong) LPEnginePrimitives *primitives;
@property (nonatomic, assign) LPPoint lightSource;

- (NSInteger)addModel:(LPEngineModel *)model;
- (void)transformModelWithID:(NSInteger)modelID
              Transformation:(LPEngineTransformState*)transformation;
- (void)transformVertices;
- (void)draw;
- (id)init;

@end
