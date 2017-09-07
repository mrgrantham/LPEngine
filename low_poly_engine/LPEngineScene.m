//
//  EngineScene.m
//  low_poly_engine
//
//  Created by DEV on 8/21/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import "LPEngineScene.h"
#import "LPEngineSceneModelState.h"

@implementation LPEngineScene

- (NSInteger)addModel:(LPEngineModel *)model {
    static NSInteger ID = -1;
    ID++;
    model.lightSource = self.lightSource;
    LPEngineSceneModelState *modelState = [[LPEngineSceneModelState alloc] initWithModel:model];
    [self.models addObject:modelState];
    
    return ID;
}
- (void)transformModelWithID:(NSInteger)modelID
              Transformation:(LPEngineTransformState*)transformation {
    self.models[modelID].transformState = transformation;
}

- (void)draw {
    [self transformVertices];
    for (LPEngineSceneModelState *modelState in self.models) {
        static int face;
        for (face = 0; face < modelState.model.faceCount; face++) {
            static NSInteger red;
            static NSInteger green;
            static NSInteger blue;
            red = (NSInteger)(modelState.lightFactors[face] * 40.0 + 150);
            green = (NSInteger)((modelState.lightFactors[face] * 40.0) + 150);
            blue = (NSInteger)((modelState.lightFactors[face] * 40.0) + 150);
            red = red > 255? 255 : red;
            green = green > 255 ? 255 : green;
            blue = blue > 255 ? 255 : blue;
            //            NSLog(@"color for face with lightfactor %0.2f red: %li green: %li blue: %li",self.lightFactors[face] ,red,green,blue);
            [self.primitives setColorWithRed:red Green:green Blue:blue];
            float *point = (float*)&modelState.model.faces[face];
            [self.primitives drawTriangleAtPoint1:&modelState.transformedVertices[(NSInteger)*(point + 0)]
                                Point2:&modelState.transformedVertices[(NSInteger)*(point + 1)]
                                Point3:&modelState.transformedVertices[(NSInteger)*(point + 2)]];
        }
    }
}

- (void)transformVertices {
    for (LPEngineSceneModelState *modelState in self.models) {
    
        // transform for model space
        [modelState.model transformVertices];
        [modelState.model findVertexCenter];
        modelState.modelCenter = [LPEngineTransforms translatePoint:modelState.model.center WithVector:modelState.transformState.translation];

        
        // transform for scene space
        for (int vertex = 0; vertex < modelState.model.vertexCount; vertex++) {
            static LPPoint temp;
            temp = modelState.model.transformedVertices[vertex];
            temp = [LPEngineTransforms translatePoint:temp WithVector:modelState.transformState.translation];
            temp = [LPEngineTransforms scalePoint:temp fromPoint:modelState.modelCenter WithVector:modelState.model.scale];
            temp = [LPEngineTransforms rotateAtXAxis:modelState.modelCenter ForPoint:temp AtAngle:modelState.model.rotation.x];
            temp = [LPEngineTransforms rotateAtYAxis:modelState.modelCenter ForPoint:temp AtAngle:modelState.model.rotation.y];
            temp = [LPEngineTransforms rotateAtZAxis:modelState.modelCenter ForPoint:temp AtAngle:modelState.model.rotation.z];
            modelState.transformedVertices[vertex] = temp;
            
        }
        // calculate light for each face before the
        for (int face = 0; face < modelState.model.faceCount; face++) {
            float faceIndex1 = modelState.model.faces[face].x;
            float faceIndex2 = modelState.model.faces[face].y;
            float faceIndex3 = modelState.model.faces[face].z;
            modelState.normals[face] = [LPEngineTransforms calculateSurfaceNormalWithPlane:LPTriangleMake(modelState.transformedVertices[(NSInteger)faceIndex1], modelState.transformedVertices[(NSInteger)faceIndex2], modelState.transformedVertices[(NSInteger)faceIndex3])];
            //        self.lightFactors[face] = [self findLightFactor:self.transformedNormals[face] ];
            modelState.lightFactors[face] = [modelState.model findLightFactor:modelState.normals[face] ];
            
        }
        
        for (int vertex = 0; vertex < modelState.model.vertexCount; vertex++) {
            static LPPoint temp;
            temp = modelState.transformedVertices[vertex];
            //EnginePrimitives *primitives = [EnginePrimitives sharedManager];
    
            temp = [LPEngineTransforms projectionTransformWithPoint:temp withCamera:[[LPEnginePrimitives sharedManager] camera]];
            modelState.transformedVertices[vertex] = temp;
        }
        
    
    }
    
}

- (id)init {
    if (self = [super init]) {
        _models = [NSMutableArray array];
        _primitives = [LPEnginePrimitives sharedManager];
    }
    return self;
}

@end
