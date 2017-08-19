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

+ (LPPoint) rotate2DAtAxis:(LPPoint)axis WithPoint:(LPPoint)point AtAngle:(float) radians;
+ (LPPoint) rotate3DAtXAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotate3DAtYAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians;
+ (LPPoint) rotate3DAtZAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians;

@end

#endif /* EngineTransforms_h */
