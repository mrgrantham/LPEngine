//
//  EngineTransforms.h
//  low_poly_engine
//
//  Created by James Granthamon 8/18/17.
//  Copyright © 2017 James Grantham All rights reserved.
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
+ (LPPoint) projectionTransformWithPoint:(LPPoint)point withCamera:(LPPoint)camera;
+ (LPPoint) calculateSurfaceNormalWithPlane:(LPTriangle)plane;
@end

#endif /* EngineTransforms_h */
