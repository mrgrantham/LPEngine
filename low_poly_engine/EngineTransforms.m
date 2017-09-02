//
//  EngineTransforms.m
//  low_poly_engine
//
//  Created by DEV on 8/18/17.
//  Copyright © 2017 DEV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngineTransforms.h"

static float _3Dmatrix[3][3];

@implementation EngineTransforms

+ (LPPoint) rotate2DAtAxis:(LPPoint)axis ForPoint:(LPPoint)point AtAngle:(float) radians {
    
    LPPoint newPoint;
    
    int x = point.x - axis.x;
    int y = point.y - axis.y;
    
    
    float A = cos(radians);
    float B = -sin(radians);
    float C = -B;
    float D = A;
    
    newPoint.x = (int)(A*(float)(x) + B*(float)(y));
    newPoint.y = (int)(C*(float)(x) + D*(float)(y));
    
    newPoint.x += axis.x;
    newPoint.y += axis.y;
    newPoint.z = 0;
    
    return newPoint;

}

+ (LPPoint) rotateAtAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngles:(LPPoint) radianVector {
    LPPoint temp = {};
    
    return temp;
}

+ (LPPoint) rotateAtXAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians {
    LPPoint temp;
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;
    
    //float _3Dmatrix[][] = new float[3][3];
    
    _3Dmatrix[0][0] = 1;     _3Dmatrix[0][1] = 0;             _3Dmatrix[0][2] = 0;
    _3Dmatrix[1][0] = 0;     _3Dmatrix[1][1] = cos(radians);  _3Dmatrix[1][2] = sin(radians);
    _3Dmatrix[2][0] = 0;     _3Dmatrix[2][1] = -sin(radians);  _3Dmatrix[2][2] = cos(radians);
    
    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;
    
    temp.x = (int)(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = (int)(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = (int)(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);
    
    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;
    
    return temp;

}

+ (LPPoint) rotateAtYAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians {
    LPPoint temp;
    
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;
    
    //float _3Dmatrix[][] = new float[3][3];
    
    _3Dmatrix[0][0] = cos(radians);    _3Dmatrix[0][1] = 0;  _3Dmatrix[0][2] = -sin(radians);
    _3Dmatrix[1][0] = 0;               _3Dmatrix[1][1] = 1;  _3Dmatrix[1][2] = 0;
    _3Dmatrix[2][0] = sin(radians);    _3Dmatrix[2][1] = 0;  _3Dmatrix[2][2] = cos(radians);
    
    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;
    
    temp.x = (int)(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = (int)(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = (int)(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);
    
    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;
    
    return temp;
}

+ (LPPoint) rotateAtZAxis: (LPPoint) axis ForPoint:(LPPoint) point AtAngle:(float) radians {
    LPPoint temp;
    temp.x=point.x-axis.x;
    temp.y=point.y-axis.y;
    temp.z=point.z-axis.z;
    
    //float _3Dmatrix[][] = new float[3][3];
    
    _3Dmatrix[0][0] = cos(radians);    _3Dmatrix[0][1] = sin(radians);  _3Dmatrix[0][2] = 0;
    _3Dmatrix[1][0] = -sin(radians);   _3Dmatrix[1][1] = cos(radians);  _3Dmatrix[1][2] = 0;
    _3Dmatrix[2][0] = 0;               _3Dmatrix[2][1] = 0;             _3Dmatrix[2][2] = 1;
    
    _3Dmatrix[0][0] *= temp.x;     _3Dmatrix[0][1] *= temp.y;           _3Dmatrix[0][2] *= temp.z;
    _3Dmatrix[1][0] *= temp.x;     _3Dmatrix[1][1] *= temp.y;           _3Dmatrix[1][2] *= temp.z;
    _3Dmatrix[2][0] *= temp.x;     _3Dmatrix[2][1] *= temp.y;           _3Dmatrix[2][2] *= temp.z;
    
    temp.x = (int)(_3Dmatrix[0][0] + _3Dmatrix[0][1] + _3Dmatrix[0][2]);
    temp.y = (int)(_3Dmatrix[1][0] + _3Dmatrix[1][1] + _3Dmatrix[1][2]);
    temp.z = (int)(_3Dmatrix[2][0] + _3Dmatrix[2][1] + _3Dmatrix[2][2]);
    
    temp.x += axis.x;
    temp.y += axis.y;
    temp.z += axis.z;
    
    return temp;
}

+ (LPPoint) translatePoint:(LPPoint)point WithVector:(LPPoint)translationVector {
    static NSInteger count = 0;
//    NSLog(@"Entering Translate Point #%li",count);
    LPPoint translatedPoint = point;
    translatedPoint.x = translationVector.x + translatedPoint.x;
    translatedPoint.y = translationVector.y + translatedPoint.y;
    translatedPoint.z = translationVector.z + translatedPoint.z;
//    NSLog(@"Exiting Translate Point #%li",count);
    count++;
    return translatedPoint;
}

+ (LPPoint) scalePoint:(LPPoint)point fromPoint:(LPPoint)centerPoint WithVector:(LPPoint)scaleVector {
    LPPoint scaledPoint = point;
    scaledPoint.x = scaledPoint.x - centerPoint.x;
    scaledPoint.y = scaledPoint.y - centerPoint.y;
    scaledPoint.z = scaledPoint.z - centerPoint.z;
    
    scaledPoint.x = scaleVector.x * scaledPoint.x;
    scaledPoint.y = scaleVector.y * scaledPoint.y;
    scaledPoint.z = scaleVector.z * scaledPoint.z;
    
    scaledPoint.x = scaledPoint.x + centerPoint.x;
    scaledPoint.y = scaledPoint.y + centerPoint.y;
    scaledPoint.z = scaledPoint.z + centerPoint.z;
    
    return scaledPoint;
}

+ (LPPoint) projectionTransformWithPoint:(LPPoint)point withCamera:(LPPoint)camera {

    static LPPoint _2Dpoint = {};
    static LPPoint D = {};
    
    
    // more complex if camera viewport is rotated
    D.x = point.x - camera.x;
    D.y = point.y - camera.y;
    D.z = point.z - camera.z;
    
    _2Dpoint.x = (NSInteger)(-camera.z * D.x / (float)D.z);
    _2Dpoint.y = (NSInteger)(-camera.z * D.y / (float)D.z);
    _2Dpoint.z = (NSInteger)D.z;
    
    _2Dpoint.x += camera.x;
    _2Dpoint.y += camera.y;
    _2Dpoint.z += camera.z;
    
    return _2Dpoint;
}


@end
