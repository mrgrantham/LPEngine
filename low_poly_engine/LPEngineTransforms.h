//
//  EngineTransforms.h
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineTransforms_h
#define EngineTransforms_h

#import "LPEnginePrimitives.h"

@interface LPEngineTransforms : NSObject

+ (LPPoint) rotate2DAtAxis:(LPPoint)axis ForPoint:(LPPoint)point AtAngle:(float) radians;
+ (LPPoint) rotateAtAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngles:(LPPoint) radianVector;
+ (LPPoint) rotateAtXAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotateAtYAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotateAtZAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;

+ (LPPoint) translatePoint:(LPPoint)point WithVector:(LPPoint)translationVector;
+ (LPPoint) scalePoint:(LPPoint)point fromPoint:(LPPoint)centerPoint WithVector:(LPPoint)scaleVector;
+ (matrix_float4x4)projectionMatrixNear:(float)near Far:(float)far Aspect:(float)aspect FieldOfView:(float)fovy;
+ (void)projectionTransformWithPoint:(Vertex *)point withCamera:(LPPoint)camera;
+ (LPPoint) calculateSurfaceNormalWithPlane:(LPTriangle)plane;
@end

#endif /* EngineTransforms_h */
