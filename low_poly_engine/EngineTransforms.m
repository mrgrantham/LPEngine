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

+ (LPPoint) rotate2DAtAxis:(LPPoint)axis WithPoint:(LPPoint)point AtAngle:(float) radians {
    
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

+ (LPPoint) rotate3DAtXAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians {
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

+ (LPPoint) rotate3DAtYAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians {
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

+ (LPPoint) rotate3DAtZAxis: (LPPoint) axis WithPoint:(LPPoint) point AtAngle:(float) radians {
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


@end
