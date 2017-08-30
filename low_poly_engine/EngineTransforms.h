//
//  EngineTransforms.h
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#ifndef EngineTransforms_h
#define EngineTransforms_h

#import "EnginePrimitives.h"

@interface EngineTransforms : NSObject

+ (LPPoint) rotate2DAtAxis:(LPPoint)axis ForPoint:(LPPoint)point AtAngle:(float) radians;
+ (LPPoint) rotateAtAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngles:(LPPoint) radianVector;
+ (LPPoint) rotateAtXAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotateAtYAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotateAtZAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians;

+ (LPPoint) translatePoint:(LPPoint)point WithVector:(LPPoint)translationVector;
+ (LPPoint) scalePoint:(LPPoint)point fromPoint:(LPPoint)centerPoint WithVector:(LPPoint)scaleVector;

@end

#endif /* EngineTransforms_h */
